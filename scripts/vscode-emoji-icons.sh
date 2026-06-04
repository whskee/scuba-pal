#!/usr/bin/env bash
set -euo pipefail

ICON_DIR="$HOME/.vscode/extensions/icons"

mkdir -p "$ICON_DIR"

make_icon() {
  local name="$1"
  local emoji="$2"

  cat > "$ICON_DIR/folder-$name.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <text
    x="32"
    y="36"
    text-anchor="middle"
    dominant-baseline="middle"
    font-size="42"
    font-family="Apple Color Emoji, Segoe UI Emoji, Noto Color Emoji, sans-serif"
  >$emoji</text>
</svg>
SVG

  cp "$ICON_DIR/folder-$name.svg" "$ICON_DIR/folder-$name-open.svg"
}

make_icon "src" "🧬"
make_icon "source" "🧬"
make_icon "app" "🚀"
make_icon "api" "🔌"
make_icon "apis" "🔌"

make_icon "frontend" "🎨"
make_icon "backend" "⚙️"
make_icon "client" "🖥️"
make_icon "server" "🖧"
make_icon "web" "🌐"
make_icon "website" "🌐"

make_icon "mobile" "📱"
make_icon "ios" "🍎"
make_icon "android" "🤖"

make_icon "java" "☕"
make_icon "python" "🐍"
make_icon "javascript" "🟨"
make_icon "js" "🟨"
make_icon "typescript" "🔷"
make_icon "ts" "🔷"
make_icon "html" "🌐"
make_icon "css" "🎨"

make_icon "data" "🗄️"
make_icon "database" "🗄️"
make_icon "db" "🗄️"
make_icon "sql" "🧾"
make_icon "migrations" "🧱"
make_icon "seed" "🌱"
make_icon "seeds" "🌱"

make_icon "docs" "📚"
make_icon "documentation" "📚"
make_icon "blog" "✍️"
make_icon "notes" "📝"
make_icon "ideas" "💡"
make_icon "research" "🔬"

make_icon "diagrams" "🧭"
make_icon "uml" "🧩"
make_icon "puml" "🧩"
make_icon "screenshots" "🖼️"
make_icon "images" "🖼️"
make_icon "assets" "📦"
make_icon "media" "🎞️"
make_icon "static" "🪨"
make_icon "public" "🏛️"

make_icon "identity" "🔐"
make_icon "auth" "🔑"
make_icon "security" "🛡️"

make_icon "controllers" "🎮"
make_icon "controller" "🎮"
make_icon "services" "🧠"
make_icon "service" "🧠"
make_icon "repositories" "🗃️"
make_icon "repository" "🗃️"
make_icon "dto" "📨"
make_icon "dtos" "📨"
make_icon "requests" "📥"
make_icon "responses" "📤"
make_icon "models" "🧱"
make_icon "model" "🧱"
make_icon "entities" "🧬"
make_icon "entity" "🧬"
make_icon "domain" "🏰"
make_icon "mapper" "🔁"
make_icon "mappers" "🔁"

make_icon "config" "⚙️"
make_icon "configuration" "⚙️"
make_icon "settings" "🎛️"
make_icon "scripts" "📜"
make_icon "tools" "🧰"
make_icon "bin" "🛠️"

make_icon "test" "🧪"
make_icon "tests" "🧪"
make_icon "spec" "✅"
make_icon "specs" "✅"

make_icon "docker" "🐳"
make_icon "infra" "🏗️"
make_icon "infrastructure" "🏗️"
make_icon "k8s" "☸️"
make_icon "kubernetes" "☸️"
make_icon "aws" "☁️"
make_icon "cloud" "☁️"

make_icon "github" "🐙"
make_icon "workflows" "🔄"
make_icon "ci" "🔄"
make_icon "cd" "🚢"

make_icon "build" "🏗️"
make_icon "target" "🎯"
make_icon "dist" "📦"
make_icon "out" "📤"

