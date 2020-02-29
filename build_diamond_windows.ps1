Push-Location -StackName 'DirStack'
Set-Location .\lib\diamond
cargo build --release
Pop-Location -StackName 'DirStack'
New-Item -Type dir .\game\engine\ffi
Copy-Item .\lib\target\release\diamond.dll .\game\diamond.dll
Copy-Item .\lib\target\diamond.lua .\game\engine\ffi\Diamond.lua
