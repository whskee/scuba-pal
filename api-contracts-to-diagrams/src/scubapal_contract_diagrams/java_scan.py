from __future__ import annotations

import re
from pathlib import Path
from typing import Any

from .util import join_paths, normalize_path, relpath, stable_unique


METHOD_BY_ANNOTATION = {
    "GetMapping": ["GET"],
    "PostMapping": ["POST"],
    "PutMapping": ["PUT"],
    "PatchMapping": ["PATCH"],
    "DeleteMapping": ["DELETE"],
}

CLASS_RE = re.compile(r"\b(class|interface|record|enum)\s+([A-Za-z_][A-Za-z0-9_]*)")
MAPPING_START_RE = re.compile(r"@(GetMapping|PostMapping|PutMapping|PatchMapping|DeleteMapping|RequestMapping)\b")
REQUEST_METHOD_RE = re.compile(r"RequestMethod\.([A-Z]+)")
QUOTED_RE = re.compile(r'"([^"]*)"')
TABLE_RE = re.compile(r'@Table\s*\((?P<body>.*?)\)', re.DOTALL)
SCHEMA_RE = re.compile(r'schema\s*=\s*"([^"]+)"')
NAME_RE = re.compile(r'name\s*=\s*"([^"]+)"')
REPO_ENTITY_RE = re.compile(r"extends\s+[A-Za-z0-9_<>.,\s]*Repository\s*<\s*([A-Za-z0-9_]+)\s*,")


def scan_java_project(repo_root: Path) -> dict[str, Any]:
    source_root = repo_root / "scubapal-app" / "src" / "main" / "java" / "com" / "scubapal"
    if not source_root.exists():
        return {
            "controllers": [],
            "routes": [],
            "entities": [],
            "repositories": [],
            "services": [],
            "tablesByController": {},
            "eventsByController": {},
        }

    java_files = sorted(source_root.rglob("*.java"))
    entities = _scan_entities(java_files, repo_root)
    repositories = _scan_repositories(java_files, entities)
    services = _scan_named_files(java_files, "Service", repo_root)
    controller_records = _scan_controllers(java_files, repo_root)

    repository_tables = {repo["className"]: repo.get("table", "") for repo in repositories}
    services_by_name = {service["className"]: service for service in services}
    source_by_name = {record["className"]: record["text"] for record in _source_records(java_files)}

    tables_by_controller: dict[str, list[str]] = {}
    events_by_controller: dict[str, list[str]] = {}
    for controller in controller_records["controllers"]:
        class_name = controller["className"]
        text = source_by_name.get(class_name, "")
        dependencies = _dependency_names(text)
        tables = []
        events = _events(text)
        for dependency in dependencies:
            table = repository_tables.get(dependency)
            if table:
                tables.append(table)
            if dependency in services_by_name:
                service_text = source_by_name.get(dependency, "")
                events.extend(_events(service_text))
                for repo_name in _dependency_names(service_text):
                    table = repository_tables.get(repo_name)
                    if table:
                        tables.append(table)
        tables_by_controller[class_name] = stable_unique(tables)
        events_by_controller[class_name] = stable_unique(events)

    return {
        "controllers": [
            {key: value for key, value in controller.items() if key != "text"}
            for controller in controller_records["controllers"]
        ],
        "routes": controller_records["routes"],
        "entities": entities,
        "repositories": repositories,
        "services": services,
        "tablesByController": tables_by_controller,
        "eventsByController": events_by_controller,
    }


def _source_records(java_files: list[Path]) -> list[dict[str, str]]:
    records = []
    for path in java_files:
        text = path.read_text(encoding="utf-8")
        class_name = _class_name(text)
        if class_name:
            records.append({"className": class_name, "text": text})
    return records


def _scan_controllers(java_files: list[Path], repo_root: Path) -> dict[str, Any]:
    controllers = []
    routes = []
    for path in java_files:
        if not path.name.endswith("Controller.java"):
            continue
        text = path.read_text(encoding="utf-8")
        route_text = _strip_java_comments(text)
        class_name = _class_name(route_text) or path.stem
        class_mapping = _class_mapping(route_text)
        source_file = relpath(path, repo_root)
        controller = {
            "className": class_name,
            "sourceFile": source_file,
            "basePath": class_mapping,
            "text": text,
        }
        controllers.append(controller)
        for mapping in _method_mappings(route_text):
            for suffix in mapping["paths"]:
                for method in mapping["methods"]:
                    routes.append(
                        {
                            "method": method,
                            "path": join_paths(class_mapping, suffix),
                            "surface": _surface(join_paths(class_mapping, suffix)),
                            "controller": class_name,
                            "handler": mapping["handler"],
                            "sourceFile": source_file,
                            "source": "java",
                        }
                    )
    return {
        "controllers": sorted(controllers, key=lambda value: value["className"]),
        "routes": sorted(_dedupe_routes(routes), key=lambda value: (value["path"], value["method"], value["controller"], value["handler"])),
    }


def _scan_entities(java_files: list[Path], repo_root: Path) -> list[dict[str, str]]:
    entities = []
    for path in java_files:
        text = path.read_text(encoding="utf-8")
        if "@Entity" not in text:
            continue
        class_name = _class_name(text) or path.stem
        table_match = TABLE_RE.search(text)
        schema = ""
        table = ""
        if table_match:
            body = table_match.group("body")
            schema_match = SCHEMA_RE.search(body)
            name_match = NAME_RE.search(body)
            schema = schema_match.group(1) if schema_match else ""
            table = name_match.group(1) if name_match else ""
        qualified = f"{schema}.{table}" if schema and table else table
        entities.append(
            {
                "className": class_name,
                "table": qualified,
                "sourceFile": relpath(path, repo_root),
            }
        )
    return sorted(entities, key=lambda value: value["className"])


