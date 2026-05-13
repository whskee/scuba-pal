#!/bin/bash

# Name of the project folder
PROJECT_NAME="scuba-pal-mobile-expo"

# Timestamped zip name
ZIP_NAME="${PROJECT_NAME}-for-chatgpt-$(date +%Y%m%d-%H%M%S).zip"

echo "Creating $ZIP_NAME..."

zip -r "$ZIP_NAME" . \
  -x "node_modules/*" \
  -x ".expo/*" \
  -x ".git/*" \
  -x "*.zip" \
  -x "dist/*" \
  -x "build/*" \
  -x ".DS_Store" \
  -x "**/.DS_Store" \
  -x "npm-debug.log" \
  -x "yarn-error.log" \
  -x ".env" \
  -x ".env.*"

echo "Done."
echo "Created: $ZIP_NAME"