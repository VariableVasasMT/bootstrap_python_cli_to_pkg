#!/bin/bash

# The path to check and create if it doesn't exist
TARGET_PATH="$1"

if [ ! -d "$TARGET_PATH" ]; then
  echo "Path does not exist. Creating: $TARGET_PATH"
  mkdir -p "$TARGET_PATH"
else
  echo "Path already exists: $TARGET_PATH"
fi
