Push-Location -StackName 'DirStack'
Set-Location .\lib
cargo build --release
Pop-Location -StackName 'DirStack'
New-Item -Type dir -Force .\game\engine\ffi | Out-Null

Copy-Item .\lib\target\release\diamond.dll .\game\diamond.dll
Copy-Item .\lib\target\release\diamond.lua .\game\engine\ffi\Diamond.lua

Copy-Item .\lib\target\release\knob.dll .\game\knob.dll
Copy-Item .\lib\target\release\knob.lua .\game\engine\ffi\Knob.lua
