
```bash
cbidkar at Chinmayas-MacBook-Pro in ~ 
-> ICON_DIR="$HOME/.vscode/extensions/icons"              

mkdir -p "$ICON_DIR"

make_folder_icon() {
  name="$1"
  emoji="$2"

  cat > "$ICON_DIR/folder-$name.svg" <<EOF
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
EOF

  cp "$ICON_DIR/folder-$name.svg" "$ICON_DIR/folder-$name-open.svg"
}

make_folder_icon "api" "🔌"
make_folder_icon "data" "🗄️"
make_folder_icon "mobile" "📱"
make_folder_icon "docs" "📚"
make_folder_icon "diagrams" "<0001f9ed>"
make_folder_icon "screenshots" "🖼️"
make_folder_icon "identity" "🔐"
make_folder_icon "auth" "🔑"
make_folder_icon "security" "🛡️"
make_folder_icon "blog" "✍️"
cbidkar at Chinmayas-MacBook-Pro in ~ 
-> open "$HOME/Library/Application Support/Code/User/settings.json"
```






---


```bash
ICON_DIR="$HOME/.vscode/extensions/icons"              

mkdir -p "$ICON_DIR"

make_folder_icon() {
  name="$1"
  emoji="$2"

  cat > "$ICON_DIR/folder-$name.svg" <<EOF
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
EOF

  cp "$ICON_DIR/folder-$name.svg" "$ICON_DIR/folder-$name-open.svg"
}

make_folder_icon "api" "🔌"
make_folder_icon "data" "🗄️"
make_folder_icon "mobile" "📱"
make_folder_icon "docs" "📚"
make_folder_icon "diagrams" "<0001f9ed>"
make_folder_icon "screenshots" "🖼️"
make_folder_icon "identity" "🔐"
make_folder_icon "auth" "🔑"
make_folder_icon "security" "🛡️"
make_folder_icon "blog" "✍️"
```


ICON_DIR="$HOME/.vscode/extensions/icons"              

mkdir -p "$ICON_DIR"

make_folder_icon() {
  name="$1"
  emoji="$2"

  cat > "$ICON_DIR/folder-$name.svg" <<EOF
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
EOF

  cp "$ICON_DIR/folder-$name.svg" "$ICON_DIR/folder-$name-open.svg"
}

make_folder_icon "mail" "✉️"
```
