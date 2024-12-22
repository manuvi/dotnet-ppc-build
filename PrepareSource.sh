#!/bin/bash

set -e

source script/config.cfg
source script/Utils.sh

Usage () {
    echo "X86 DOTNET Builder for PPC64 BE/LE Targets - by Manuel Virgilio"
    echo ""
    echo "This script will prepare DOTNET Source Code"
    echo ""
    echo "Usage: ./PrepareSource.sh <arch>"
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
source script/Repo.sh

# Now we can build chroot
Utils_Title "Get 'runtime' project"
Repo_GetSource runtime

Utils_Title "Get 'aspnetcore' project"
Repo_GetSource aspnetcore

Utils_Title "Get 'sdk' project"
Repo_GetSource sdk

Utils_Title "Done"