def _scan_repositories(java_files: list[Path], entities: list[dict[str, str]]) -> list[dict[str, str]]:
    tables_by_entity = {entity["className"]: entity.get("table", "") for entity in entities}
    repositories = []
    for path in java_files:
        if not path.name.endswith("Repository.java"):
            continue
        text = path.read_text(encoding="utf-8")
        class_name = _class_name(text) or path.stem
        entity = ""
        match = REPO_ENTITY_RE.search(text)
        if match:
            entity = match.group(1)
        repositories.append(
            {
                "className": class_name,
                "entity": entity,
                "table": tables_by_entity.get(entity, ""),
            }
        )
    return sorted(repositories, key=lambda value: value["className"])


def _scan_named_files(java_files: list[Path], suffix: str, repo_root: Path) -> list[dict[str, str]]:
    records = []
    for path in java_files:
        if not path.name.endswith(f"{suffix}.java"):
            continue
        text = path.read_text(encoding="utf-8")
        class_name = _class_name(text) or path.stem
        records.append({"className": class_name, "sourceFile": relpath(path, repo_root)})
    return sorted(records, key=lambda value: value["className"])


def _class_mapping(text: str) -> str:
    class_index = text.find("class ")
    if class_index == -1:
        class_index = len(text)
    prefix_text = text[:class_index]
    mappings = _annotation_blocks(prefix_text)
    for annotation_name, body in reversed(mappings):
        if annotation_name == "RequestMapping":
            paths = _paths_from_body(body)
            return normalize_path(paths[0]) if paths else ""
    return ""


def _method_mappings(text: str) -> list[dict[str, Any]]:
    lines = text.splitlines()
    mappings = []
    pending: list[tuple[str, str]] = []
    index = 0
    while index < len(lines):
        line = lines[index].strip()
        if MAPPING_START_RE.search(line):
            block_lines = [line]
            open_parens = line.count("(") - line.count(")")
            while open_parens > 0 and index + 1 < len(lines):
                index += 1
                next_line = lines[index].strip()
                block_lines.append(next_line)
                open_parens += next_line.count("(") - next_line.count(")")
            block = " ".join(block_lines)
            name_match = MAPPING_START_RE.search(block)
            if name_match:
                annotation = name_match.group(1)
                body = _body(block)
                pending.append((annotation, body))
        elif pending and _looks_like_method_signature(line):
            handler = _method_name(line)
            for annotation, body in pending:
                methods = METHOD_BY_ANNOTATION.get(annotation) or _methods_from_request_mapping(body)
                paths = _paths_from_body(body)
                if not paths:
                    paths = [""]
                if not methods:
                    methods = ["ANY"]
                mappings.append({"methods": methods, "paths": paths, "handler": handler})
            pending = []
        elif line and not line.startswith("@"):
            if pending and (";" in line or line.startswith(("private final", "final "))):
                pending = []
        index += 1
    return mappings


def _annotation_blocks(text: str) -> list[tuple[str, str]]:
    blocks = []
    for match in MAPPING_START_RE.finditer(text):
        annotation = match.group(1)
        start = match.end()
        body = ""
        if start < len(text) and text[start] == "(":
            depth = 0
            for index in range(start, len(text)):
                char = text[index]
                if char == "(":
                    depth += 1
                    if depth == 1:
                        continue
                elif char == ")":
                    depth -= 1
                    if depth == 0:
                        body = text[start + 1:index]
                        break
        blocks.append((annotation, body))
    return blocks


def _body(annotation_line: str) -> str:
    start = annotation_line.find("(")
    end = annotation_line.rfind(")")
    if start == -1 or end == -1 or end <= start:
        return ""
    return annotation_line[start + 1:end]


def _paths_from_body(body: str) -> list[str]:
    if not body:
        return [""]
    paths = [value for value in QUOTED_RE.findall(body) if value == "" or value.startswith("/")]
    return paths or [""]


def _methods_from_request_mapping(body: str) -> list[str]:
    return sorted(set(REQUEST_METHOD_RE.findall(body)))


def _class_name(text: str) -> str:
    match = CLASS_RE.search(text)
    return match.group(2) if match else ""


def _strip_java_comments(text: str) -> str:
    without_blocks = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    return "\n".join(line.split("//", 1)[0] for line in without_blocks.splitlines())


def _looks_like_method_signature(line: str) -> bool:
    return bool(re.search(r"\b(public|private|protected)\b", line) and re.search(r"[A-Za-z_][A-Za-z0-9_]*\s*\(", line))


def _method_name(line: str) -> str:
    match = re.search(r"([A-Za-z_][A-Za-z0-9_]*)\s*\(", line)
    return match.group(1) if match else ""


def _dependency_names(text: str) -> list[str]:
    return stable_unique(re.findall(r"\b([A-Za-z0-9_]+(?:Repository|Service))\b", text))


def _events(text: str) -> list[str]:
    events = re.findall(r"publishEvent\s*\(\s*new\s+([A-Za-z0-9_]+)", text)
    events.extend(re.findall(r"\b([A-Za-z0-9_]+Event)\b", text) if "ApplicationEventPublisher" in text else [])
    return stable_unique(events)


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


def _dedupe_routes(routes: list[dict[str, str]]) -> list[dict[str, str]]:
    seen = set()
    deduped = []
    for route in routes:
        key = (route["method"], route["path"], route["controller"], route["handler"])
        if key in seen:
            continue
        seen.add(key)
        deduped.append(route)
    return deduped
