#!/bin/bash

# echo "Starting post-install script for mtcli" > "$LOG_PATH"
# ARCH=$(uname -m)
# VERSION="1.0.2" # Replace with your actual version
# INSTALL_DIR="/usr/local/bin"
# SOURCE_DIR="/usr/local/bin" # Adjust this to the path where binaries are located inside the package
# LOG_FILE="/tmp/mtcli_postinstall.log"

# # Start logging
# touch "$LOG_FILE"
# echo "Starting post-install script for mtcli" > "$LOG_FILE"
# echo "Architecture detected: $ARCH" >> "$LOG_FILE"
# echo "Version: $VERSION" >> "$LOG_FILE"

# case "$ARCH" in
#     "arm64")
#         BINARY_NAME="mtcli_arm64"
#         ;;
#     "x86_64")
#         BINARY_NAME="mtcli_x86_64"
#         ;;
#     *)
#         echo "Unsupported architecture: $ARCH" >> "$LOG_FILE"
#         exit 1
#         ;;
# esac


# echo "Selected binary for installation: $BINARY_NAME" >> "$LOG_FILE"

# if mv "${SOURCE_DIR}/${BINARY_NAME}" "${INSTALL_DIR}/mtcli"; then
#     echo "Successfully moved ${BINARY_NAME} to ${INSTALL_DIR}/mtcli" >> "$LOG_FILE"
#     chmod +x "${INSTALL_DIR}/mtcli"
#     echo "Set execute permissions for ${INSTALL_DIR}/mtcli" >> "$LOG_FILE"
# else
#     echo "Error moving ${BINARY_NAME} to ${INSTALL_DIR}/mtcli" >> "$LOG_FILE"
#     exit 1
# fi

# # Optionally, clean up the other binary
# rm -f "${SOURCE_DIR}/mtcli_arm64" "${SOURCE_DIR}/mtcli_x86_64"