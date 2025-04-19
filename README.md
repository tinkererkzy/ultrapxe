# PXE Boot Server

This repository contains the configuration and scripts for setting up a PXE boot server. It supports booting multiple operating systems, including Fedora and Arch Linux, over the network.

## Directory Structure

- **boot/**: Contains bootloader configurations and OS-specific boot scripts.
- **build/**: Temporary directory for building and preparing files.
- **config/**: Configuration files, including environment settings and machine-specific configurations.
- **extras/**: Additional files and utilities.
- **loaders/**: Compiled iPXE bootloader binaries.
- **src/**: Source files for custom iPXE configurations.
- **utils/**: Utility scripts for building and managing the PXE server.

## Features

- **Multi-OS Support**: Boot Fedora, Arch Linux, and other operating systems.
- **Dynamic Menu Generation**: Automatically generates iPXE menus based on available configurations.
- **Custom iPXE Builds**: Includes scripts to build custom iPXE binaries.
- **Environment Configuration**: Easily configurable via `config/env.conf`.

## Setup Instructions

1. Clone this repository to your PXE server.
2. Setup your DHCP, HTTP, and TFTP servers to serve this directory
3. Run the setup script to configure the environment:
   cd /path/to/repo/utils
   setup-env.sh
   Note: Make sure you are in the `utils` folder
4. chmod the OS build scripts that you want to make available
