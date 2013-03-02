# This scripts is called by mac_build.sh and linux_build.sh and should not be called by itself

OS=`uname -s | tr A-Z a-z | sed -e 's/darwin/mac/' | sed -e 's/mingw32_nt.*/mingw/'`
ARCH=`uname -m`

PREFIX=$PWD/moon-dependencies-$OS-$ARCH
BUILD=$PWD/build-$OS-$ARCH

PATH=$PATH:$PREFIX/bin

mkdir -p $BUILD $PREFIX/bin $PREFIX/include $PREFIX/lib $PREFIX/data $PREFIX/docs/dependencies

