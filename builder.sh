#!/bin/bash

# Define variables
# This script defines variables related to the build process of the "mtcli" application.
# - APP_NAME: The name of the application.
# - VERSION: The version number of the application.
# - ENTRY_SCRIPT: The entry script file for the application.
# - DATA_DIR: The directory containing the application's data files.
# - VERSION_FILE: The file to store the version number.
# - DIST_DIR: The directory to store the distribution files.
# - BUILD_DIR: The directory to store the build files.
# - STAGING_DIR: The directory for staging the DMG file.
# - DMG_NAME: The name of the DMG file.
# - IDENTIFIER: The identifier for the application.
# - PKG_DIR: The directory for packaging the application.
# - MACOS_ARCH: The architecture for macOS.

APP_NAME="mtcli"
VERSION="1.0.3"
ENTRY_SCRIPT="bootstrap_cli/cli.py"
DATA_DIR="bootstrap_cli/templates"
VERSION_FILE="version.txt"
DIST_DIR="dist"
BUILD_DIR="build"
STAGING_DIR="/tmp/${APP_NAME}_dmg_staging"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
IDENTIFIER="com.mindtickle.${APP_NAME}"
PKG_DIR="/tmp/${APP_NAME}_pkg_${VERSION}"
MACOS_ARCH="universal2"

rm -rf ${DIST_DIR} ${BUILD_DIR} ${STAGING_DIR} ${PKG_DIR}
# Ensure directories exist
mkdir -p "${DIST_DIR}" "${BUILD_DIR}" "${PKG_DIR}" "${STAGING_DIR}"

# Create a version file for Windows (optional)
echo "Creating version file..."
cat > $VERSION_FILE << EOF
VSVersionInfo(
  ffi=FixedFileInfo(
    filevers=($VERSION),
    prodvers=($VERSION),
    mask=0x3f,
    flags=0x0,
    OS=0x4,
    fileType=0x1,
    subtype=0x0,
    date=(0, 0)
    ),
  kids=[
    StringFileInfo(
      [
      StringTable(
        '040904B0',
        [StringStruct('CompanyName', 'Your Company'),
        StringStruct('FileDescription', 'Your Application Description'),
        StringStruct('FileVersion', '$VERSION'),
        StringStruct('InternalName', '$APP_NAME'),
        StringStruct('OriginalFilename', '$APP_NAME.exe'),
        StringStruct('ProductName', 'Your Product Name'),
        StringStruct('ProductVersion', '$VERSION')])
      ]),
    VarFileInfo([VarStruct('Translation', [0x0409, 0x04B0])])
  ]
)
EOF


# Function to build the application for a specific architecture
# Parameters:
#   - arch: The target architecture (e.g., arm64, x86_64)
#   - spec_file: The name of the spec file for the architecture
# Description:
#   This function builds the application for the specified architecture using PyInstaller.
#   It installs the required packages, executes PyInstaller with the appropriate command,
#   and determines the output path based on the .spec configuration.
#   For arm64 architecture, it activates the arm64-python3.9 conda environment before building.
#   After the build, it deactivates the conda environment if the architecture is arm64.
#   Note: This function assumes the existence of a requirements.txt file, an entry script,
#   and a version file.
build_for_arch() {
    local arch=$1
    local spec_file="${APP_NAME}_${arch}.spec"
    
    # Check if the architecture is arm64
    if [ "$arch" == "arm64" ]; then
        whoami
        conda env list
        conda activate arm64-python3.9
        which python3
        
        pip install pyinstaller
    fi
    
    echo "================================================================================="
    echo "Building $APP_NAME version $VERSION for $arch using $spec_file..."
    echo "================================================================================="

    # Check if the spec file exists
    if [[ ! -f "$spec_file" ]]; then
        echo "Spec file $spec_file does not exist."
        exit 1
    fi

    # Determine the correct Python and PyInstaller command based on architecture
    local pyinstaller_cmd="pyinstaller"
    local pip_cmd="pip3"
    echo "python3 arch being referred: which python $(which python3), $(which python),python arch = $(lipo -archs $(which python3)) , pip arch = $(lipo -archs $(which pip3))"
    if [ "$arch" == "x86_64" ]; then
        # Use the x86_64 Python and PyInstaller under Rosetta 2
        # Ensure
        suitable environment or the path is adjusted for x86_64 Python
        pyinstaller_cmd="arch -x86_64 /usr/local/bin/$pyinstaller_cmd"
        pip_cmd="arch -x86_64 /usr/local/bin/pip3"
        echo "arch seeked is $arch, python arch should be used: $(lipo -archs /usr/local/bin/python3)"
        echo "pyinstaller arch should be used: $(which pyinstaller)"
    else
        echo "python arch should be used: $(lipo -archs $(which python3))"
        echo "pyinstaller arch should be used: $(which pyinstaller)"
    fi
    
    # Install the required packages
    $pip_cmd install --force-reinstall -r requirements.txt 
        # Execute PyInstaller with the appropriate command
    $pyinstaller_cmd --onefile --name="${APP_NAME}_${arch}" \
        --add-data="$DATA_DIR:templates" \
        --target-architecture="$arch" \
        --log-level=INFO \
        --hidden-import=openai \
        --hidden-import=requests \
        --hidden-import=dotenv \
        --hidden-import=jinja2 \
        --hidden-import=gitlab \
        --version-file="$VERSION_FILE" "$ENTRY_SCRIPT" || { echo "PyInstaller build failed for $arch"; exit 1; }

    # Determine the output path based on your .spec configuration
    # This example assumes output is directly under `dist/${APP_NAME}`
    local output_path="dist/${APP_NAME}_${arch}"
    ls -lR "dist"
    ls -lr $output_path
    
    # Check if the architecture is arm64
    if [ "$arch" == "arm64" ]; then
        conda env list
        conda deactivate
    fi
}

