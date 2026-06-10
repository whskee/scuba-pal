from __future__ import annotations

import json
import re
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any


HTTP_METHODS = {"get", "put", "post", "delete", "patch", "options", "head", "trace"}
HTTP_METHOD_ORDER = {
    "GET": 10,
    "POST": 20,
    "PUT": 30,
    "PATCH": 40,
    "DELETE": 50,
    "OPTIONS": 60,
    "HEAD": 70,
    "TRACE": 80,
    "ANY": 90,
}


class CollectionError(RuntimeError):
    """Raised when a required source cannot be collected or parsed."""


def read_json(path: Path) -> Any:
    try:
        with path.open("r", encoding="utf-8") as handle:
            return json.load(handle)
    except FileNotFoundError as exc:
        raise CollectionError(f"JSON file does not exist: {path}") from exc
    except json.JSONDecodeError as exc:
        raise CollectionError(f"Invalid JSON in {path}: {exc}") from exc


def write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        json.dump(value, handle, ensure_ascii=False, indent=2, sort_keys=True)
        handle.write("\n")


def write_text(path: Path, value: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(value, encoding="utf-8")


def fetch_json(url: str, timeout: float) -> Any:
    request = urllib.request.Request(url, headers={"Accept": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            body = response.read()
    except urllib.error.URLError as exc:
        raise CollectionError(f"Could not fetch {url}: {exc}") from exc

    try:
        return json.loads(body.decode("utf-8"))
    except json.JSONDecodeError as exc:
        raise CollectionError(f"Invalid JSON from {url}: {exc}") from exc


def relpath(path: Path, root: Path) -> str:
    try:
        return path.resolve().relative_to(root.resolve()).as_posix()
    except ValueError:
        return path.resolve().as_posix()


def stable_unique(values: list[str]) -> list[str]:
    return sorted({value for value in values if value})


def normalize_path(path: str) -> str:
    if not path:
        return "/"
    normalized = re.sub(r"/+", "/", path.strip())
    if not normalized.startswith("/"):
        normalized = "/" + normalized
    if len(normalized) > 1:
        normalized = normalized.rstrip("/")
    return normalized


def join_paths(prefix: str, suffix: str) -> str:
    if not prefix:
        return normalize_path(suffix)
    if not suffix:
        return normalize_path(prefix)
    return normalize_path(prefix.rstrip("/") + "/" + suffix.lstrip("/"))


def route_sort_key(route: dict[str, Any]) -> tuple[str, int, str]:
    return (
        str(route.get("path", "")),
        HTTP_METHOD_ORDER.get(str(route.get("method", "ANY")).upper(), 999),
        str(route.get("operationId") or route.get("handler") or ""),
    )


def mermaid_id(prefix: str, text: str, used: set[str]) -> str:
    base = re.sub(r"[^A-Za-z0-9_]+", "_", text).strip("_")
    if not base:
        base = "node"
    if base[0].isdigit():
        base = "_" + base
    candidate = f"{prefix}_{base}"[:80]
    original = candidate
    counter = 2
    while candidate in used:
        candidate = f"{original}_{counter}"
        counter += 1
    used.add(candidate)
    return candidate


def mermaid_label(text: str) -> str:
    text = text.replace("<br/>", "\n")
    escaped = (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "#quot;")
        .replace("\n", "<br/>")
    )
    return escaped


def dot_id(text: str) -> str:
    base = re.sub(r"[^A-Za-z0-9_]+", "_", text).strip("_")
    if not base:
        base = "node"
    if base[0].isdigit():
        base = "_" + base
    return base


def dot_label(text: str) -> str:
    return text.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")
