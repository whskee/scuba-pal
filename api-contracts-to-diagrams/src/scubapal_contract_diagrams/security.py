from __future__ import annotations

import re


def classify_auth(method: str, path: str) -> dict[str, list[str] | str]:
    method = method.upper()
    normalized = _normalize_template(path)

    if method == "OPTIONS":
        return {"auth": "Public", "roles": []}

    if normalized.startswith("/api/"):
        return _api_auth(method, normalized)
    return _web_auth(method, normalized)


def _api_auth(method: str, path: str) -> dict[str, list[str] | str]:
    public_auth_paths = {
        "/api/auth/register",
        "/api/auth/login",
        "/api/auth/refresh",
        "/api/auth/logout",
        "/api/auth/username-available",
        "/api/auth/forgot-password",
        "/api/auth/reset-password",
    }
    if path in public_auth_paths:
        return {"auth": "Public", "roles": []}

    if path.startswith("/api/admin/") or path == "/api/admin":
        return {"auth": "Role", "roles": ["ADMIN"]}

    if method == "GET" and _matches_any(path, [
        "/api/learn/**",
        "/api/locations/**",
        "/api/shops/**",
        "/api/posts/**",
        "/api/profiles/**",
        "/api/users/*/profile",
        "/api/users/*/follow-summary",
        "/api/users/*/followers",
        "/api/users/*/following",
    ]):
        return {"auth": "Public", "roles": []}

    if _matches_any(path, ["/api/locations/**"]):
        return {"auth": "Role", "roles": ["ADMIN", "MODERATOR", "SHOP_OWNER"]}

    if _matches_any(path, ["/api/users/*/follow", "/api/messages/**", "/api/notifications/**", "/api/media/**", "/api/me/**", "/api/me"]):
        return {"auth": "Authenticated", "roles": []}

    if _matches_any(path, ["/api/posts/**", "/api/profiles/**"]):
        return {"auth": "Authenticated", "roles": []}

    if _matches_any(path, ["/api/users/**"]):
        return {"auth": "Role", "roles": ["ADMIN", "MODERATOR"]}

    return {"auth": "Authenticated", "roles": []}


def _web_auth(method: str, path: str) -> dict[str, list[str] | str]:
    if _matches_any(path, [
        "/",
        "/login",
        "/register",
        "/forgot-password",
        "/reset-password",
        "/feed",
        "/learn",
        "/locations",
        "/shops",
        "/divers",
        "/buddies",
        "/css/**",
        "/js/**",
        "/img/**",
        "/media/**",
        "/error",
        "/swagger-ui/**",
        "/swagger-ui.html",
        "/v3/api-docs/**",
        "/actuator/health/**",
        "/actuator/health",
        "/actuator/info",
    ]):
        return {"auth": "Public", "roles": []}

    if method == "GET" and _matches_any(path, ["/profile/**", "/posts/**"]):
        return {"auth": "Public", "roles": []}

    if method == "POST" and _matches_any(path, ["/posts/**", "/profile/*/follow", "/profile/*/unfollow"]):
        return {"auth": "Authenticated", "roles": []}

    return {"auth": "Authenticated", "roles": []}


def _normalize_template(path: str) -> str:
    return re.sub(r"\{[^/]+}", "*", path.rstrip("/") or "/")


def _matches_any(path: str, patterns: list[str]) -> bool:
    return any(_matches(path, pattern) for pattern in patterns)


def _matches(path: str, pattern: str) -> bool:
    if pattern.endswith("/**"):
        prefix = pattern[:-3]
        return path == prefix or path.startswith(prefix + "/")
    pattern_parts = [part for part in pattern.split("/") if part]
    path_parts = [part for part in path.split("/") if part]
    if len(pattern_parts) != len(path_parts):
        return False
    for pattern_part, path_part in zip(pattern_parts, path_parts):
        if pattern_part == "*":
            continue
        if pattern_part != path_part:
            return False
    return True

