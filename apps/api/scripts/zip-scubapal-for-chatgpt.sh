#!/bin/bash

set -e

# Output zip name
ZIP_NAME="scubapal.zip"

# Source project folders
ROOT_DIR="scubapal"
BACKEND_DIR="$ROOT_DIR/scuba-pal-app"
MOBILE_FRONTEND_DIR="$ROOT_DIR/scuba-pal-mobile-expo"

# Temporary clean export folder
TMP_DIR="scubapal-chatgpt-export"

# Remove old zip/export if they exist
rm -rf "$TMP_DIR"
rm -f "$ZIP_NAME"

# Create final folder structure
mkdir -p "$TMP_DIR/scuba-pal-app"
mkdir -p "$TMP_DIR/scuba-pal-mobile-expo"

# =========================
# scuba-pal-app files
# =========================

cp -R "$BACKEND_DIR/src" "$TMP_DIR/scuba-pal-app/"

for file in pom.xml mvnw mvnw.cmd docker-compose.yml; do
  if [ -f "$BACKEND_DIR/$file" ]; then
    cp "$BACKEND_DIR/$file" "$TMP_DIR/scuba-pal-app/"
  fi
done

# =========================
# scuba-pal-mobile-expo files
# =========================

cp -R "$MOBILE_FRONTEND_DIR/src" "$TMP_DIR/scuba-pal-mobile-expo/"

for file in app.json App.tsx package-lock.json package.json tsconfig.json .env.local; do
  if [ -f "$MOBILE_FRONTEND_DIR/$file" ]; then
    cp "$MOBILE_FRONTEND_DIR/$file" "$TMP_DIR/scuba-pal-mobile-expo/"
  fi
done

# Create the zip
cd "$TMP_DIR"
zip -r "../$ZIP_NAME" .
cd ..

# Clean up temp folder
rm -rf "$TMP_DIR"

echo "Created $ZIP_NAME"
echo "Zip contains only:"
echo "  scuba-pal-app/"
echo "  scuba-pal-mobile-expo/"