cd lib
cargo build --release
cd ..

mkdir -p ./game/engine/ffi

cp ./lib/target/release/libdiamond.so ./game
cp ./lib/target/release/diamond.lua ./game/engine/ffi/Diamond.lua

cp ./lib/target/release/libknob.so ./game
cp ./lib/target/release/knob.lua ./game/engine/ffi/knob.lua
