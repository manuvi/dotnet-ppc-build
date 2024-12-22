#!/bin/bash

BASE_DIR=`pwd`

# Variables used by script
SCRIPT_DIR=$BASE_DIR/script
RUNTIME_DIR=$BASE_DIR/runtime

# default runtime
REDIST_DIR=$BASE_DIR/redist
DEFAULT_RUNTIME=dotnet-sdk-9.0.100-linux-x64.tar.gz

# Variables used by build system
export NUGET_PACKAGES=${BASE_DIR}/nuget-packages

if [ ! -v ARCH ]; then
    echo "Error! ARCH is not defined"  
    exit 1
fi

X86_DIR=x86-$ARCH

NUGET_CHROOT_DIR=

_UIO=$(id -u)
_GID=$(id -g)


