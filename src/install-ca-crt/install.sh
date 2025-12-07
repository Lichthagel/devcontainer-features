#!/bin/bash
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERTIFICATE_FILE="$SCRIPT_DIR/licht.crt"
CERTIFICATE_NAME="licht"

echo "Activating feature 'install-ca-crt'"
echo "Installing certificate from: $CERTIFICATE_FILE"

# Determine the package manager
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Unable to determine OS"
    exit 1
fi

# Function to install CA certificate on Debian/Ubuntu
install_ca_debian() {
    echo "Installing CA certificate on Debian/Ubuntu..."
    
    # Ensure ca-certificates package is installed
    apt-get update
    apt-get install -y ca-certificates
    
    # Create directory if it doesn't exist
    mkdir -p /usr/local/share/ca-certificates
    
    # Copy certificate
    if [ -f "$CERTIFICATE_FILE" ]; then
        echo "Copying certificate: $CERTIFICATE_FILE"
        cp "$CERTIFICATE_FILE" "/usr/local/share/ca-certificates/${CERTIFICATE_NAME}.crt"
    else
        echo "Error: Certificate not found at $CERTIFICATE_FILE"
        exit 1
    fi
    
    # Set proper permissions
    chmod 644 "/usr/local/share/ca-certificates/${CERTIFICATE_NAME}.crt"
    
    # Update CA certificates
    update-ca-certificates
    
    echo "CA certificate installed successfully"
}

# Function to install CA certificate on Alpine
install_ca_alpine() {
    echo "Installing CA certificate on Alpine..."
    
    # Ensure ca-certificates package is installed
    apk add --no-cache ca-certificates
    
    # Create directory if it doesn't exist
    mkdir -p /usr/local/share/ca-certificates
    
    # Copy certificate
    if [ -f "$CERTIFICATE_FILE" ]; then
        echo "Copying certificate: $CERTIFICATE_FILE"
        cp "$CERTIFICATE_FILE" "/usr/local/share/ca-certificates/${CERTIFICATE_NAME}.crt"
    else
        echo "Error: Certificate not found at $CERTIFICATE_FILE"
        exit 1
    fi
    
    # Set proper permissions
    chmod 644 "/usr/local/share/ca-certificates/${CERTIFICATE_NAME}.crt"
    
    # Update CA certificates
    update-ca-certificates
    
    echo "CA certificate installed successfully"
}

# Function to install CA certificate on RHEL/CentOS/Fedora
install_ca_rhel() {
    echo "Installing CA certificate on RHEL/CentOS/Fedora..."
    
    # Ensure ca-certificates package is installed
    if command -v dnf > /dev/null; then
        dnf install -y ca-certificates
    else
        yum install -y ca-certificates
    fi
    
    # Create directory if it doesn't exist
    mkdir -p /etc/pki/ca-trust/source/anchors
    
    # Copy certificate
    if [ -f "$CERTIFICATE_FILE" ]; then
        echo "Copying certificate: $CERTIFICATE_FILE"
        cp "$CERTIFICATE_FILE" "/etc/pki/ca-trust/source/anchors/${CERTIFICATE_NAME}.crt"
    else
        echo "Error: Certificate not found at $CERTIFICATE_FILE"
        exit 1
    fi
    
    # Set proper permissions
    chmod 644 "/etc/pki/ca-trust/source/anchors/${CERTIFICATE_NAME}.crt"
    
    # Update CA certificates
    update-ca-trust
    
    echo "CA certificate installed successfully"
}

# Install based on OS
case "$OS" in
    debian|ubuntu)
        install_ca_debian
        ;;
    alpine)
        install_ca_alpine
        ;;
    rhel|centos|fedora|rocky|almalinux)
        install_ca_rhel
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

echo "Feature 'install-ca-crt' activation complete!"
