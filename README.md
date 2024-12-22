# PPC Big/Little Endian Script for .DOTNET

## Why these scripts
While trying to port DOTNET for Big Endian I face some problem to understand the many and many pages of [official DOTNET Documentation](https://github.com/dotnet).
So I got all I can from documentation and from [(old DotNet7 scripts for PPC Little Endian)](https://github.com/ppc64le/build-scripts/tree/master/d/dotnet7).

## How to use
These scripts works inside a chroot environment and to avoid big or little endian issue for CMake auto detect or other problems related to common architecture definition, you can create a specific chroot dedicated to big or little endian architecture.
Then inside /opt path a sysrootfs will be created for cross build libraries.
Cross sysrootfs is created with debuildroot + qemu-ppc64/ppc64le.

### Step 0 - Prerequisites
These scripts are intended to be run on a **Debian** or compatible system.
You must check these dependencies:
* wget
* debootstrap
* git
* debian-ports-archive-keyring

You have to be able to run as **sudo** user.

### Step 1 - Prepare you environment
To setup your environment use
* ```./PrepareEnv.sh ppc64```
or
* ```./PrepareEnv.sh ppc64le```

It will generate a chroot environment with a sysrootfs under /opt path, depending the architecture you choose.
Then it will generates a directory for **nuget-package** to share the downloaded packets across al the projects (and architectures if you need)
Finally it downloads an sdk. It is needed to run come command to upadate NuGet local repo.

### Step 2 - Prepare source code
To download all the sources needed you have to run
* ```./PrepareSource.sh ppc64```
or
* ```./PrepareSource.sh ppc64le```

It will clone from official repositories the following three projects:
1. [dotnet runtime](https://github.com/dotnet/runtime)
2. [dotnet aspnetcore](https://github.com/dotnet/aspnetcore)
3. [dotnet sdk](https://github.com/dotnet/sdk)

Then applies some local patches.

### Step 3 - Build the code
To build the code, just run
* ```./Build.sh <arch> <project> <option>```
Arch can be:
```ppc64 / ppc64le```
Project can be
```runtime / aspnetcore / sdk / all```
Option can be
```empty / rebuild / post```

If you take a look inside script directory you will find a directory for every project.
Every project has a pre, build and post scripts.
- **post** option will run only the post scripts (usually something that pull out some artifact to redist directory)
- **rebuild** will delete artifacts directory before start the process
- **empty** will run pre, build and post

## Customization
Inside script directory you'll find some file to update some information about build type (Debug / Release), Debian repository and distro codename to use, proxy...take a look on
```script/config.cfg```

Moreover, if you want to specify another git repo, branch or head revision to get, you'll find a ```source.sh``` script inside every configuration project dir. Just update as you need.

## WARNING
**The ppc64 build is not working.**
Actually there's some problem inside mono mini-ppc.c because probably the work around little endian ABIv2 has been done without taking in account that big endian still works with ABIv1, then the generated code will produce SIGSEGV or other kind of fails.

Feel free to help me to make it working again.


