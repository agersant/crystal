Push-Location -StackName 'DirStack'
Set-Location .\lib\diamond
cargo build --release
Pop-Location -StackName 'DirStack'
New-Item -Type dir -Force .\game\engine\ffi | Out-Null
Copy-Item .\lib\target\release\diamond.dll .\game\diamond.dll
Copy-Item .\lib\target\release\diamond.lua .\game\engine\ffi\Diamond.lua
