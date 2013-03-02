@echo off
mkdir bin include lib build
call "C:\Program Files\Microsoft Visual Studio 9.0\VC\bin\vcvars32.bat"

rem UNZIP
copy /y packages\win\unzip.exe bin\

rem CMAKE
bin\unzip -qqn packages\win\cmake*.zip -d build

rem LUA
bin\unzip -qqn packages\lua*Sources.zip -d build
cd build\lua5.1\mak.vs2008
vcbuild lua5.1.sln
cd ..\..\..

rem ODE
bin\unzip -qqn packages\ode*.zip -d build
cd build\ode-0.10.1\build
premake --target vs2008
cd vs2008
vcbuild ode.vcproj ReleaseDoubleLib
cd ..\..\..

rem OpenSceneGraph 3rd party dependencies
bin\unzip -qqn packages\win\3rdParty* -d build

rem OpenSceneGraph
bin\unzip -qqn packages\OpenSceneGraph-2.6.0.zip -d build
cd build\OpenSceneGraph-2.6.0
..\cmake-2.6.1-win32-x86\bin\cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_OSG_EXAMPLES=ON -DCMAKE_INSTALL_PATH="..\.." -G "NMake Makefiles" .
nmake /i
cd ..\..

rem UnitTest++ - manual
bin\unzip -qqn packages\unittest*.zip -d build
cd build\UnitTest++
vcexpress UnitTest++.vcnet2005.vcproj
echo === Continue when done building UnitTest++ ===
pause
cd ..\..

echo TODO Tolua++
echo TODO plib
