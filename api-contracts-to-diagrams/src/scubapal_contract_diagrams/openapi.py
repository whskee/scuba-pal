from __future__ import annotations

from typing import Any

from .util import HTTP_METHODS, normalize_path, stable_unique


def normalize_openapi(openapi: dict[str, Any]) -> dict[str, Any]:
    paths = openapi.get("paths")
    if not isinstance(paths, dict):
        raise ValueError("OpenAPI document is missing a paths object")

    endpoints: list[dict[str, Any]] = []
    global_security = openapi.get("security", [])
    for path in sorted(paths):
        path_item = paths[path]
        if not isinstance(path_item, dict):
            continue
        path_parameters = path_item.get("parameters", [])
        for method in sorted(path_item, key=lambda value: value.lower()):
            method_key = method.lower()
            if method_key not in HTTP_METHODS:
                continue
            operation = path_item.get(method)
            if not isinstance(operation, dict):
                continue
            parameters = _parameters(path_parameters, operation.get("parameters", []))
            request_schema = _request_schema(operation.get("requestBody"))
            response_schema = _response_schema(operation.get("responses", {}))
            response_codes = sorted(str(code) for code in operation.get("responses", {}).keys())
            tags = operation.get("tags") if isinstance(operation.get("tags"), list) else []
            tag = str(tags[0]) if tags else _tag_from_path(path)

            endpoints.append(
                {
                    "method": method_key.upper(),
                    "path": normalize_path(path),
                    "surface": _surface(path),
                    "tag": tag,
                    "summary": str(operation.get("summary") or ""),
                    "description": str(operation.get("description") or ""),
                    "operationId": str(operation.get("operationId") or ""),
                    "parameters": parameters,
                    "requestDto": request_schema,
                    "responseDto": response_schema,
                    "responseCodes": response_codes,
                    "openapiSecurity": operation.get("security", global_security),
                    "source": "openapi",
                }
            )

    components = openapi.get("components", {})
    schemas = []
    if isinstance(components, dict) and isinstance(components.get("schemas"), dict):
        schemas = sorted(str(name) for name in components["schemas"])

    tags = []
    for tag in openapi.get("tags", []):
        if isinstance(tag, dict) and tag.get("name"):
            tags.append(
                {
                    "name": str(tag["name"]),
                    "description": str(tag.get("description") or ""),
                }
            )

    return {
        "info": openapi.get("info", {}),
        "servers": openapi.get("servers", []),
        "tags": sorted(tags, key=lambda value: value["name"].lower()),
        "schemas": schemas,
        "endpoints": sorted(endpoints, key=lambda route: (route["path"], route["method"], route["operationId"])),
    }


def _parameters(path_parameters: Any, operation_parameters: Any) -> list[dict[str, str]]:
    merged = []
    for parameter in _as_list(path_parameters) + _as_list(operation_parameters):
        if not isinstance(parameter, dict):
            continue
        merged.append(
            {
                "name": str(parameter.get("name") or ""),
                "in": str(parameter.get("in") or ""),
                "required": str(bool(parameter.get("required", False))).lower(),
                "schema": _schema_name(parameter.get("schema", {})),
            }
        )
    return sorted(merged, key=lambda value: (value["in"], value["name"]))


def _request_schema(request_body: Any) -> str:
    if not isinstance(request_body, dict):
        return ""
    content = request_body.get("content", {})
    if not isinstance(content, dict):
        return ""
    for content_type in sorted(content):
        media = content[content_type]
        if isinstance(media, dict):
            name = _schema_name(media.get("schema", {}))
            if name:
                return name
    return ""


def _response_schema(responses: Any) -> str:
    if not isinstance(responses, dict):
        return ""
    for status_code in _preferred_response_codes(responses):
        response = responses.get(status_code)
        if not isinstance(response, dict):
            continue
        content = response.get("content", {})
        if not isinstance(content, dict):
            continue
        for content_type in sorted(content):
            media = content[content_type]
            if isinstance(media, dict):
                name = _schema_name(media.get("schema", {}))
                if name:
                    return name
    return ""


def _preferred_response_codes(responses: dict[str, Any]) -> list[str]:
    codes = [str(code) for code in responses.keys()]
    success = sorted([code for code in codes if code.startswith("2")])
    default = sorted([code for code in codes if code == "default"])
    other = sorted([code for code in codes if code not in success and code != "default"])
    return success + default + other


def _schema_name(schema: Any) -> str:
    if not isinstance(schema, dict):
        return ""
    ref = schema.get("$ref")
    if isinstance(ref, str):
        return ref.rsplit("/", 1)[-1]
    schema_type = schema.get("type")
    if schema_type == "array":
        item = _schema_name(schema.get("items", {})) or "object"
        return f"array[{item}]"
    for composed in ("oneOf", "anyOf", "allOf"):
        items = schema.get(composed)
        if isinstance(items, list):
            names = stable_unique([_schema_name(item) for item in items])
            if names:
                return f"{composed}({', '.join(names)})"
    if schema_type == "object" and "additionalProperties" in schema:
        value = _schema_name(schema.get("additionalProperties", {})) or "object"
        return f"map[string,{value}]"
    return str(schema_type or "")


def _surface(path: str) -> str:
    normalized = normalize_path(path)
    if normalized.startswith("/api/") or normalized == "/api":
        return "REST API"
    if normalized.startswith("/actuator"):
        return "Actuator"
    if normalized.startswith("/v3/api-docs") or normalized.startswith("/swagger-ui"):
        return "API Docs"
    if normalized.startswith(("/css/", "/js/", "/img/", "/media/")):
        return "Static/Media"
    return "Web"


def _tag_from_path(path: str) -> str:
    pieces = [piece for piece in normalize_path(path).split("/") if piece]
    if not pieces:
        return "Home"
    if pieces[0] == "api" and len(pieces) > 1:
        return pieces[1].replace("-", " ").title()
    return pieces[0].replace("-", " ").title()


def _as_list(value: Any) -> list[Any]:
    return value if isinstance(value, list) else []

