#!/bin/bash

Repo_GetSource() {
    # check parameter
    if [ -z "$1" ]; then
        echo "Repo: project not specified"
        exit 1
    fi

    # check configuration directory
    if [ ! -d $BASE_DIR/script/$1 ]; then
        echo "Repo: configuration directory for project $1 doesn't exists"
        exit 1
    fi

    # execute getter script
    source $BASE_DIR/script/$1/source.sh

    GetSource

    unset GetSource
}

Repo_ApplyCommmonPatches () {
    COMMON_PATCHES=$BASE_DIR/script/patches

    files=($(ls -1 "$COMMON_PATCHES" | sort))
    count=${#files[@]}

    if [[ $count -gt 0 ]]; then
        echo "Found $count common patches"

        pushd $X86_DIR/opt/$1
            for file in "${files[@]}"; do
                echo "Apply patch $file"
                git apply --binary $COMMON_PATCHES/$file
                #patch -p1 < $COMMON_PATCHES/$file
            done
        popd
    fi
}

Repo_ApplyProjectPatches () {
    PATCHES=$BASE_DIR/script/$1/patches

    files=($(ls -1 "$PATCHES" | sort))
    count=${#files[@]}

    if [[ $count -gt 0 ]]; then
        echo "Found $count patches for project $1"

        pushd $X86_DIR/opt/$1
            for file in "${files[@]}"; do
                echo "Apply patch $file"
                #patch -p1 < $PATCHES/$file
                git apply --binary $PATCHES/$file
            done
        popd
    fi
}






