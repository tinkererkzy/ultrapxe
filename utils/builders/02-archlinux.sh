#!/bin/bash
#This script preps the Archlinux ISO for netbooting
set -euo pipefail
#Variables (User Adjustable)

# Check if xorriso is installed
if ! command -v xorriso &> /dev/null; then
    echo "Error: xorriso is not installed. Please install it using your package manager (e.g., 'sudo pacman -S xorriso' on Arch-based systems)."
    exit 1
fi

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
BOOT_DIR_NET=$SERVER_BASE_PATH/boot/archlinux
TMP_PATH="$(realpath "$BASE_DIR/build/arch.iso")"


#####################################
# VARIABLES END HERE SO DON'T TOUCH!#
#####################################
# Step 1:create the image dir
echo Creating $BOOT_DIR_IRL
# Check if the directory exists
if [ ! -d "$BOOT_DIR_IRL" ]; then
    mkdir --parents "$BOOT_DIR_IRL"
else
    echo "Directory $BOOT_DIR_IRL already exists. Deleting old files."
    rm -r "$BOOT_DIR_IRL/"
    mkdir --parents "$BOOT_DIR_IRL"
fi

# Step 2: Download the arch ISO
echo Downloading Archlinux
if [ -f "$TMP_PATH" ]; then
    rm "$TMP_PATH"
fi
wget --tries=3 --timeout=30 https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso -O $TMP_PATH

# Step 3: Extract the ISO
# First we delete the old files
echo Extracting Archlinux
if [ -d "$BASE_DIR/boot/archlinux" ]; then
    echo "Deleting existing deploy."
    rm -r "$BASE_DIR/boot/archlinux"
fi
mkdir --parents "$BOOT_DIR_IRL/iso"
xorriso -osirrox on  -indev $TMP_PATH -extract / $BOOT_DIR_IRL/iso
chmod -R u+w $BOOT_DIR_IRL/iso
# Step 4: Write the boot script
echo "Setting up boot config"
BOOT_DIR=$BOOT_DIR_IRL  # Ensure BOOT_DIR is defined
#Check if we are using NFS
if [ "$SERVER_PROTOCOL" == "nfs" ]; then
   cat > $BOOT_DIR/boot.ipxe <<EOF
#!ipxe
kernel nfs://${SERVER_IPv4}${BOOT_DIR_NET}/iso/arch/boot/x86_64/vmlinuz-linux archiso_nfs_srv=${SERVER_IPV4}:${SERVER_BASE_PATH}/iso/ ip=dhcp
initrd nfs://${SERVER_IPv4}${SERVER_BASE_PATH}/iso/arch/boot/x86_64/initramfs-linux.img
boot
EOF
fi
if [ "$SERVER_PROTOCOL" == "http" ]; then
   cat > $BOOT_DIR/boot.ipxe <<EOF
#!ipxe
kernel http://${SERVER_IPv4}${BOOT_DIR_NET}/iso/arch/boot/x86_64/vmlinuz-linux archiso_http_srv=http://${SERVER_IPv4}${BOOT_DIR_NET}/iso/ ip=dhcp
initrd http://${SERVER_IPv4}${BOOT_DIR_NET}/iso/arch/boot/x86_64/initramfs-linux.img
boot
EOF
fi
cat > $BOOT_DIR_IRL/menu.pipxe <<EOF
item arch Archlinux (Installer)
goto continue-arch
:arch
chain ${SERVER_PROTOCOL}://${SERVER_IPv4}${SERVER_BASE_PATH}/boot/archlinux/boot.ipxe
boot
goto menu
:continue-arch
EOF
rm "$TMP_PATH"
echo "Arch is now ready to be netinstalled"
