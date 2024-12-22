#!/bin/bash

prebuild_runtime() {
  echo "Runtime prebuild section"
  if [ "$REBUILD" -eq 1 ]; then
    echo "Clear artifacts directory"
    pushd  $X86_DIR/opt/runtime
      sudo rm -rf artifacts
    popd
  fi
}

build_runtime() {
  echo "Runtime build section"

  #echo "Build X86 runtime"
  #  CMD="\
  #  cd /opt/runtime && \
  #  NUGET_PACKAGES=/opt/nuget-packages \
  #  ./build.sh -c $BUILD_CONF"
  #sudo chroot $X86_DIR /bin/bash -c "$CMD"
#
  #echo "Clean X86 build files"
  #pushd  $X86_DIR/opt/runtime/artifacts
  #  sudo rm -rf bin obj
  #popd

  echo "Build $ARCH runtime"
  CMD="\
    cd /opt/runtime && \
    NUGET_PACKAGES=/opt/nuget-packages \
    ROOTFS_DIR=/opt/$ARCH \
    ./build.sh -c $BUILD_CONF -arch $ARCH -cross"
  sudo chroot $X86_DIR /bin/bash -c "$CMD"
}

postbuild_runtime() {
  echo "Runtime postbuild section"

  pushd  $X86_DIR/opt/runtime
    cp artifacts/packages/$BUILD_CONF/Shipping/dotnet-runtime-*-linux-*.tar.gz $REDIST_DIR
  popd
}
