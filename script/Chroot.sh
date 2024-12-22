#!/bin/bash

# external parameters
# X86_DIR
# ROOTFS_DIR
# note: the ppc64 rootfs will be crated from host and after that it will be copied inside X86 root

# Args: #1 'host/rootfs'
Chroot_build () {
    # Proxy check
    if [[  -z "$APT_PROXY" ]]; then
        export http_proxy=$APT_PROXY
    fi
    
    # mode check
    if [ "$1" = "host" ]; then
        DST=$X86_DIR

        # if directory exists, exit
        if [[ -d $DST ]]; then
            return
        fi
    elif [ "$1" = "rootfs" ]; then
        DST=$ARCH

        # if directory exists, exit
        if [[ -d $X86_DIR/opt/$DST ]]; then
            return
        fi
    fi
    
    # ensure that DST is a valid path because otherwise we could damage host root filesystem
    if [[ -z "$DST" ]]; then
        echo "debootstrap works in root env, something is wrong on setup"
        exit 1
    fi

    # x86 is supported by standard debian url
    if [ "$1" = "host" ]; then
        sudo debootstrap $DEBIAN_NAME $DST $DEBIAN_URL
    elif [ "$1" = "rootfs" ]; then
        if [ "$ARCH" = "ppc64" ]; then
            # ppc is supported by debian ports url
            sudo debootstrap --variant=minbase --foreign $DEBIANPORT_KEYRING --arch $ARCH $DEBIAN_NAME $DST $DEBIANPORT_URL
        else
            # ppc le is supported by debian url
            sudo debootstrap --variant=minbase --foreign --arch ppc64el $DEBIAN_NAME $DST $DEBIAN_URL
        fi
    fi
    
    # setup apt proxy if available
    if [ ! -z "$APT_PROXY" ]; then
        echo "Acquire::http::proxy \"$APT_PROXY/\";" | sudo tee $DST/etc/apt/apt.conf.d/80proxy > /dev/null
        echo "Acquire::https::proxy \"$APT_PROXY/\";" | sudo tee -a $DST/etc/apt/apt.conf.d/80proxy > /dev/null
        echo "Acquire::ftp::proxy \"$APT_PROXY/\";" | sudo tee -a $DST/etc/apt/apt.conf.d/80proxy > /dev/null
    fi

    if [ "$1" = "rootfs" ]; then
        # this is cross environment, we need qemu static and we need to run step 2 bootstrap
        CROSS_RUN=/usr/bin/qemu-$ARCH
        sudo cp $CROSS_RUN $DST/usr/bin
        sudo chroot $DST $CROSS_RUN /usr/bin/bash /debootstrap/debootstrap --second-stage
    fi

    sudo chroot $DST $CROSS_RUN /usr/bin/apt update
    sudo chroot $DST $CROSS_RUN /usr/bin/apt upgrade -y
    sudo chroot $DST $CROSS_RUN /usr/bin/apt install locales -y 
    sudo chroot $DST $CROSS_RUN /usr/bin/sed -i 's/# $CHROOT_LOCALE/$CHROOT_LOCALE/g' /etc/locale.gen
    echo "LANG=$CHROOT_LANG" | sudo tee $DST/etc/default/locale
    sudo chroot $DST $CROSS_RUN /usr/bin/sh /usr/sbin/locale-gen
    
    if [ "$1" = "host" ]; then
        # Install Fixed common packages
        sudo chroot $DST /usr/bin/apt install -y $X86_APT_PKG

        if [ "$ARCH" = "ppc64" ]; then
            PKG_SUFFIX=powerpc
        elif [ "$ARCH" = "ppc64le" ]; then
            PKG_SUFFIX=ppc64el
        fi

        # Install arch dep packages
        sudo chroot $DST /usr/bin/apt install -y gcc-multilib-powerpc64-linux-gnu crossbuild-essential-$PKG_SUFFIX

        echo "Cleanup packages..."
        sudo chroot $DST /usr/bin/apt-get clean
        sudo chown $_UIO:$_GID $DST
        sudo chown $_UIO:$_GID $DST/opt
        mkdir -p $DST/opt/nuget-packages
    elif [ "$1" = "rootfs" ]; then
        # install packages required for dotnet build
        sudo chroot $DST $CROSS_RUN /usr/bin/apt install -y $ROOTFS_APT_PKG
        
        echo "Cleanup packages..."
        sudo chroot $DST $CROSS_RUN /usr/bin/apt-get clean
        sudo chown $_UIO:$_GID $DST
        # move the rootfs inside x86 dir
        sudo mv $ARCH $X86_DIR/opt
    else
        echo "Chroot: Which kind of configuration do have you run?"
        exit 1
    fi
}