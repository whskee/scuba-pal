from __future__ import annotations

from typing import Any

from .security import classify_auth
from .util import route_sort_key, stable_unique


def merge_routes(
    openapi_routes: list[dict[str, Any]],
    actuator_routes: list[dict[str, Any]],
    java_routes: list[dict[str, Any]],
    java_summary: dict[str, Any],
) -> list[dict[str, Any]]:
    merged: dict[tuple[str, str], dict[str, Any]] = {}
    sources_by_key: dict[tuple[str, str], set[str]] = {}

    for route in java_routes:
        key = _key(route)
        merged.setdefault(key, _base_route(route))
        _overlay(merged[key], route)
        sources_by_key.setdefault(key, set()).add("java")

    for route in actuator_routes:
        key = _key(route)
        merged.setdefault(key, _base_route(route))
        _overlay(merged[key], route)
        sources_by_key.setdefault(key, set()).add("actuator")

    for route in openapi_routes:
        key = _key(route)
        merged.setdefault(key, _base_route(route))
        _overlay(merged[key], route)
        sources_by_key.setdefault(key, set()).add("openapi")

    tables_by_controller = java_summary.get("tablesByController", {})
    events_by_controller = java_summary.get("eventsByController", {})

    output = []
    for key, route in merged.items():
        route["sources"] = sorted(sources_by_key.get(key, set()))
        route["contractOnly"] = "openapi" in route["sources"] and "actuator" not in route["sources"] and "java" not in route["sources"]
        route["runtimeOnly"] = "actuator" in route["sources"] and "openapi" not in route["sources"]
        auth = classify_auth(str(route.get("method", "ANY")), str(route.get("path", "")))
        route["auth"] = auth["auth"]
        route["roles"] = auth["roles"]
        controller = str(route.get("controller", ""))
        route["tablesTouched"] = tables_by_controller.get(controller, [])
        route["eventsEmitted"] = events_by_controller.get(controller, [])
        route.setdefault("calledBy", [])
        route["routeKey"] = f"{route.get('method')} {route.get('path')}"
        output.append(route)

    return sorted(output, key=route_sort_key)


def _base_route(route: dict[str, Any]) -> dict[str, Any]:
    return {
        "method": route.get("method", "ANY"),
        "path": route.get("path", ""),
        "surface": route.get("surface", ""),
        "tag": route.get("tag", ""),
        "summary": "",
        "description": "",
        "operationId": "",
        "parameters": [],
        "requestDto": "",
        "responseDto": "",
        "responseCodes": [],
        "controller": "",
        "handler": "",
        "sourceFile": "",
        "runtimeHandler": "",
        "tablesTouched": [],
        "eventsEmitted": [],
        "calledBy": [],
    }


def _overlay(target: dict[str, Any], route: dict[str, Any]) -> None:
    for key, value in route.items():
        if value in ("", None, []):
            continue
        if key in {"parameters", "responseCodes"}:
            existing = target.get(key, [])
            if isinstance(existing, list) and isinstance(value, list):
                if key == "parameters":
                    seen = {(item.get("in"), item.get("name")) for item in existing if isinstance(item, dict)}
                    for item in value:
                        if not isinstance(item, dict):
                            continue
                        item_key = (item.get("in"), item.get("name"))
                        if item_key not in seen:
                            existing.append(item)
                            seen.add(item_key)
                    target[key] = sorted(existing, key=lambda item: (item.get("in", ""), item.get("name", "")))
                else:
                    target[key] = stable_unique([str(item) for item in existing + value])
            continue
        target[key] = value


def _key(route: dict[str, Any]) -> tuple[str, str]:
    return (str(route.get("method", "ANY")).upper(), str(route.get("path", "")))

