
# Read crystal.json
$config = Get-Content -Raw -Path crystal.json | ConvertFrom-Json

$archive = $config.archive_name
if (!$archive) {
	throw "Missing archive_name from crystal.json"
}

$executable = $config.executable_name
if (!$executable) {
	throw "Missing executable_name from crystal.json"
}

$icon = $config.executable_icon
if (!$icon) {
	throw "Missing executable_icon from crystal.json"
}

# Reset release directory
if (Test-Path release) {
	Remove-Item -Path release -Recurse
}
New-Item -Type dir -Force "release" | Out-Null

# Replace love.exe icon with game icon
Copy-Item  bin/love.exe release/love.exe
bin/nacre.exe --executable release/love.exe --icon $icon

# Combine love.exe with game content (https://love2d.org/wiki/Game_Distribution)
Compress-Archive -Path game/* -DestinationPath release/game.love
cmd /c copy /b release\love.exe+release\game.love "release\$executable" > NUL
Remove-Item -Path release/game.love
Remove-Item -Path release/love.exe

# Add dependencies
Copy-Item bin/*.dll, bin/license.txt release

# Zip everything together
Compress-Archive -Path release/* -DestinationPath release/$archive
