# This scripts is called by mac_build.sh and linux_build.sh and should not be called by itself

# if [ ! -e $PREFIX/bin/premake ]; then
# 	echo "=== Building Premake ==="
# 	unzip -qqn packages/premake*.zip -d $BUILD
# 	cd $BUILD/Premake*
# 	make || exit 1
# 	cp bin/premake $PREFIX/bin/
# 	cd - >/dev/null
# fi

if [ ! -e $PREFIX/lib/libUnitTest++.a ]; then
	echo "=== Building UnitTest++ ==="
	unzip -qqn packages/unittest*.zip -d $BUILD
	cd $BUILD/UnitTest*
	CXXFLAGS="-g -Wall -W" make libUnitTest++.a || exit 1
	cp -fp libUnitTest++.a $PREFIX/lib/
	mkdir -p $PREFIX/include/UnitTest++
	cp -fp src/*.h $PREFIX/include/UnitTest++/
	if [ "$OS" = "mingw" ]; then
		mkdir -p $PREFIX/include/UnitTest++/Win32
		cp -fp src/Win32/*.h $PREFIX/include/UnitTest++/Win32/
	else
		mkdir -p $PREFIX/include/UnitTest++/Posix
		cp -fp src/Posix/*.h $PREFIX/include/UnitTest++/Posix/
	fi
	cp -fp docs/UnitTest++.html $PREFIX/docs/dependencies/
	cd - >/dev/null
fi

if [ ! -e $PREFIX/lib/libTinyXML.a ]; then
	echo "=== Building TinyXML ==="
	unzip -qqn packages/tinyxml*.zip -d $BUILD
	cd $BUILD/tinyxml*
	mv tinyxml.h temp.h
	echo '#define TIXML_USE_STL' >tinyxml.h
	cat temp.h >>tinyxml.h
	rm -f temp.h
	g++ -fPIC -c tinyxml.cpp tinyxmlerror.cpp tinyxmlparser.cpp || exit 1
	ar cr libTinyXML.a *.o || exit 1
	rm -f *.o
	mkdir -p $PREFIX/include/TinyXML
	cp -fp *.h $PREFIX/include/TinyXML/
	cp -fp libTinyXML.a $PREFIX/lib/
	cp -rfp docs $PREFIX/docs/dependencies/TinyXML
	cd - >/dev/null
fi

if [ ! -e $PREFIX/bin/tolua -a ! -e $PREFIX/bin/tolua.exe ]; then
	echo "=== Building tolua++ ==="
	unzip -qqn packages/tolua*.zip -d $BUILD
	cd $BUILD/tolua*
	make -f ../../custom/tolua_$OS.make PREFIX=$PREFIX || exit 1
	make -f ../../custom/tolua_$OS.make PREFIX=$PREFIX install || exit 1
	cp -rfp doc $PREFIX/docs/dependencies/tolua
	cd - >/dev/null
fi

if [ ! -e $PREFIX/lib/libplibjs.a ]; then
	echo "=== Build plib ==="
	tar xfz packages/plib*.tar.gz -C $BUILD
	cd $BUILD/plib*
	CFLAGS="-fPIC" CXXFLAGS="-fPIC" ./configure --prefix=$PREFIX --disable-ssg --disable-ssgaux && make install || exit 1
	cd - >/dev/null
fi

if [ ! -e $PREFIX/lib/libode.a ]; then
	echo "=== Building ODE ==="
	unzip -qqn packages/ode*.zip -d $BUILD
	cd $BUILD/ode*
	CFLAGS="-fPIC" CXXFLAGS="-fPIC" ./configure --prefix=$PREFIX --with-trimesh=opcode --disable-asserts \
		&& make && make install || exit 1
	rm -rf $PREFIX/docs/dependencies/ode
	( cd ode/doc ; doxygen ) && cp -rf docs $PREFIX/docs/dependencies/ode
	cd - >/dev/null
fi

if [ ! -e $PREFIX/lib/libogg.a ]; then
	echo "=== Build OGG ==="
	tar xfz packages/libogg*.tar.gz -C $BUILD
	cd $BUILD/libogg*
	./configure --prefix=$PREFIX && make && make install || exit 1
	cp -rf doc $PREFIX/docs/dependencies/libogg
	cd - >/dev/null
fi

if [ ! -e $PREFIX/lib/libvorbis.a ]; then
	echo "=== Build Vorbis ==="
	tar xfz packages/libvorbis*.tar.gz -C $BUILD
	cd $BUILD/libvorbis*
	LDFLAGS="-L$PREFIX/lib -logg" ./configure --with-ogg=$PREFIX --prefix=$PREFIX && make && make install || exit 1
	cp -rf doc $PREFIX/docs/dependencies/libvorbis
	cd - >/dev/null
fi

#if [ ! -e $PREFIX/lib/libFLAC.a ]; then
#	echo "=== Build FLAC ==="
#	tar xfz packages/flac*.tar.gz -C $BUILD
#	cd $BUILD/flac*
#	./configure --disable-asm-optimizations --prefix=$PREFIX && make && make install || exit 1
#	cp -rf doc/html $PREFIX/docs/dependencies/flac
#	cd - >/dev/null
#fi

if [ ! -e $PREFIX/lib/libsndfile.a ]; then
	echo "=== Build libSndFile ==="
	tar xfz packages/libsndfile*.tar.gz -C $BUILD
	cd $BUILD/libsndfile*
	./configure --disable-flac --prefix=$PREFIX && make && make install || exit 1
	cp -rf doc $PREFIX/docs/dependencies/libsndfile
	cd - >/dev/null
fi

if [ ! -e $PREFIX/lib/libmpg123.la ]; then
	echo "=== Build MPG123 ==="
	tar xfz packages/mpg123*.tar.gz -C $BUILD
	cd $BUILD/mpg123*
	./configure --prefix=$PREFIX && make && make install || exit 1
	cd - >/dev/null
fi

if [ ! -e $PREFIX/lib/libRakNet.a ]; then
	echo "=== Building RakNet ==="
	unzip -qqn packages/RakNet*.zip -d $BUILD/RakNet
	cd $BUILD/RakNet
	g++ -fPIC -c -ISource Source/*.cpp || exit 1
	ar cr libRakNet.a *.o || exit 1
	rm -f *.o
	mkdir -p $PREFIX/include/RakNet
	cp -fp Source/*.h $PREFIX/include/RakNet/
	cp -fp libRakNet.a $PREFIX/lib/
	cp -rfp Help $PREFIX/docs/dependencies/RakNet
	cd - >/dev/null
fi

if [ ! -e $PREFIX/data/OpenSceneGraph-Data-?.?.? ]; then
	echo "=== Installing OpenSceneGraph-Data ==="
	unzip -qqn packages/OpenSceneGraph-Data-?.?.?.zip -d $PREFIX/data
fi

if [ ! -e $PREFIX/docs/dependencies/OpenSceneGraphReferenceDocs ]; then
	echo "=== Installing OpenSceneGraph documentation ==="
	unzip -qqn packages/OpenSceneGraphReferenceDocs*.zip -d $PREFIX/docs/dependencies
fi

if [ ! -e $PREFIX/docs/dependencies/www.cppreference.com ]; then
	echo "=== Installing cppreference documentation ==="
	tar xfz packages/cppreference*.tar.gz -C $PREFIX/docs/dependencies
fi

if [ ! -e $PREFIX/docs/dependencies/OpenAL_1_1_spec.html ]; then
	echo "=== Installing OpenAL documentation ==="
	tar xfz packages/OpenAL_1_1_spec.tar.gz -C $PREFIX/docs/dependencies
fi
