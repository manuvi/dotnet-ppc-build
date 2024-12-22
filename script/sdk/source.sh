#!/bin/bash

GetSource() {
    local PROJECT=sdk
    #local REPO_GIT_BRANCH=ppc64
    local REPO_GIT_COMMIT=59db016f11bb27d359336cf37524b863d77e7fea
    local REPO_ADDRESS=https://github.com/dotnet/sdk

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
