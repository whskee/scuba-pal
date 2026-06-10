from __future__ import annotations

import re
from pathlib import Path
from typing import Any

from .util import relpath


FEATURE_RE = re.compile(r"^\s*\d+\.\s+(.+?)\s*$")
TABLE_ROW_RE = re.compile(r"^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|")
DBML_TABLE_RE = re.compile(r'Table\s+"([^"]+)"\."([^"]+)"')


def build_inventory(repo_root: Path, openapi_summary: dict[str, Any], java_summary: dict[str, Any]) -> dict[str, Any]:
    readme = repo_root / "README.md"
    readme_text = readme.read_text(encoding="utf-8") if readme.exists() else ""
    migrations = sorted((repo_root / "scubapal-app" / "src" / "main" / "resources" / "db" / "migration").glob("*.sql"))
    dbml_tables = _dbml_tables(repo_root / "database.dbml")

    features, stack = _readme_context(readme_text)
    return {
        "project": {
            "name": "Scuba Pal",
            "description": _description(readme_text),
            "features": features,
            "stack": stack,
        },
        "counts": {
            "controllers": len(java_summary.get("controllers", [])),
            "services": len(java_summary.get("services", [])),
            "repositories": len(java_summary.get("repositories", [])),
            "entities": len(java_summary.get("entities", [])),
            "databaseTables": len(dbml_tables),
            "flywayMigrations": len(migrations),
            "openapiEndpoints": len(openapi_summary.get("endpoints", [])),
            "openapiSchemas": len(openapi_summary.get("schemas", [])),
        },
        "openapi": {
            "title": openapi_summary.get("info", {}).get("title", ""),
            "version": openapi_summary.get("info", {}).get("version", ""),
            "tags": openapi_summary.get("tags", []),
            "schemas": openapi_summary.get("schemas", []),
        },
        "backend": {
            "controllers": java_summary.get("controllers", []),
            "services": java_summary.get("services", []),
            "repositories": java_summary.get("repositories", []),
            "entities": java_summary.get("entities", []),
        },
        "database": {
            "tables": dbml_tables,
            "migrations": [relpath(path, repo_root) for path in migrations],
        },
    }


def _readme_context(text: str) -> tuple[list[str], list[dict[str, str]]]:
    features: list[str] = []
    stack: list[dict[str, str]] = []
    in_features = False
    in_stack_table = False
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("# Features"):
            in_features = True
            continue
        if in_features:
            match = FEATURE_RE.match(line)
            if match:
                features.append(match.group(1))
                continue
            if stripped.startswith("#") or stripped.startswith("<h3"):
                in_features = False
        if stripped.startswith("|") and "Domain" in stripped and "Core" in stripped:
            in_stack_table = True
            continue
        if in_stack_table:
            if not stripped.startswith("|"):
                in_stack_table = False
                continue
            if set(stripped.replace("|", "").replace(":", "").replace("-", "").strip()) == set():
                continue
            match = TABLE_ROW_RE.match(line)
            if match:
                domain = _strip_markdown(match.group(1))
                core = _strip_markdown(match.group(2))
                if domain and core and domain.lower() != "domain":
                    stack.append({"domain": domain, "core": core})
    return features, stack


def _description(text: str) -> str:
    for line in text.splitlines():
        stripped = line.strip()
        if stripped and not stripped.startswith("<") and not stripped.startswith("#") and "Scuba Pal is" in stripped:
            return _strip_markdown(stripped)
    return "A community platform for scuba divers."


def _dbml_tables(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    tables = []
    for schema, name in DBML_TABLE_RE.findall(path.read_text(encoding="utf-8")):
        tables.append({"schema": schema, "name": name, "qualifiedName": f"{schema}.{name}"})
    return sorted(tables, key=lambda value: value["qualifiedName"])


def _strip_markdown(value: str) -> str:
    value = re.sub(r"<[^>]+>", "", value)
    value = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", value)
    value = value.replace("`", "")
    return re.sub(r"\s+", " ", value).strip()

