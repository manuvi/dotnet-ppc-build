#!/bin/bash

GetSource() {
    local PROJECT=aspnetcore
    #local REPO_GIT_BRANCH=ppc64
    local REPO_GIT_COMMIT=e7acd42364e7294cc8f42a8031688851376cfa68
    local REPO_ADDRESS=https://github.com/dotnet/aspnetcore

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
                git submodule update --init --recursive  
            popd
        fi

        # Check for patches
        Repo_ApplyCommmonPatches $PROJECT

        Repo_ApplyProjectPatches $PROJECT
    else
        echo "Skip $PROJECT source retrieve, directory already exists."
    fi
}


    

    
