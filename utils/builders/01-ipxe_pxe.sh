#!/bin/bash
#Builds the ipxe pxe bootloader binaries
#Set so that if any command returns a non zero exit code return
set -euo pipefail

#Variables (User Adjustable)

ENV_FILE="$(dirname "$0")/../../config/env.conf"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "Error: env configuration file not found at $ENV_FILE"
    echo "Run setup-env.sh to create it"
    exit 1
fi

NAMED_CONFIGS_DIR="$(realpath "$BASE_DIR/src/ipxe-named-configs")"
CLONE_DIR="$(realpath "$BASE_DIR/build")"
CONFIG_FILE="${NAMED_CONFIGS_DIR}/clone-config"


#####################################
# VARIABLES END HERE SO DON'T TOUCH!#
#####################################
# Step 1: Clone the ipxe repository
# Set base and clone directories


# Source the config file
if [ ! -f "$CONFIG_FILE" ] ; then
    echo "Warning: Configuration file '$CONFIG_FILE' not found, using defaults"
    IPXE_BRANCH=""
    IPXE_COMMIT=""
else
    # Read but don't execute config file
    IPXE_BRANCH=$(grep -Po '^TARGET_BRANCH=\K.*' "$CONFIG_FILE" | tr -d '"' | tr -d "'")
    IPXE_COMMIT=$(grep -Po '^TARGET_COMMIT=\K.*' "$CONFIG_FILE" | tr -d '"' | tr -d "'")
fi

# Validate branch name if provided (alphanumeric, dash, underscore, forward slash only)
if [ -n "$IPXE_BRANCH" ] && ! [[ "$IPXE_BRANCH" =~ ^[a-zA-Z0-9/_-]+$ ]]; then
    echo "Error: Invalid characters in IPXE_BRANCH"
    exit 1
fi

# Validate commit hash if provided (hexadecimal only)
if [ -n "$IPXE_COMMIT" ] && ! [[ "$IPXE_COMMIT" =~ ^[a-fA-F0-9]+$ ]]; then
    echo "Error: Invalid characters in IPXE_COMMIT"
    exit 1
fi

# Create and move to build directory
mkdir -p "$CLONE_DIR"
if ! cd "$CLONE_DIR"; then
    echo "Error: Failed to change to clone directory"
    exit 1
fi

# Remove the existing ipxe src if its exists
if [ -d "ipxe" ]; then
    echo "Found left over ipxe source. Deleting."
    rm -r ipxe
fi

echo "Cloning iPXE repository..."
if ! git clone  https://github.com/ipxe/ipxe.git; then
   echo "Error: Failed to clone iPXE repository"
  exit 1
fi
# Change to ipxe directory
if ! cd ipxe; then
    echo "Error: Failed to change to ipxe directory"
    exit 1
fi 

# Fetch and checkout specific commit if providedsrc/ipxe-named-configs
if [ -n "$IPXE_COMMIT" ]; then
    echo "Fetching commit: $IPXE_COMMIT"
    if ! git fetch origin "$IPXE_COMMIT"; then
        echo "Error: Failed to fetch commit $IPXE_COMMIT"
        cd "$BASE_DIR"
        exit 1
    fi

    echo "Checking out commit: $IPXE_COMMIT"
    if ! git checkout "$IPXE_COMMIT"; then
        echo "Error: Failed to checkout commit $IPXE_COMMIT"
        cd "$BASE_DIR"
        exit 1
    fi
else
    echo "No specific commit specified, using latest from default branch"
fi


# Step 2: Copy custom configuration
if [ -d "$NAMED_CONFIGS_DIR" ]; then
    echo "Copying custom configuration files..."
    cp -r "$NAMED_CONFIGS_DIR"/* src/config/local/
fi

# Step 3: Build the ipxe bootloader
#
cd src
make clean
make "-j$(nproc)" bin-x86_64-efi/snponly.efi CONFIG=ultrasrv-pxe
make "-j$(nproc)" bin-i386-efi/snponly.efi CONFIG=ultrasrv-pxe
make "-j$(nproc)" bin/undionly.kpxe CONFIG=ultrasrv-pxe
# Step 3.5: Copy the ipxe bootloader to the output directory
set +e
rm $BASE_DIR/loaders/*.*
set -e
cp bin-x86_64-efi/snponly.efi "$BASE_DIR/loaders/ipxe64.efi"
cp bin-i386-efi/snponly.efi "$BASE_DIR/loaders/ipxe32.efi"
cp bin/undionly.kpxe "$BASE_DIR/loaders/ipxe.undi"

# Done just clear the build directory
rm -rf "$CLONE_DIR/ipxe"

# Done
echo "Done"
exit 0
