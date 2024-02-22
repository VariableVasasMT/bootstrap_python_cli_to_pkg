#!/bin/bash

# Install Rosetta 2 if it's not already installed
if ! /usr/bin/pgrep oahd >/dev/null 2>&1; then
    echo "Installing Rosetta 2..."
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    
    if [ $? -ne 0 ]; then
        echo "Failed to install Rosetta 2. Please install Rosetta 2 manually."
        exit 1
    fi
else
    echo "Rosetta 2 is already installed."
fi

# Install Homebrew for arm64 if not installed
if ! command -v /opt/homebrew/bin/brew &> /dev/null; then
    echo "Installing Homebrew for arm64..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew for arm64 is already installed."
fi

# Function to install Homebrew for x86_64
install_homebrew_x86_64() {
    echo "Installing Homebrew for x86_64 under Rosetta 2..."
    arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# Check if Homebrew for x86_64 is installed
if ! arch -x86_64 /usr/bin/which brew &> /dev/null; then
    install_homebrew_x86_64
else
    echo "Homebrew for x86_64 is already installed."
fi

# Install Python and PyInstaller for arm64
echo "Installing Python and PyInstaller for arm64..."
/opt/homebrew/bin/brew install python
/opt/homebrew/bin/pip3 install pyinstaller

# Install Python and PyInstaller for x86_64
echo "Installing Python and PyInstaller for x86_64..."
arch -x86_64 /usr/local/bin/brew install python
arch -x86_64 /usr/local/bin/pip3 install pyinstaller

echo "Setup complete. Python and PyInstaller are installed for both architectures."
