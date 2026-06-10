from __future__ import annotations

from collections import Counter, defaultdict
from typing import Any

from .util import dot_id, dot_label, mermaid_id, mermaid_label


def render_mermaid(routes: list[dict[str, Any]], *, include_non_api: bool = True) -> str:
    visible_routes = [route for route in routes if include_non_api or route.get("surface") == "REST API"]
    used_ids: set[str] = set()
    lines = [
        "flowchart LR",
        "    CLIENT((Client))",
        "    AUTH_PUBLIC[Public]",
        "    AUTH_AUTH[Authenticated]",
        "    AUTH_ROLE[Role gated]",
    ]

    by_surface: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for route in visible_routes:
        by_surface[str(route.get("surface") or "Other")].append(route)

    route_nodes: list[tuple[dict[str, Any], str]] = []
    for surface in sorted(by_surface):
        surface_id = mermaid_id("surface", surface, used_ids)
        lines.append(f'    subgraph {surface_id}["{mermaid_label(surface)}"]')
        by_tag: dict[str, list[dict[str, Any]]] = defaultdict(list)
        for route in by_surface[surface]:
            by_tag[str(route.get("tag") or _tag_from_route(route))].append(route)
        for tag in sorted(by_tag):
            tag_id = mermaid_id("tag", f"{surface}_{tag}", used_ids)
            lines.append(f'        subgraph {tag_id}["{mermaid_label(tag)}"]')
            for route in by_tag[tag]:
                label = f"{route.get('method')} {route.get('path')}"
                if route.get("operationId") or route.get("handler"):
                    label += f"<br/>{route.get('operationId') or route.get('handler')}"
                node_id = mermaid_id("route", label, used_ids)
                lines.append(f'            {node_id}["{mermaid_label(label)}"]')
                route_nodes.append((route, node_id))
            lines.append("        end")
        lines.append("    end")

    controller_nodes: dict[str, str] = {}
    table_nodes: dict[str, str] = {}
    for route, node_id in route_nodes:
        lines.append(f"    CLIENT --> {node_id}")
        auth = route.get("auth")
        if auth == "Public":
            lines.append(f"    {node_id} -.-> AUTH_PUBLIC")
        elif auth == "Role":
            lines.append(f"    {node_id} -.-> AUTH_ROLE")
        else:
            lines.append(f"    {node_id} -.-> AUTH_AUTH")

        controller = str(route.get("controller") or "")
        if controller:
            controller_id = controller_nodes.get(controller)
            if not controller_id:
                controller_id = mermaid_id("controller", controller, used_ids)
                controller_nodes[controller] = controller_id
                lines.append(f'    {controller_id}["{mermaid_label(controller)}"]')
            lines.append(f"    {node_id} --> {controller_id}")

        for table in route.get("tablesTouched", []):
            table_id = table_nodes.get(table)
            if not table_id:
                table_id = mermaid_id("table", table, used_ids)
                table_nodes[table] = table_id
                lines.append(f'    {table_id}["{mermaid_label(table)}"]')
            lines.append(f"    {node_id} -.-> {table_id}")

    lines.extend(
        [
            "    classDef public fill:#e8fff3,stroke:#087f5b,color:#0b3d2e",
            "    classDef auth fill:#fff4d6,stroke:#b7791f,color:#4a2a00",
            "    class AUTH_PUBLIC public",
            "    class AUTH_AUTH,AUTH_ROLE auth",
        ]
    )
    return "\n".join(lines) + "\n"


def render_dot(routes: list[dict[str, Any]]) -> str:
    lines = [
        "digraph ScubaPalRouteMap {",
        '  graph [rankdir="LR", bgcolor="transparent"];',
        '  node [shape="box", style="rounded,filled", fillcolor="white", color="#375a64", fontname="Helvetica"];',
        '  edge [color="#55727b"];',
        '  client [label="Client", shape="oval", fillcolor="#e8fff3"];',
    ]
    for route in routes:
        route_id = dot_id(f"{route.get('method')}_{route.get('path')}")
        label = f"{route.get('method')} {route.get('path')}"
        lines.append(f'  {route_id} [label="{dot_label(label)}"];')
        lines.append(f"  client -> {route_id};")
        controller = route.get("controller")
        if controller:
            controller_id = dot_id(str(controller))
            lines.append(f'  {controller_id} [label="{dot_label(str(controller))}", fillcolor="#eef7ff"];')
            lines.append(f"  {route_id} -> {controller_id};")
        for table in route.get("tablesTouched", []):
            table_id = dot_id(str(table))
            lines.append(f'  {table_id} [label="{dot_label(str(table))}", shape="cylinder", fillcolor="#f8f9fa"];')
            lines.append(f"  {route_id} -> {table_id} [style=dashed];")
    lines.append("}")
    return "\n".join(lines) + "\n"


