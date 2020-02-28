cd lib/diamond
cargo build --release
cd ../..
cp ./lib/diamond/target/release/libdiamond.so ./game
mkdir ./game/engine/ffi
cp ./lib/diamond/target/diamond.lua ./game/engine/ffi/Diamond.lua
