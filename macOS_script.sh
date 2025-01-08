#!/bin/bash
set -e  # Exit on any error
set -x  # Debugging: Show all commands

# Function to install VirtualBox on macOS
install_virtualbox_mac() {
    echo "Installing the latest version of VirtualBox on macOS..."

    # Fetch the latest VirtualBox version URL
    VBOX_URL="https://download.virtualbox.org/virtualbox/7.1.4/VirtualBox-7.1.4-165100-OSX.dmg"
    echo "Latest version URL: $VBOX_URL"
    
    # Download the DMG
    curl -L $VBOX_URL -o /tmp/virtualbox.dmg
    if [ $? -ne 0 ]; then
        echo "Error downloading VirtualBox DMG. Exiting."
        exit 1
    fi

    # Mount the DMG
    hdiutil attach /tmp/virtualbox.dmg
    if [ $? -ne 0 ]; then
        echo "Error mounting VirtualBox DMG. Exiting."
        exit 1
    fi

    # List mounted volumes to verify
    echo "Mounted volumes:"
    ls /Volumes

    # Find the mount point for VirtualBox
    VBOX_MOUNT=$(ls /Volumes | grep -i "VirtualBox")
    if [ -z "$VBOX_MOUNT" ]; then
        echo "VirtualBox volume not found. Exiting."
        exit 1
    fi

    # Show the mounted volume contents
    echo "Contents of mounted volume:"
    ls -l "/Volumes/$VBOX_MOUNT"

    # Install VirtualBox
    if [ -f "/Volumes/$VBOX_MOUNT/VirtualBox.pkg" ]; then
        echo "Found VirtualBox.pkg. Installing..."
        sudo installer -pkg "/Volumes/$VBOX_MOUNT/VirtualBox.pkg" -target /
        if [ $? -eq 0 ]; then
            echo "VirtualBox installation completed on macOS!"
        else
            echo "Error installing VirtualBox."
            exit 1
        fi
    else
        echo "VirtualBox.pkg not found. Exiting."
        exit 1
    fi

    # Detach the DMG
    hdiutil detach "/Volumes/$VBOX_MOUNT/"
}

# Function to install VMware Fusion on macOS from Dropbox
install_vmware_mac() {
    echo "Installing VMware Fusion on macOS..."

    # Direct Dropbox URL with download
    VMWARE_URL="https://www.dropbox.com/scl/fi/10afvvihhtzr73m3ik0hf/VMware-Fusion-13.6.2-24409261_universal.dmg?rlkey=305abejpfyu507jbttnhzuy6m&st=137rxb2t&dl=1"
    echo "Using URL: $VMWARE_URL"

    # Download VMware Fusion DMG with curl, following redirects
    echo "Downloading VMware Fusion..."
    curl -L -o /tmp/vmware-fusion.dmg "$VMWARE_URL"
    if [ $? -ne 0 ]; then
        echo "Error downloading VMware Fusion DMG. Exiting."
        exit 1
    fi

    # Check file size to ensure download was successful
    FILE_SIZE=$(stat -f%z /tmp/vmware-fusion.dmg)
    if [ $FILE_SIZE -lt 100000 ]; then
        echo "Downloaded file appears too small. Exiting."
        exit 1
    fi

    # Skip MIME type check since Dropbox is serving the file in a different way
    # Uncomment the following lines if you want to proceed without MIME checking
    # FILE_TYPE=$(file --mime-type /tmp/vmware-fusion.dmg | awk '{print $2}')
    # if [ "$FILE_TYPE" != "application/x-apple-diskimage" ]; then
    #     echo "Downloaded file is not a valid DMG. Exiting."
    #     exit 1
    # fi

    # Attach the DMG file
    echo "Mounting VMware Fusion DMG..."
    MOUNT_POINT=$(hdiutil attach /tmp/vmware-fusion.dmg | grep -o '/Volumes/.*' | head -n 1)
    if [ $? -ne 0 ]; then
        echo "Error mounting VMware Fusion DMG. Exiting."
        exit 1
    fi

    # Install VMware Fusion
    if [ -d "$MOUNT_POINT/VMware Fusion.app" ]; then
        echo "Found VMware Fusion.app. Installing..."
        sudo cp -R "$MOUNT_POINT/VMware Fusion.app" /Applications/
        if [ $? -eq 0 ]; then
            echo "VMware Fusion installation completed on macOS!"
        else
            echo "Error installing VMware Fusion."
            exit 1
        fi
    else
        echo "VMware Fusion.app not found. Exiting."
        exit 1
    fi

    # Detach the DMG
    echo "Ejecting VMware Fusion DMG..."
    hdiutil detach "$MOUNT_POINT"
    echo "VMware Fusion installation finished."
}

# Install both VirtualBox and VMware Fusion
install_virtualbox_mac
install_vmware_mac
