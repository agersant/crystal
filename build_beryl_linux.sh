cd lib
mkdir builddir
CC=clang meson builddir --backend ninja --buildtype release
cd builddir
ninja
cd ../..
cp ./lib/builddir/libberyl.so ./game

