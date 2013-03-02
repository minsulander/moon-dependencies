#!/bin/bash

. common_build_pre.sh

LINUX_DIST=`lsb_release -is`
LINUX_DIST_VERSION=`lsb_release -rs`

echo "Distribution: $LINUX_DIST"
echo "Version: $LINUX_DIST_VERSION"

if [ ! -e $PREFIX/.aptdone -a "$1" != "--no-apt" ]; then
    echo "=== Installing OpenSceneGraph dependencies ==="
    echo "This is done system-wide with 'sudo apt-get' - so I need your password..."
    sudo apt-get -y install g++ cmake libglut-dev libreadline-dev libxmu-dev libfreetype6-dev libopenal-dev libjpeg-dev libpng12-dev libtiff4-dev libgdal1-dev gdal-bin || exit 1
    touch $PREFIX/.aptdone
fi

# Built before OSG so that OSG/FLTK examples can be built
#if [ ! -e $PREFIX/lib/libfltk.a ]; then
#    echo "=== Building FLTK ==="
#    unzip -qqn packages/fltk*.zip -d $BUILD
#    cd $BUILD/fltk*
#    ./configure --enable-threads --enable-shared --prefix=$PREFIX
#    make && make install || exit 1
#    cd - >/dev/null
#fi

if [ ! -e $PREFIX/bin/osgviewer ]; then
	echo "=== Building OpenSceneGraph ==="
	unzip -qqn packages/OpenSceneGraph-?.?.?.zip -d $BUILD
	cd $BUILD/OpenSceneGraph-?.?.?
	if [ ! -e CMakeCache.txt ]; then
	    cmake . -DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=$PREFIX \
		-DBUILD_OSG_EXAMPLES=OFF \
		|| exit 1
	fi
#		-DGDAL_INCLUDE_DIR=/usr/include/gdal \
#		-DGDAL_LIBRARY=/usr/lib/libgdal1.4.0.so \
	make && make install || exit 1
	cd - >/dev/null
fi

if [ ! -e $PREFIX/lib/liblua.a ]; then
	echo "=== Building Lua ==="
	tar xfz packages/lua*.tar.gz -C $BUILD
	cd $BUILD/lua*
	make CC="g++ -fPIC" linux && make INSTALL_TOP=$PREFIX install || exit 1
	cp -rfp doc $PREFIX/docs/dependencies/lua
	cd - >/dev/null
fi

if [ ! -e $PREFIX/bin/osgdem ]; then
	echo "=== Building VirtualPlanetBuilder"
	unzip -qqn packages/VirtualPlanetBuilder*.zip -d $BUILD
	cd $BUILD/VirtualPlanetBuilder*
	if [ ! -e CMakeCache.txt ]; then
	    cmake -D CMAKE_INCLUDE_PATH=$PREFIX/include -D CMAKE_LIBRARY_PATH=$PREFIX/lib -D CMAKE_INSTALL_PREFIX=$PREFIX . || exit 1
	fi
	make && make install || exit 1
	cd - >/dev/null
fi

. common_build_post.sh

touch $PREFIX/.depsdone



