cd lib/diamond
cargo build --release
cd ../..

mkdir -p ./game/engine/ffi
cp ./lib/target/release/libdiamond.so ./game
cp ./lib/target/diamond.lua ./game/engine/ffi/Diamond.lua
