#!/bin/bash

. common_build_pre.sh

if unzip --version >/dev/null 2>&1; then
	echo "unzip found"
else
	if [ -e packages/win/unzip.exe ]; then
		PATH=$PATH:$PWD/packages/win
	else
		echo "Can't find 'unzip' command..."
		exit 1
	fi
fi

if [ ! -e $PREFIX/bin/cmake.exe ]; then
	unzip -qqn packages/win/cmake*.zip -d $PREFIX
	mkdir -p $PREFIX/bin $PREFIX/share
	mv $PREFIX/cmake-*/bin/* $PREFIX/bin/
	mv $PREFIX/cmake-*/share/* $PREFIX/share/
	rm -rf $PREFIX/cmake-*
fi

# Built before OSG so that OSG/FLTK examples can be built
# FLTK png/jpeg libraries are used by OSG as well..
if [ ! -e $PREFIX/lib/libfltk.a ]; then
    echo "=== Building FLTK ==="
    unzip -qqn packages/fltk*.zip -d $BUILD
    cd $BUILD/fltk*
    ./configure --enable-threads --enable-shared --prefix=$PREFIX
    make && make install || exit 1
    cd - >/dev/null
fi

if [ ! -e $PREFIX/lib/libfreetype.a ]; then
	echo "=== Building FreeType ==="
	tar xfj packages/freetype*.tar.bz2 -C $BUILD
	cd $BUILD/freetype*
	./configure --prefix=$PREFIX && make && make install || exit 1
	cd - >/dev/null
fi

# TODO OpenAL soft needs dx80_mgw package for its dsound.h - I installed it under /c/mingw
# but this script should use it locally... need to figure out from clean MSys/MinGW installation
if [ ! -e $PREFIX/lib/libopenal.a ]; then
	echo "=== Building OpenAL Soft ==="
	tar xfj packages/openal-soft*.tar.bz2 -C $BUILD
	cd $BUILD/openal-soft*
	cmake . -G "MSYS Makefiles" -DCMAKE_INSTALL_PREFIX=$PREFIX && make && make install || exit 1
	mv $PREFIX/lib/libOpenAL32.dll.a $PREFIX/lib/libopenal.a
	cd - >/dev/null
fi

if [ ! -e $PREFIX/bin/osgviewer.exe ]; then
	echo "=== Building OpenSceneGraph ==="
	unzip -qqn packages/OpenSceneGraph-?.?.?.zip -d $BUILD
	cd $BUILD/OpenSceneGraph-?.?.?
	if [ ! -e CMakeCache.txt ]; then
	    cmake . -G "MSYS Makefiles" -DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=$PREFIX \
		-DBUILD_OSG_EXAMPLES=OFF \
		-DJPEG_LIBRARY=$PREFIX/lib/libfltk_jpeg.a -DJPEG_INCLUDE_DIR=$PREFIX/include/FL/images \
		-DPNG_LIBRARY=$PREFIX/lib/libfltk_png.a -DPNG_PNG_INCLUDE_DIR=$PREFIX/include/FL/images \
		-DZLIB_LIBRARY=$PREFIX/lib/libfltk_z.a -DZLIB_INCLUDE_DIR=$PREFIX/include/FL/images \
		-DFREETYPE_INCLUDE_DIR_freetype2=$PREFIX/include/freetype2 \
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
	make CC=g++ mingw && make INSTALL_TOP=$PREFIX install || exit 1
	cp src/lua51.dll $PREFIX/bin/
	cp -rfp doc $PREFIX/docs/dependencies/lua
	cd - >/dev/null
fi

#if [ ! -e $PREFIX/bin/osgdem ]; then
#	echo "=== Building VirtualPlanetBuilder"
#	unzip -qqn packages/VirtualPlanetBuilder*.zip -d $BUILD
#	cd $BUILD/VirtualPlanetBuilder*
#	if [ ! -e CMakeCache.txt ]; then
#	    cmake -D CMAKE_INCLUDE_PATH=$PREFIX/include -D CMAKE_LIBRARY_PATH=$PREFIX/lib -D CMAKE_INSTALL_PREFIX=$PREFIX . || exit 1
#	fi
#	make && make install || exit 1
#	cd - >/dev/null
#fi

# configure workaround here overrides the one in common_build_post.sh...
if [ ! -e $PREFIX/lib/libsndfile.a ]; then
	echo "=== Build libSndFile ==="
	tar xfz packages/libsndfile*.tar.gz -C $BUILD
	cd $BUILD/libsndfile*
	CPPFLAGS="-Dint64_t=long" ./configure --disable-flac --prefix=$PREFIX && make && make install || exit 1
	cp -rf doc $PREFIX/docs/dependencies/libsndfile
	cd - >/dev/null
fi

. common_build_post.sh

touch $PREFIX/.depsdone



