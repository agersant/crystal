Push-Location -StackName 'crystal'
Set-Location .\lib
Push-Location -StackName 'lib'

# Build LuaJIT so we can link against it when compiling Lua modules
Set-Location .\luajit\src
$VSWhere = [System.Environment]::ExpandEnvironmentVariables("%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe")
$installationPath = & "$VSWhere" -products * -prerelease -latest -property installationPath
cmd.exe -/c "`"$installationPath\Common7\Tools\vsdevcmd.bat`" -arch=amd64 && .\msvcbuild.bat"

# Build Lua modules implemented in Rust
Pop-Location -StackName 'lib'
cargo build --release

# Copy Lua modules to game directory
Pop-Location -StackName 'crystal'
New-Item -Type dir -Force .\bin | Out-Null
Copy-Item .\lib\target\release\diamond.dll .\game\diamond.dll
Copy-Item .\lib\target\release\knob.dll .\game\knob.dll
