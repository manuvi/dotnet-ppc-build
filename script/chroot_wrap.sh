#!/bin/bash

chroot_cleanup () {
    echo "Umounting file systems..."

    sudo umount -lf "$X86_DIR/proc" 2>/dev/null    
    echo "$X86_DIR/proc Unmounted"

    sudo umount -lf "$X86_DIR/sys" 2>/dev/null
    echo "$X86_DIR/sys Unmounted"

    sudo umount -lf "$X86_DIR/dev/pts" 2>/dev/null
    echo "$X86_DIR/dev/pts Unmounted"

    sudo umount -lf "$X86_DIR/dev" 2>/dev/null
    echo "$X86_DIR/dev Unmounted"

    if grep -qs "$X86_DIR/opt/nuget-packages" /proc/mounts; then
        sudo umount -lf "$X86_DIR/opt/nuget-packages" 2>/dev/null
        echo "$X86_DIR/opt/nuget-packages Unmounted"
    fi
    
    echo "Unmount complete."
}

function chroot_wrap {
    echo "Mounting file system..."

    if ! grep -qs "$X86_DIR/proc" /proc/mounts; then
        echo "Mount $X86_DIR/proc"
        sudo mount -t proc none "$X86_DIR/proc"
    else
        echo "$X86_DIR/proc already mounted"
    fi

    if ! grep -qs "$X86_DIR/sys" /proc/mounts; then
        echo "Mount $X86_DIR/sys"
        sudo mount -t sysfs none "$X86_DIR/sys"
    else
        echo "$X86_DIR/sys already mounted"
    fi

    if ! grep -qs "$X86_DIR/dev" /proc/mounts; then
        echo "Mount $X86_DIR/dev"
        sudo mount --bind /dev "$X86_DIR/dev"
    else
        echo "$X86_DIR/dev already mounted"
    fi

    if ! grep -qs "$X86_DIR/dev/pts" /proc/mounts; then
        echo "Mount $X86_DIR/dev/pts"
        sudo mount --bind /dev/pts "$X86_DIR/dev/pts"
    else
        echo "$X86_DIR/dev/pts already mounted"
    fi

    if [ "$1" != "inner" ]; then
        if ! grep -qs "$X86_DIR/opt/nuget-packages" /proc/mounts; then
            echo "Mount $X86_DIR/opt/nuget-packages"
            sudo mount --bind nuget-packages "$X86_DIR/opt/nuget-packages"
        else
            echo "$X86_DIR/opt/nuget-packages already mounted"
        fi
    fi
}

function chroot_execute {
    sudo chroot $CHROOT_DIR /bin/bash $@
}

function chroot_enter {
    chroot_wrap    

    trap chroot_cleanup EXIT

    echo "Entering chroot..."
    sudo chroot "$X86_DIR" /bin/bash
}

function chroot_enter_inner {
    X86_DIR=$X86_DIR/opt/$ARCH

    chroot_wrap inner

    trap chroot_cleanup EXIT

    echo "Entering chroot..."
    sudo chroot "$X86_DIR" /usr/bin/qemu-$ARCH /bin/bash -i
}



