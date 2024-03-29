# Reset release directory
if (Test-Path release) {
	Remove-Item -Path release -Recurse
}

# Copy starter project setup
Copy-Item -Path dist -Destination release -Recurse
New-Item -Type dir -Force "release/game/assets" | Out-Null

# Copy binaries
New-Item -Type dir -Force "release/bin" | Out-Null
Copy-Item -Path bin/*.dll -Destination release/bin
Copy-Item -Path bin/*.exe -Destination release/bin
Copy-Item -Path bin/license.txt -Destination release/bin

# Copy game runtime data
Copy-Item -Path runtime -Destination release/game/crystal -Recurse
Remove-Item -Path release/game/crystal/conf.lua
Remove-Item -Path release/game/crystal/main.lua
Remove-Item -Path release/game/crystal/test-data -Recurse
$test_output_dir = "release/game/crystal/test-output"
if (Test-Path $test_output_dir) {
	Remove-Item -Path $test_output_dir -Recurse
}

# Copy changelog
Copy-Item -Path CHANGELOG.md -Destination release/game/crystal

# Zip release
Compress-Archive -Path release/* -DestinationPath release/crystal.zip