# Build for arm64
MACOS_ARCH="arm64"
build_for_arch $MACOS_ARCH

# Build for x86_64
MACOS_ARCH="x86_64"
build_for_arch $MACOS_ARCH


# Cleanup (optional)
echo "Cleaning up version file..."
rm $VERSION_FILE

# Define script directory for pkgbuild
SCRIPT_DIR="${PKG_DIR}/scripts"
mkdir -p "${SCRIPT_DIR}"

# Move the executable to the PKG staging directory
BIN_DIR="${PKG_DIR}"
mkdir -p "${BIN_DIR}"

# Copy architecture-specific executables to the PKG staging directory
cp "${DIST_DIR}/${APP_NAME}_arm64" "${BIN_DIR}/"
cp "${DIST_DIR}/${APP_NAME}_x86_64" "${BIN_DIR}/"

echo "================= CHECK BINARY ================"
mtcli_arm64="${DIST_DIR}/${APP_NAME}_arm64"
mtcli_x86_64="${DIST_DIR}/${APP_NAME}_x86_64"
echo "Paths: $mtcli_arm64 $mtcli_x86_64"
chmod +x "${mtcli_arm64}" "${mtcli_x86_64}"

echo "<<<<<<<<<<<<<<<<<<<< EXEC BINARY ARM64 >>>>>>>>>>>>>>>>>>>>"
$mtcli_arm64
echo ">>>>>>>>>>>>>>>>>>>> EXEC BINARY ARM64 <<<<<<<<<<<<<<<<<<<<"
echo "<<<<<<<<<<<<<<<<<<<< EXEC BINARY x86_64 >>>>>>>>>>>>>>>>>>>>"
$mtcli_x86_64
echo ">>>>>>>>>>>>>>>>>>>> EXEC BINARY x86_64 <<<<<<<<<<<<<<<<<<<<"

echo "================= CHECK BINARY ================"

ls -l "${BIN_DIR}"
LOG_PATH="/tmp/${APP_NAME}_postinstall.log"
# Create post-install script
echo "Creating post-install script in ${SCRIPT_DIR}..."


# This script is a post-installation script that moves a binary file to the specified installation directory.
# It detects the architecture of the system and selects the appropriate binary file based on the architecture.
# The selected binary file is then moved to the installation directory and given execute permissions.
# Optionally, it can also clean up other binary files.
# The script logs its progress and any errors to a specified log file.
cat > "${SCRIPT_DIR}/postinstall" <<EOF
#!/bin/bash

