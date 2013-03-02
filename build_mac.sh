#!/bin/bash

. common_build_pre.sh

mkdir -p $PREFIX/Frameworks 

if [ ! -e $PREFIX/bin/cmake ]; then
	echo "=== Installing CMake ==="
	tar xfz packages/mac/cmake*Darwin*.tar.gz
	mv cmake*/CMake*.app $PREFIX/bin/
	rm -rf cmake*
	cd $PREFIX/bin
	ln -s CMake*.app/Contents/bin/cmake
	ln -s CMake*.app/Contents/bin/ccmake
	ln -s CMake*.app/Contents/bin/ctest
	ln -s CMake*.app/Contents/bin/cpack
	ln -s CMake*.app/Contents/bin/cmakexbuild
	ln -s CMake*.app/Contents/bin/cmake-gui
	cd - >/dev/null
fi

if [ ! -e $PREFIX/Frameworks/GDAL.framework ]; then
	echo "=== Installing UnixCompatFrameworks ==="
	unzip -qqn packages/mac/UnixCompatFrameworks.zip -d $BUILD
	mv $BUILD/UnixCompatFrameworks/*.framework $PREFIX/Frameworks/
fi

if [ ! -e $PREFIX/bin/osgviewer ]; then
	echo "=== Building OpenSceneGraph ==="
	unzip -qqn packages/OpenSceneGraph-?.?.?.zip -d $BUILD
	cd $BUILD/OpenSceneGraph-?.?.?
	if [ ! -e CMakeCache.txt ]; then
		cmake . -DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_INSTALL_PREFIX=$PREFIX \
			-DBUILD_OSG_EXAMPLES=ON \
			-DGDAL_INCLUDE_DIR=$PREFIX/Frameworks/GDAL.framework/Headers/ \
			-DGDAL_LIBRARY=$PREFIX/Frameworks/GDAL.framework || exit 1
	fi
	make && make install || exit 1
	cd - >/dev/null
fi

# Built before OSG so that OSG/FLTK examples can be built
if [ ! -e $PREFIX/lib/libfltk.a ]; then
    echo "=== Building FLTK ==="
    unzip -qqn packages/fltk*.zip -d $BUILD
    cd $BUILD/fltk*
    ./configure --enable-threads --enable-shared --prefix=$PREFIX
    make && make install || exit 1
    cd - >/dev/null
fi

if [ ! -e $PREFIX/lib/liblua.a ]; then
	echo "=== Building Lua ==="
	tar xfz packages/lua*.tar.gz -C $BUILD
	cd $BUILD/lua*
	make CC=g++ CFLAGS="-arch i386 -arch ppc -DLUA_USE_LINUX -O2" LIBS="-arch i386 -arch ppc -lreadline" macosx && make INSTALL_TOP=$PREFIX install || exit 1
	cp -rfp doc $PREFIX/docs/dependencies/lua
	cd - >/dev/null
fi

if [ ! -e $PREFIX/bin/osgdem ]; then
	echo "=== Building VirtualPlanetBuilder"
	unzip -qqn packages/VirtualPlanetBuilder*.zip -d $BUILD
	cd $BUILD/VirtualPlanetBuilder*
	cmake -D CMAKE_INCLUDE_PATH=$PREFIX/include -D CMAKE_LIBRARY_PATH=$PREFIX/lib -D CMAKE_INSTALL_PREFIX=$PREFIX -D GDAL_INCLUDE_DIR=$PREFIX/Frameworks/GDAL.framework/Headers -D GDAL_LIBRARY=$PREFIX/Frameworks/GDAL.framework . || exit 1
	make && make install || exit 1
	cd - >/dev/null
fi


. common_build_post.sh

touch $PREFIX/.depsdone



