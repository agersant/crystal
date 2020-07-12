cd lib/diamond
cargo build --release
cd ../..
cp ./lib/diamond/target/release/diamond.dll ./game
cp ./lib/diamond/target/diamond.lua ./game/engine/ffi/Diamond.lua
