#!/bin/bash
# This script Downloads Fedora and prepares it for netinstall
# TODO:Allow for non-x86_64 architectures
set -e
# Variables (User Adjustable)
FEDORA_REPO=https://download.fedoraproject.org/pub/fedora/linux/releases
#FEDORA_REPO=https://ftp.halifax.rwth-aachen.de/fedora/linux/releases/
# Load env
CONFIG_FILE="$(dirname "$0")/../../config/env.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: env configuration file not found at $CONFIG_FILE"
    echo "Run setup-env.sh to create it"
    exit 1
fi

BOOT_DIR="/boot/fedora"
BOOT_DIR_IRL="$(realpath "$BASE_DIR$BOOT_DIR")"
TMP_PATH="$(realpath "$BASE_DIR/build/fedora")"
#####################################
# VARIABLES END HERE SO DON'T TOUCH!#
#####################################
# Step 1:create the image dir
echo Downloading Fedora
# Step 2: Download the fedora files
# TODO:Actually read the .treeinfo
# TODO:Somehow get the latest version directly from the fedora site
# This is a bit of a hack, but it works

# Loop for the latest version
FEDORA_VERSION=0
VALID_VERSION=40 # The latest version is 42 at the time of writing but this checking if its above 40 just in case
i=$VALID_VERSION
echo -n Checking for the latest of fedora:
while true; do
    # Try to get the .treeinfo file for version i
    # If it fails, the i - 1 version is the latest
    # First disable -e
    set +e
    echo -n "$i "
    curl -s -f $FEDORA_REPO/$i/Everything/x86_64/os/.treeinfo > /dev/null
    
    if [ $? -eq 0 ]; then
        set -e
        # If it succeeds, set the version and continue
        i=$((i + 1))
    else
        # If it fails, check if a README file exists
        # If it does, continue
        # If it doesn't, set the version and break
        # First disable -e
        set +e
        curl -s -f $FEDORA_REPO/$i/README > /dev/null
        if [ $? -eq 0 ]; then
            # If it succeeds, set the version and continue
            i=$((i + 1))
            continue
        fi
        set -e
        FEDORA_VERSION=$((i - 1))
        break
    fi
done
# Check if the version is valid
if [ $FEDORA_VERSION -lt $VALID_VERSION ]; then
    echo "Error: Fedora version is less than $VALID_VERSION"
    echo "Got $FEDORA_VERSION"
    echo "The autodetection broke, please set the version manually in the script and report it"
    exit 1
fi
echo Downloading Fedora $FEDORA_VERSION
# Step 3: Download the fedora boot files
#rm -rf $BOOT_DIR_IRL
#mkdir --parents $BOOT_DIR_IRL/
wget $FEDORA_REPO/$FEDORA_VERSION/Everything/x86_64/os/images/pxeboot/vmlinuz -O $BOOT_DIR_IRL/vmlinuz
wget $FEDORA_REPO/$FEDORA_VERSION/Everything/x86_64/os/images/pxeboot/initrd.img -O $BOOT_DIR_IRL/initrd.img
wget $FEDORA_REPO/$FEDORA_VERSION/Everything/x86_64/os/images/install.img -O $BOOT_DIR_IRL/stage2.img
# Step 4: Write the boot script
echo "Setting up boot config"
cat > $BOOT_DIR_IRL/boot.ipxe <<EOF
#!ipxe
echo Starting Fedora
kernel ${SERVER_PROTOCOL}://${SERVER_IPv4}${SERVER_PATH}${SERVER_BASE_PATH}/vmlinuz ip=dhcp inst.stage2=${SERVER_PROTOCOL}://${SERVER_IPv4}${SERVER_BASE_PATH}${BOOT_DIR}/stage2.img loglevel=3 inst.sshd
initrd ${SERVER_PROTOCOL}://${SERVER_IPv4}${SERVER_PATH}${SERVER_BASE_PATH}/initrd.img
echo Starting kernel (don't forget to stream Short n' Sweet while installing [good luck doing that])
boot
EOF