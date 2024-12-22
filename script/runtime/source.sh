#!/bin/bash

GetSource() {
    local PROJECT=runtime
    #local REPO_GIT_BRANCH=ppc64
    local REPO_GIT_COMMIT=9d5a6a9aa463d6d10b0b0ba6d5982cc82f363dc3
    local REPO_ADDRESS=https://github.com/dotnet/runtime

    if [ ! -d $X86_DIR/opt/$PROJECT ]; then
        mkdir -p $X86_DIR/opt/$PROJECT

        if [[ -n "$REPO_GIT_BRANCH" ]]; then
            BRANCH="--branch $REPO_GIT_BRANCH"
        else
            unset $BRANCH
        fi

        git clone $BRANCH $REPO_ADDRESS $X86_DIR/opt/$PROJECT
        if [ "$REPO_GIT_COMMIT" != "HEAD" ]; then
            pushd $X86_DIR/opt/$PROJECT        
                git checkout $REPO_GIT_COMMIT        
            popd
        fi

        # Check for patches
        Repo_ApplyCommmonPatches $PROJECT

        Repo_ApplyProjectPatches $PROJECT
    else
        echo "Skip $PROJECT source retrieve, directory already exists."
    fi
}


    

    
