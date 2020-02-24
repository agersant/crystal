Push-Location -StackName 'DirStack'
Set-Location .\lib\diamond
cargo build --release
Pop-Location -StackName 'DirStack'
Copy-Item .\lib\diamond\target\release\diamond.dll .\game
Copy-Item .\lib\diamond\ffi\Diamond.lua .\game\engine\ffi