echo "Starting post-install script for $APP_NAME"
ARCH=\$(uname -m)
VERSION="$VERSION" # Replace with your actual version
INSTALL_DIR="/usr/local/bin"
SOURCE_DIR="/usr/local/bin" # Adjust this to the path where binaries are located inside the package
LOG_FILE="$LOG_PATH"

# Start logging
touch "\$LOG_FILE"
echo "Starting post-install script for $APP_NAME" > "\$LOG_FILE"
echo "Architecture detected: \$ARCH" >> "\$LOG_FILE"
echo "Version: \$VERSION" >> "\$LOG_FILE"

case "\$ARCH" in
    "arm64")
        BINARY_NAME="${APP_NAME}_arm64"
        ;;
    "x86_64")
        BINARY_NAME="${APP_NAME}_x86_64"
        ;;
    *)
        echo "Unsupported architecture: \$ARCH" >> "\$LOG_FILE"
        exit 1
        ;;
esac


echo "Selected binary for installation: \$BINARY_NAME" >> "\$LOG_FILE"

if mv "\${SOURCE_DIR}/\${BINARY_NAME}" "\${INSTALL_DIR}/${APP_NAME}"; then
    echo "Successfully moved \${BINARY_NAME} to \${INSTALL_DIR}/${APP_NAME}" >> "\$LOG_FILE"
    chmod +x "\${INSTALL_DIR}/${APP_NAME}"
    echo "Set execute permissions for \${INSTALL_DIR}/${APP_NAME}" >> "\$LOG_FILE"
else
    echo "Error moving \${BINARY_NAME} to \${INSTALL_DIR}/${APP_NAME}" >> "\$LOG_FILE"
    exit 1
fi

# Optionally, clean up the other binary
rm -f "\${SOURCE_DIR}/${APP_NAME}_arm64" "\${SOURCE_DIR}/${APP_NAME}_x86_64"
EOF

chmod +x "${SCRIPT_DIR}/postinstall"

echo "================= PKG_DIR ================"
# Check package directory
if ls -lR "${PKG_DIR}"; then
    echo "PKG_DIR exists"
    cat "${SCRIPT_DIR}/postinstall"
else
    echo "PKG_DIR does not exist"
fi
echo "================= PKG_DIR ================"

# Ensure the correct root directory is used for pkgbuild
# Note: Using the parent directory of the structure as root
echo "Building the .pkg installer..."
pkgbuild --root "${PKG_DIR}" \
         --identifier "${IDENTIFIER}" \
         --version "${VERSION}" \
         --scripts "${SCRIPT_DIR}" \
         --install-location "/usr/local/bin" \
         "${DIST_DIR}/${APP_NAME}-${VERSION}.pkg" || { echo "pkgbuild failed."; exit 1; }

# Optionally, create a .dmg file containing the .pkg
echo "Creating .dmg file..."
hdiutil create -volname "${APP_NAME} ${VERSION}" -srcfolder "${DIST_DIR}/${APP_NAME}-${VERSION}.pkg" -ov -format UDZO "${DIST_DIR}/${DMG_NAME}" || { echo "Failed to create .dmg"; exit 1; }

# Cleanup
echo "Cleaning up..."
echo "Build complete. Find the .pkg and .dmg in the ${DIST_DIR} directory, PKG in ${PKG_DIR} directory, build in ${BUILD_DIR} directory.staging in ${STAGING_DIR} directory."

echo "Testing..."
pkgutil --expand "${DIST_DIR}/${APP_NAME}-${VERSION}.pkg" "expanded_package"
echo "================= expanded pkg log ================"
ls -lR "expanded_package"
cat "expanded_package/Scripts/postinstall"
echo "================= expanded pkg log ================"

sudo installer -verboseR -pkg "${DIST_DIR}/${APP_NAME}-${VERSION}.pkg" -target /
echo "================= post install log ================"
cat "$LOG_PATH"
echo "================= post install log ================"

echo "removing build and packaging files pkg_dir=${PKG_DIR} build_dir=${BUILD_DIR} staging_dir=${STAGING_DIR} expanded_package"
rm -rf "${PKG_DIR}" "${BUILD_DIR}" "${STAGING_DIR}" "expanded_package"
ls -lR "${PKG_DIR}" "${BUILD_DIR}" "${STAGING_DIR}" "expanded_package"
echo "Build and packaging complete. Find the .pkg and .dmg in the ${DIST_DIR} directory."