echo "Created emoji folder icons in:"
echo "$ICON_DIR"
echo
echo "Add this to VS Code User Settings JSON if using Material Icon Theme:"
echo
cat <<'JSON'
{
  "workbench.iconTheme": "material-icon-theme",
  "material-icon-theme.folders.theme": "specific",
  "material-icon-theme.folders.associations": {
    "src": "../../../../icons/folder-src",
    "source": "../../../../icons/folder-source",
    "app": "../../../../icons/folder-app",
    "api": "../../../../icons/folder-api",
    "apis": "../../../../icons/folder-apis",

    "frontend": "../../../../icons/folder-frontend",
    "backend": "../../../../icons/folder-backend",
    "client": "../../../../icons/folder-client",
    "server": "../../../../icons/folder-server",
    "web": "../../../../icons/folder-web",
    "website": "../../../../icons/folder-website",

    "mobile": "../../../../icons/folder-mobile",
    "ios": "../../../../icons/folder-ios",
    "android": "../../../../icons/folder-android",

    "java": "../../../../icons/folder-java",
    "python": "../../../../icons/folder-python",
    "javascript": "../../../../icons/folder-javascript",
    "js": "../../../../icons/folder-js",
    "typescript": "../../../../icons/folder-typescript",
    "ts": "../../../../icons/folder-ts",
    "html": "../../../../icons/folder-html",
    "css": "../../../../icons/folder-css",

    "data": "../../../../icons/folder-data",
    "database": "../../../../icons/folder-database",
    "db": "../../../../icons/folder-db",
    "sql": "../../../../icons/folder-sql",
    "migrations": "../../../../icons/folder-migrations",
    "seed": "../../../../icons/folder-seed",
    "seeds": "../../../../icons/folder-seeds",

    "docs": "../../../../icons/folder-docs",
    "documentation": "../../../../icons/folder-documentation",
    "blog": "../../../../icons/folder-blog",
    "notes": "../../../../icons/folder-notes",
    "ideas": "../../../../icons/folder-ideas",
    "research": "../../../../icons/folder-research",

    "diagrams": "../../../../icons/folder-diagrams",
    "uml": "../../../../icons/folder-uml",
    "puml": "../../../../icons/folder-puml",
    "screenshots": "../../../../icons/folder-screenshots",
    "images": "../../../../icons/folder-images",
    "assets": "../../../../icons/folder-assets",
    "media": "../../../../icons/folder-media",
    "static": "../../../../icons/folder-static",
    "public": "../../../../icons/folder-public",

    "identity": "../../../../icons/folder-identity",
    "auth": "../../../../icons/folder-auth",
    "security": "../../../../icons/folder-security",

    "controllers": "../../../../icons/folder-controllers",
    "controller": "../../../../icons/folder-controller",
    "services": "../../../../icons/folder-services",
    "service": "../../../../icons/folder-service",
    "repositories": "../../../../icons/folder-repositories",
    "repository": "../../../../icons/folder-repository",
    "dto": "../../../../icons/folder-dto",
    "dtos": "../../../../icons/folder-dtos",
    "requests": "../../../../icons/folder-requests",
    "responses": "../../../../icons/folder-responses",
    "models": "../../../../icons/folder-models",
    "model": "../../../../icons/folder-model",
    "entities": "../../../../icons/folder-entities",
    "entity": "../../../../icons/folder-entity",
    "domain": "../../../../icons/folder-domain",
    "mapper": "../../../../icons/folder-mapper",
    "mappers": "../../../../icons/folder-mappers",

    "config": "../../../../icons/folder-config",
    "configuration": "../../../../icons/folder-configuration",
    "settings": "../../../../icons/folder-settings",
    "scripts": "../../../../icons/folder-scripts",
    "tools": "../../../../icons/folder-tools",
    "bin": "../../../../icons/folder-bin",

    "test": "../../../../icons/folder-test",
    "tests": "../../../../icons/folder-tests",
    "spec": "../../../../icons/folder-spec",
    "specs": "../../../../icons/folder-specs",

    "docker": "../../../../icons/folder-docker",
    "infra": "../../../../icons/folder-infra",
    "infrastructure": "../../../../icons/folder-infrastructure",
    "k8s": "../../../../icons/folder-k8s",
    "kubernetes": "../../../../icons/folder-kubernetes",
    "aws": "../../../../icons/folder-aws",
    "cloud": "../../../../icons/folder-cloud",

    "github": "../../../../icons/folder-github",
    "workflows": "../../../../icons/folder-workflows",
    "ci": "../../../../icons/folder-ci",
    "cd": "../../../../icons/folder-cd",

    "build": "../../../../icons/folder-build",
    "target": "../../../../icons/folder-target",
    "dist": "../../../../icons/folder-dist",
    "out": "../../../../icons/folder-out"
  }
}
JSON