def render_route_markdown(routes: list[dict[str, Any]], mermaid: str, collection: dict[str, Any]) -> str:
    counts = Counter(str(route.get("surface") or "Other") for route in routes)
    auth_counts = Counter(str(route.get("auth") or "Unknown") for route in routes)
    lines = [
        "---",
        "title: Generated Route Map",
        "description: Deterministic Scuba Pal route map generated from OpenAPI, Actuator, and controller source.",
        "tags: [api, automation, diagram]",
        "---",
        "",
        "# Generated Route Map",
        "",
        "This page is generated by `make routes-generate`. It combines the OpenAPI contract, Actuator mappings when available, and Java controller source as a deterministic route architecture index.",
        "",
        "## Source Health",
        "",
        "| Source | Status | Detail |",
        "| --- | --- | --- |",
    ]
    for source in collection.get("sources", []):
        lines.append(f"| {source['name']} | {source['status']} | {source['detail']} |")

    lines.extend(
        [
            "",
            "## Summary",
            "",
            f"- Total routes: {len(routes)}",
            f"- REST API routes: {counts.get('REST API', 0)}",
            f"- Web routes: {counts.get('Web', 0)}",
            f"- Static/media routes: {counts.get('Static/Media', 0)}",
            f"- Public routes: {auth_counts.get('Public', 0)}",
            f"- Authenticated routes: {auth_counts.get('Authenticated', 0)}",
            f"- Role-gated routes: {auth_counts.get('Role', 0)}",
            "",
            "## Diagram",
            "",
            "```mermaid",
            mermaid.rstrip(),
            "```",
            "",
            "## Route Architecture",
            "",
            "| Method | Path | Surface | Auth | Handler | Request | Response | Tables |",
            "| --- | --- | --- | --- | --- | --- | --- | --- |",
        ]
    )
    for route in routes:
        roles = ", ".join(route.get("roles", []))
        auth = str(route.get("auth") or "")
        if roles:
            auth = f"{auth}: {roles}"
        handler = _handler_label(route)
        lines.append(
            "| "
            + " | ".join(
                [
                    _cell(route.get("method")),
                    _code(route.get("path")),
                    _cell(route.get("surface")),
                    _cell(auth),
                    _cell(handler),
                    _cell(route.get("requestDto") or "-"),
                    _cell(route.get("responseDto") or "-"),
                    _cell(", ".join(route.get("tablesTouched", [])) or "-"),
                ]
            )
            + " |"
        )
    lines.append("")
    return "\n".join(lines)


def render_inventory_markdown(inventory: dict[str, Any]) -> str:
    counts = inventory.get("counts", {})
    project = inventory.get("project", {})
    lines = [
        "---",
        "title: Generated Scuba Pal Inventory",
        "description: Deterministic project inventory generated from README, OpenAPI, Java source, and database metadata.",
        "tags: [api, automation]",
        "---",
        "",
        "# Generated Scuba Pal Inventory",
        "",
        str(project.get("description") or "Scuba Pal project inventory."),
        "",
        "## Counts",
        "",
        "| Area | Count |",
        "| --- | ---: |",
    ]
    for key in sorted(counts):
        lines.append(f"| {key} | {counts[key]} |")

    lines.extend(["", "## README Features", ""])
    for feature in project.get("features", []):
        lines.append(f"- {feature}")

    lines.extend(["", "## OpenAPI Tags", "", "| Tag | Description |", "| --- | --- |"])
    for tag in inventory.get("openapi", {}).get("tags", []):
        lines.append(f"| {_cell(tag.get('name'))} | {_cell(tag.get('description'))} |")

    lines.extend(["", "## Database Tables", "", "| Schema | Table |", "| --- | --- |"])
    for table in inventory.get("database", {}).get("tables", []):
        lines.append(f"| {_cell(table.get('schema'))} | {_cell(table.get('name'))} |")

    lines.append("")
    return "\n".join(lines)


def _handler_label(route: dict[str, Any]) -> str:
    controller = str(route.get("controller") or "")
    handler = str(route.get("handler") or route.get("operationId") or "")
    if controller and handler:
        return f"{controller}.{handler}"
    return controller or handler or "-"


def _tag_from_route(route: dict[str, Any]) -> str:
    path = str(route.get("path") or "")
    pieces = [piece for piece in path.split("/") if piece]
    if len(pieces) > 1 and pieces[0] == "api":
        return pieces[1].replace("-", " ").title()
    if pieces:
        return pieces[0].replace("-", " ").title()
    return "Home"


def _cell(value: Any) -> str:
    text = str(value if value is not None else "")
    return text.replace("|", "\\|").replace("\n", " ").strip()


def _code(value: Any) -> str:
    return "`" + _cell(value) + "`"
