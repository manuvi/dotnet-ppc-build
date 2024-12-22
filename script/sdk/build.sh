#!/bin/bash

prebuild_sdk() {
  echo "SDK prebuild section"
  if [ "$REBUILD" -eq 1 ]; then
    echo "Clear artifacts directory"
    pushd $X86_DIR/opt/sdk
      sudo rm  -rf artifacts
    popd
  fi

  echo "Runtime copy"
  pushd $X86_DIR/opt/sdk
    DST=artifacts/obj/redist-installer/$BUILD_CONF/downloads
    mkdir -p $DST
    cp $REDIST_DIR/dotnet-runtime-9.0.0-linux-$ARCH.tar.gz $DST
    cp $REDIST_DIR/aspnetcore-runtime-*-linux-$ARCH.tar.gz  $DST
  popd

  echo "Add runtime shipping to nuget sources"
  CMD="\
  cd /opt/sdk && \
  ../dotnet-runtime/dotnet nuget add source /opt/runtime/artifacts/packages/$BUILD_CONF/Shipping --name RuntimeLocalSource"
  sudo chroot $X86_DIR /bin/bash -c "$CMD" 
  
  CMD="\
  cd /opt/sdk && \
  ../dotnet-runtime/dotnet nuget add source /opt/aspnetcore/artifacts/packages/$BUILD_CONF/Shipping --name AspNetCoreLocalSource"
  sudo chroot $X86_DIR /bin/bash -c "$CMD" 
}

build_sdk() {
  echo "SDK build section"

  CMD="\
    cd /opt/sdk && \
    NUGET_PACKAGES=/opt/nuget-packages \
    ROOTFS_DIR=/opt/$ARCH \
    ./build.sh --pack -c $BUILD_CONF  /p:Architecture=$ARCH --verbosity detailed"
  sudo chroot $X86_DIR /bin/bash -c "$CMD"
}

postbuild_sdk() {
  echo "SDK postbuild section"
}
