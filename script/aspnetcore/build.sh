#!/bin/bash

prebuild_aspnetcore() {
  echo "ASPNetCore prebuild section"
  if [ "$REBUILD" -eq 1 ]; then
    echo "Clear artifacts directory"
    pushd $X86_DIR/opt/aspnetcore
      sudo rm  -rf artifacts
    popd
  fi

  echo "Add runtime shipping to nuget sources"
  CMD="\
  cd /opt/aspnetcore && \
  ../dotnet-runtime/dotnet nuget add source /opt/runtime/artifacts/packages/$BUILD_CONF/Shipping --name LocalSource"    
  sudo chroot $X86_DIR /bin/bash -c "$CMD" 

  RUNTIME=dotnet-runtime-9.0.0-linux-$ARCH.tar.gz
  if [ -f "$REDIST_DIR/$RUNTIME" ]; then
    pushd $X86_DIR/opt/aspnetcore
      echo "Copy runtime on AspNetCore.App.Runtime"
      DST=artifacts/obj/Microsoft.AspNetCore.App.Runtime
      sudo mkdir -p $DST
      sudo cp $REDIST_DIR/$RUNTIME $DST
    popd  
  else
    echo "Cannot find $REDIST_DIR/$RUNTIME"
    exit 1
  fi  

  if [ ! -d $X86_DIR/opt/aspnetcore/.dotnet ]; then
    # create dotnet directory (don't let build to create it) and update it with new runtime
    pushd $X86_DIR/opt/aspnetcore
      mkdir -p .dotnet
      cd .dotnet
      tar xzf $REDIST_DIR/$(basename $X86_DOTNET_SDK)
      # tar xzf $REDIST_DIR/dotnet-runtime-9.0.0-linux-x64.tar.gz
      cd packs
      rm -rf Microsoft.NETCore.App.Host.linux-x64 Microsoft.NETCore.App.Ref
    popd
  fi
}

build_aspnetcore() {
  echo "ASPNetCore build section"

  CMD="\
    cd /opt/aspnetcore && \
    NUGET_PACKAGES=/opt/nuget-packages \
    ROOTFS_DIR=/opt/$ARCH \
    ./eng/build.sh --pack -c $BUILD_CONF -arch $ARCH"
  sudo chroot $X86_DIR /bin/bash -c "$CMD"
}

postbuild_aspnetcore() {
  echo "ASPNetCore postbuild section"
  
  pushd $X86_DIR/opt/aspnetcore
    cp artifacts/installers/$BUILD_CONF/aspnetcore-runtime-9.0.1-linux-$ARCH.tar.gz $REDIST_DIR/aspnetcore-runtime-9.0.0-linux-$ARCH.tar.gz
  popd
}
