from __future__ import annotations

import re
from typing import Any

from .util import normalize_path


REQUEST_METHOD_RE = re.compile(r"RequestMethod\.([A-Z]+)")
PREDICATE_RE = re.compile(r"\{?\s*([A-Z,\s]*)?\s*\[([^\]]+)\]")


def normalize_actuator_mappings(mappings: dict[str, Any]) -> list[dict[str, Any]]:
    routes: list[dict[str, Any]] = []
    for entry in _iter_mapping_entries(mappings):
        methods, paths = _methods_and_paths(entry)
        handler = str(entry.get("handler") or "")
        controller, handler_name = _handler_parts(entry, handler)
        for path in paths:
            for method in methods:
                routes.append(
                    {
                        "method": method,
                        "path": normalize_path(path),
                        "surface": _surface(path),
                        "controller": controller,
                        "handler": handler_name,
                        "runtimeHandler": handler,
                        "source": "actuator",
                    }
                )
    return sorted(
        _dedupe(routes),
        key=lambda route: (route["path"], route["method"], route.get("controller", ""), route.get("handler", "")),
    )


def _iter_mapping_entries(value: Any) -> list[dict[str, Any]]:
    entries: list[dict[str, Any]] = []

    def visit(node: Any) -> None:
        if isinstance(node, list):
            for item in node:
                visit(item)
            return
        if not isinstance(node, dict):
            return
        if "predicate" in node and "handler" in node:
            entries.append(node)
            return
        for child in node.values():
            visit(child)

    visit(value)
    return entries


def _methods_and_paths(entry: dict[str, Any]) -> tuple[list[str], list[str]]:
    details = entry.get("details") if isinstance(entry.get("details"), dict) else {}
    conditions = details.get("requestMappingConditions") if isinstance(details.get("requestMappingConditions"), dict) else {}

    methods = _strings(conditions.get("methods"))
    paths = _strings(conditions.get("patterns")) or _strings(conditions.get("pathPatterns"))

    if not paths:
        predicate_methods, predicate_paths = _parse_predicate(str(entry.get("predicate") or ""))
        methods = methods or predicate_methods
        paths = predicate_paths

    if not methods:
        methods = ["ANY"]
    return sorted({method.upper() for method in methods}), sorted({path for path in paths if path})


def _handler_parts(entry: dict[str, Any], handler: str) -> tuple[str, str]:
    details = entry.get("details") if isinstance(entry.get("details"), dict) else {}
    handler_method = details.get("handlerMethod") if isinstance(details.get("handlerMethod"), dict) else {}

    class_name = str(handler_method.get("className") or "")
    method_name = str(handler_method.get("name") or "")
    if class_name:
        controller = class_name.rsplit(".", 1)[-1]
        return controller, method_name

    if "#" in handler:
        left, right = handler.split("#", 1)
        controller = left.rsplit(".", 1)[-1]
        method = right.split("(", 1)[0]
        return controller, method

    return "", ""


def _parse_predicate(predicate: str) -> tuple[list[str], list[str]]:
    methods: list[str] = []
    paths: list[str] = []
    for match in PREDICATE_RE.finditer(predicate):
        method_part = (match.group(1) or "").strip()
        path_part = match.group(2)
        for method in re.split(r"[,\s]+", method_part):
            if method:
                methods.append(method.upper())
        for path in path_part.split(","):
            cleaned = path.strip()
            if cleaned.startswith("/"):
                paths.append(cleaned)
    return sorted(set(methods)), sorted(set(paths))


def _strings(value: Any) -> list[str]:
    if isinstance(value, list):
        return [str(item) for item in value]
    if isinstance(value, str):
        return [value]
    return []


def _surface(path: str) -> str:
    normalized = normalize_path(path)
    if normalized.startswith("/api/") or normalized == "/api":
        return "REST API"
    if normalized.startswith("/actuator"):
        return "Actuator"
    if normalized.startswith(("/v3/api-docs", "/swagger-ui")):
        return "API Docs"
    if normalized.startswith(("/css/", "/js/", "/img/", "/media/")):
        return "Static/Media"
    return "Web"


def _dedupe(routes: list[dict[str, Any]]) -> list[dict[str, Any]]:
    seen = set()
    deduped = []
    for route in routes:
        key = (route.get("method"), route.get("path"), route.get("controller"), route.get("handler"))
        if key in seen:
            continue
        seen.add(key)
        deduped.append(route)
    return deduped

