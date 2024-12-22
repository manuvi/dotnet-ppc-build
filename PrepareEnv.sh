#!/bin/bash

set -e

source script/config.cfg
source script/Utils.sh

Usage () {
    echo "X86 DOTNET Builder for PPC64 BE/LE Targets - by Manuel Virgilio"
    echo ""
    echo "This script will prepare a chroot environment to isolate the build process and the ppc related libraries"
    echo ""
    echo "Usage: ./PrepareEnv.sh <arch>"
    echo "Arch can be: "
    echo "  ppc64    : big endian"
    echo "  ppc64le  : little endian"
}

# check parameters
if [[ $# -lt 1 ]]; then
    Usage
    exit 1
fi

# check arch keyword
unset ARCH
case "$1" in
    ppc64)
    	ARCH=ppc64        
        ;;
    
    ppc64le)
    	ARCH=ppc64le
        ;;
        
    *)
        echo "Wrong Architecture, available ppc64, ppc64le"
        exit 1
        ;;
esac

# Load common variables
source script/Common.sh
source script/Chroot.sh

# Now we can build chroot
Utils_Title "BUILD CHROOT Environment"
Chroot_build host

Utils_Title "BUILD Dedicated $ARCH sysroot"
Chroot_build rootfs

Utils_Title "Create nuget-package directory"
mkdir -p $BASE_DIR/nuget-packages
echo "Created"

if [ ! -d redist ]; then
    mkdir -p redist
fi
SDK_FILE=$(basename "$X86_DOTNET_SDK")
if [ ! -f $BASE_DIR/redist/$SDK_FILE ]; then
    Utils_Title "Get X86 DOTNET SDK from Repo"
    pushd $BASE_DIR/redist
        wget $X86_DOTNET_SDK 
    popd
fi

Utils_Title "DOTNET Runtime"
pushd $X86_DIR/opt
    if [ ! -d dotnet-runtime ]; then
        mkdir -p dotnet-runtime
        cd dotnet-runtime
        tar xzf $BASE_DIR/redist/$SDK_FILE
    else
        echo "RUNTIME already installed"
    fi
popd

Utils_Title "Done"