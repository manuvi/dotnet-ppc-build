#!/bin/bash

source script/config.cfg

usage() {
  echo "Usage: ./build.sh <arch> <project> rebuild/post"
  echo "Arch can be: "
  echo "  ppc64"
  echo "  ppc64le"
  echo "Project can be:"
  echo "  all - runtime, next aspnetcore, next sdk"
  echo "  runtime"
  echo "  aspnetcore"
  echo "  sdk"
  echo " if rebuild is used, all artifacts are cleaned before run build"
  echo " if post is used, only post script will be run"
}

allprojects=(
  "runtime"
  "aspnetcore"
  "sdk"
)

# check parameters
if [ $# -eq 0 ]; then
  usage
  exit 1
fi

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

REBUILD=0
ONLYPOST=0
if [ "$3" = "rebuild" ]; then
  REBUILD=1
elif [ "$3" = "post" ]; then
  ONLYPOST=1
fi

Test () {
  for elemento in "${allprojects[@]}"; do
    echo "$elemento"
  done
}


PROJECT=$2

VALID_PROJECT=0
ALL_PROJECT=0
case "$2" in
    runtime)
    	VALID_PROJECT=1        
        ;;
    
    aspnetcore)
    	VALID_PROJECT=1
        ;;

    sdk)
    	VALID_PROJECT=1
        ;;
    
    all)
      ALL_PROJECT=1
        ;;

    test)
      Test
      exit 0
      ;;
        
    *)
        echo "Wrong Parameters"
        exit 1
        ;;
esac

source script/Common.sh
source script/BuildHelper.sh

BuildHelper_UpdateRootFSPath 

#setup filesystem for chroot
BuildHelper_PreBuild

if [ "$ALL_PROJECT" -eq 1 ]; then
  for elemento in "${allprojects[@]}"; do
    PROJECT=$elemento
    echo "Build Project $PROJECT"
    BuildHelper_BuildProject $PROJECT
  done
else
  echo "Build Project $PROJECT"
  BuildHelper_BuildProject $PROJECT
fi

# clean mounted filesystems for chroot
BuildHelper_PostBuild



