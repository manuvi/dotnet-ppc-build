#!/bin/bash

source script/chroot_wrap.sh

BuildHelper_PreBuild () {
  chroot_wrap
}

BuildHelper_PostBuild () {
  chroot_cleanup
}

BuildHelper_BuildProject() {
  source $SCRIPT_DIR/$1/build.sh
  # Run build scripts
  if [ "$ONLYPOST" -eq 0 ]; then
    prebuild_$PROJECT 
    build_$PROJECT
  fi
  postbuild_$PROJECT
  
  unset prebuild_$PROJECT
  unset build_$PROJECT
  unset postbuild_$PROJECT
}

BuildHelper_UpdateRootFSPath () {
  export ROOTFS_DIR=${BASE_DIR}/$1
}

Common_UnpackRuntime() {
  if [ -d "$RUNTIME_DIR" ]; then
    echo "$RUNTIME_DIR does exist."
  else
    mkdir -p $RUNTIME_DIR

    pushd $RUNTIME_DIR
      tar xvzf $REDIST_DIR/$DEFAULT_RUNTIME
      PATH=$RUNTIME_DIR:$PATH
    popd
  fi
}
