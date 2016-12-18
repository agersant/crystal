[![Build Status](https://travis-ci.org/agersant/crystal.svg?branch=master)](https://travis-ci.org/agersant/crystal)

# Build instructions

## Windows

1. Install the 32-bit version of [Love2D](https://love2d.org/)
2. Add `C:\Program Files (x86)\LOVE` to your path if necessary
3. Download the [Visual C++ Build Tools](http://landinghub.visualstudio.com/visual-cpp-build-tools)
4. Run the installer, making sure the "Windows 8.1 SDK" feature is part of the installation (even on Windows 10)
5. Add `C:\Program Files (x86)\MSBuild\14.0\Bin` to your path if necessary
6. In crystal\source\code\beryl, open a command prompt and execute `msbuild /p:Configuration=Release`
7. Copy the resulting dll from `crystal\source\code\beryl\bin\Release` to `crystal\game`
8. Open a command prompt in `crystal\game` and execute `love .`
9. Game is running! Press ` to access the ingame CLI