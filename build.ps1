$crystal = (Get-Location).Path
Set-Location lib
$lib = (Get-Location).Path

# Reset bin directory
Set-Location $crystal
if (Test-Path bin) {
	Remove-Item -Path bin -Recurse
}
New-Item -Type dir -Force "bin" | Out-Null

# Download Love2D
Set-Location $crystal
$zip = New-TemporaryFile
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri "https://github.com/love2d/love/releases/download/11.3/love-11.3-win64.zip" -OutFile $zip
Expand-Archive $zip -DestinationPath "bin" -Force
Remove-Item $zip
Get-ChildItem -Path "bin" -Recurse -File | Move-Item -Destination "bin"
Get-ChildItem -Path "bin" -Recurse -Directory | Remove-Item

# Build LuaJIT so we can link against it when compiling Lua modules
Set-Location $lib
Set-Location luajit\src
$VSWhere = [System.Environment]::ExpandEnvironmentVariables("%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe")
$installationPath = & "$VSWhere" -products * -prerelease -latest -property installationPath
cmd.exe -/c "`"$installationPath\Common7\Tools\vsdevcmd.bat`" -arch=amd64 && .\msvcbuild.bat"

# Build Lua modules implemented in Rust
Set-Location $lib
cargo build --release

# Copy Lua modules to game directory
Set-Location $crystal
Copy-Item lib\target\release\diamond.dll bin\diamond.dll
Copy-Item lib\target\release\knob.dll bin\knob.dll
