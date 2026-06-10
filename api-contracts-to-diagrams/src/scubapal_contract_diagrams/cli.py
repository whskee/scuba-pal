from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Any
from urllib.parse import urljoin

from .actuator import normalize_actuator_mappings
from .inventory import build_inventory
from .java_scan import scan_java_project
from .merge import merge_routes
from .openapi import normalize_openapi
from .render import render_dot, render_inventory_markdown, render_mermaid, render_route_markdown
from .util import CollectionError, fetch_json, read_json, relpath, write_json, write_text


DEFAULT_OPENAPI_CANDIDATES = [
    "scubapal-ios/OpenAPI/scubapal-openapi.json",
    "scubapal-ios/Packages/ScubaPalAPI/Sources/ScubaPalAPI/openapi.json",
    "docs/routes/openapi.json",
]


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        result = generate(args)
    except (CollectionError, ValueError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    print(f"Wrote {len(result['files'])} files:")
    for path in result["files"]:
        print(f"  - {path}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Collect Scuba Pal API contracts and generate deterministic route diagrams.",
    )
    parser.add_argument("--repo-root", type=Path, default=Path.cwd(), help="Repository root. Defaults to cwd.")
    parser.add_argument("--base-url", default="http://localhost:8080", help="Running Spring Boot base URL.")
    parser.add_argument("--openapi-url", default="/v3/api-docs", help="OpenAPI path or absolute URL.")
    parser.add_argument("--mappings-url", default="/actuator/mappings", help="Actuator mappings path or absolute URL.")
    parser.add_argument("--openapi-file", type=Path, help="Use this OpenAPI JSON file instead of discovery fallback.")
    parser.add_argument("--mappings-file", type=Path, help="Use this Actuator mappings JSON file if live mappings are unavailable.")
    parser.add_argument("--output-dir", type=Path, default=Path("docs/routes"), help="Machine artifact output directory.")
    parser.add_argument("--docs-dir", type=Path, default=Path("docs/content/api/routes"), help="Docusaurus docs output directory.")
    parser.add_argument("--timeout", type=float, default=4.0, help="HTTP fetch timeout in seconds.")
    parser.add_argument("--skip-fetch", action="store_true", help="Do not call the running app; use files/source only.")
    parser.add_argument("--require-live", action="store_true", help="Fail if live OpenAPI or mappings cannot be fetched.")
    parser.add_argument("--api-only-diagram", action="store_true", help="Render only REST API routes in route-map.mmd.")
    return parser


def generate(args: argparse.Namespace) -> dict[str, Any]:
    repo_root = args.repo_root.resolve()
    output_dir = _resolve(repo_root, args.output_dir)
    docs_dir = _resolve(repo_root, args.docs_dir)

    source_report: list[dict[str, str]] = []
    openapi_raw, openapi_source = _collect_openapi(args, repo_root, source_report)
    mappings_raw, mappings_source = _collect_mappings(args, repo_root, source_report)

    openapi_summary = normalize_openapi(openapi_raw)
    actuator_routes = normalize_actuator_mappings(mappings_raw) if mappings_raw else []
    java_summary = scan_java_project(repo_root)
    routes = merge_routes(openapi_summary["endpoints"], actuator_routes, java_summary["routes"], java_summary)
    inventory = build_inventory(repo_root, openapi_summary, java_summary)

    collection = {
        "sources": source_report,
        "openapiSource": openapi_source,
        "mappingsSource": mappings_source,
        "routeCount": len(routes),
    }

    mermaid = render_mermaid(routes, include_non_api=not args.api_only_diagram)
    dot = render_dot(routes)
    route_markdown = render_route_markdown(routes, mermaid, collection)
    inventory_markdown = render_inventory_markdown(inventory)

    files: list[Path] = []
    for path, value in [
        (output_dir / "openapi.json", openapi_raw),
        (output_dir / "routes.json", {"routes": routes}),
        (output_dir / "scubapal-inventory.json", inventory),
        (output_dir / "collection-report.json", collection),
    ]:
        write_json(path, value)
        files.append(path)

    if mappings_raw:
        write_json(output_dir / "spring-mappings.json", mappings_raw)
        files.append(output_dir / "spring-mappings.json")

    for path, text in [
        (output_dir / "route-map.mmd", mermaid),
        (output_dir / "route-map.dot", dot),
        (output_dir / "route-map.md", route_markdown),
        (docs_dir / "_category_.json", '{\n  "label": "Generated Routes",\n  "position": 99\n}\n'),
        (docs_dir / "route-map.md", route_markdown),
        (docs_dir / "scubapal-inventory.md", inventory_markdown),
    ]:
        write_text(path, text)
        files.append(path)

    return {"files": [relpath(path, repo_root) for path in files], "routes": routes}


def _collect_openapi(args: argparse.Namespace, repo_root: Path, report: list[dict[str, str]]) -> tuple[dict[str, Any], str]:
    if args.openapi_file:
        path = _resolve(repo_root, args.openapi_file)
        report.append({"name": "OpenAPI", "status": "file", "detail": relpath(path, repo_root)})
        return read_json(path), relpath(path, repo_root)

    if not args.skip_fetch:
        url = _source_url(args.base_url, args.openapi_url)
        try:
            value = fetch_json(url, args.timeout)
            report.append({"name": "OpenAPI", "status": "live", "detail": url})
            return value, url
        except CollectionError as exc:
            if args.require_live:
                raise
            report.append({"name": "OpenAPI live", "status": "unavailable", "detail": _safe_detail(str(exc))})

    for candidate in DEFAULT_OPENAPI_CANDIDATES:
        path = repo_root / candidate
        if path.exists():
            report.append({"name": "OpenAPI", "status": "fallback-file", "detail": candidate})
            return read_json(path), candidate

    raise CollectionError("OpenAPI was not available from the running app and no fallback JSON file was found.")


def _collect_mappings(args: argparse.Namespace, repo_root: Path, report: list[dict[str, str]]) -> tuple[dict[str, Any] | None, str]:
    if not args.skip_fetch:
        url = _source_url(args.base_url, args.mappings_url)
        try:
            value = fetch_json(url, args.timeout)
            report.append({"name": "Actuator mappings", "status": "live", "detail": url})
            return value, url
        except CollectionError as exc:
            if args.require_live:
                raise
            report.append({"name": "Actuator mappings live", "status": "unavailable", "detail": _safe_detail(str(exc))})

    if args.mappings_file:
        path = _resolve(repo_root, args.mappings_file)
        report.append({"name": "Actuator mappings", "status": "file", "detail": relpath(path, repo_root)})
        return read_json(path), relpath(path, repo_root)

    generated = repo_root / "docs" / "routes" / "spring-mappings.json"
    if generated.exists():
        report.append({"name": "Actuator mappings", "status": "fallback-file", "detail": relpath(generated, repo_root)})
        return read_json(generated), relpath(generated, repo_root)

    report.append({"name": "Actuator mappings", "status": "not-collected", "detail": "Run the app with the dev profile to collect runtime mappings."})
    return None, ""


def _source_url(base_url: str, path_or_url: str) -> str:
    if path_or_url.startswith(("http://", "https://")):
        return path_or_url
    return urljoin(base_url.rstrip("/") + "/", path_or_url.lstrip("/"))


def _resolve(repo_root: Path, path: Path) -> Path:
    return path if path.is_absolute() else repo_root / path


def _safe_detail(detail: str) -> str:
    return detail.replace("|", "\\|").replace("\n", " ")[:240]

