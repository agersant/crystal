# Reset release directory
if (Test-Path release) {
	Remove-Item -Path release -Recurse
}
New-Item -Type dir -Force "release" | Out-Null

# Package game (https://love2d.org/wiki/Game_Distribution)
Compress-Archive -Path game/* -DestinationPath release/game.love
cmd /c copy /b bin\love.exe+release\game.love release\game.exe
Compress-Archive -Path release/game.exe, bin/*.dll, bin/license.txt -DestinationPath release/game.zip

# Cleanup
Remove-Item -Path release/game.exe
Remove-Item -Path release/game.love
