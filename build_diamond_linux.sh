cd lib/diamond
cargo build --release
cd ../..

mkdir -p ./game/engine/ffi
cp ./lib/diamond/target/release/libdiamond.so ./game
cp ./lib/diamond/target/diamond.lua ./game/engine/ffi/Diamond.lua
