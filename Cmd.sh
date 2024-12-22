#!/bin/bash

set -e

source script/Utils.sh

Usage () {
    echo "X86 DOTNET Builder for PPC64 BE/LE Targets - by Manuel Virgilio"
    echo ""
    echo "This script will enter on x86 chroot"
    echo ""
    echo "Usage: ./Cmd.sh <arch>"
    echo "Arch can be: "
    echo "  x86ppc64    : x86 chroot for ppc64  big endian"
    echo "  x86ppc64le  : x86 chroot for ppc64 little endian"
    echo "  ppc64       : ppc64 chroot inside x86 for ppc64 big endian"
    echo "  ppc64le     : ppc64 chroot inside x86 for ppc64 little endian"
}

# check parameters
if [[ $# -lt 1 ]]; then
    Usage
    exit 1
fi

# check arch keyword
unset ARCH
INNER=0
case "$1" in
    x86ppc64)
        ARCH=ppc64        
        ;;
    ppc64)
    	ARCH=ppc64
        INNER=1
        ;;
    
    x86ppc64le)
        ARCH=ppc64le
        ;;

    ppc64le)
    	ARCH=ppc64le
        INNER=1
        ;;
        
    *)
        echo "Wrong Options! Check Usage"
        exit 1
        ;;
esac

# Load common variables
source script/Common.sh
source script/chroot_wrap.sh

# Now we can build chroot
if [ "$INNER" -eq 1 ]; then
    Utils_Title "Enter $ARCH Command line for $X86_DIR"
    chroot_enter_inner
else
    Utils_Title "Enter Command line for $X86_DIR"
    chroot_enter
fi