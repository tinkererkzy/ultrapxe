#!/bin/bash
#This script Downloads Arch Linux and installs it 
set -e
#Variables (User Adjustable)

# Load env
CONFIG_FILE="$(dirname "$0")/../../config/env.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: env configuration file not found at $CONFIG_FILE"
    echo "Run setup-env.sh to create it"
    exit 1
fi

BOOT_DIR_IRL="$(realpath "$BASE_DIR/boot/archlinux")"
BOOT_DIR_NFS=$NFS_BASE_PATH/boot/archlinux
TMP_PATH="$(realpath "$BASE_DIR/build/arch.iso")"


#####################################
# VARIABLES END HERE SO DON'T TOUCH!#
#####################################
# Check if the server is using HTTP
# if yes quit
if [ "$SERVER_PROTOCOL" != "nfs" ]; then
    echo "This script only works with NFS"
    echo "This script is not ready for HTTP yet"
    exit 1
fi

# Step 1:create the image dir
echo Downloading Archlinux

# Step 2: Download the arch ISO
echo Downloading Archlinux
rm $TMP_PATH
wget https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso -O $TMP_PATH

# Step 3: Extract the ISO
# First we delete the old files
echo Extracting Archlinux
if [ -d "$BASE_DIR/boot/archlinux" ]; then
    echo "Deleting existing deploy."
    rm -r "$BASE_DIR/boot/archlinux"
fi
mkdir --parents $BOOT_DIR_IRL/iso
xorriso -osirrox on  -indev $TMP_PATH -extract / $BOOT_DIR_IRL/iso
chmod -R u+w $BOOT_DIR_IRL/iso
# Step 4: Write the boot script
echo "Setting up boot config"
cat > $BOOT_DIR/boot.ipxe <<EOF
#!ipxe
kernel nfs://${SERVER_IPV4}${SERVER_BASE_PATH}/iso/arch/boot/x86_64/vmlinuz-linux archiso_nfs_srv=${SERVER_IPV4}:${SERVER_BASE_PATH}/iso/ ip=dhcp
initrd nfs://${SERVER_IPV4}${SERVER_BASE_PATH}/iso/arch/boot/x86_64/initramfs-linux.img
boot
EOF
rm $TMP_PATH
echo Set-up Archlinux successfully