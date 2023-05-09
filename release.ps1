$crystal = (Get-Location).Path

# Reset release directory
Set-Location $crystal
if (Test-Path release) {
	Remove-Item -Path release -Recurse
}

# Copy binaries
New-Item -Type dir -Force "release/bin" | Out-Null
Copy-Item -Path bin/*.dll -Destination release/bin
Copy-Item -Path bin/*.exe -Destination release/bin
Copy-Item -Path bin/license.txt -Destination release/bin

# Copy game runtime data
New-Item -Type dir -Force "release/game" | Out-Null
Copy-Item -Path runtime -Destination release/game/crystal -Recurse
Remove-Item -Path release/game/crystal/conf.lua
Remove-Item -Path release/game/crystal/main.lua
Remove-Item -Path release/game/crystal/test-data -Recurse
Remove-Item -Path release/game/crystal/test-output -Recurse

# Copy sample project setup
Copy-Item -Path dist/starter_game/* -Destination release/game -Recurse
Copy-Item -Path dist/package.ps1 -Destination release