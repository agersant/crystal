[![Build Status](https://travis-ci.org/agersant/crystal.svg?branch=master)](https://travis-ci.org/agersant/crystal)

# Build instructions

## Windows

### Dependencies
1. Install the 32-bit version of [Love2D](https://love2d.org/) (0.10.2 as of this writing)
1. If you plan to run unit tests, install the 32-bit version of [LuaJIT](http://luajit.org/) (2.1.0-beta3 as of this writing)
4. Download the [Visual C++ Build Tools](http://landinghub.visualstudio.com/visual-cpp-build-tools)
5. Run the installer, making sure the "Windows 8.1 SDK" feature is part of the installation (even on Windows 10)
2. Add `C:\Program Files (x86)\LOVE` to your path
3. Add `C:\Program Files (x86)\LuaJIT\2.1.0-beta3` to your path
5. Add `C:\Program Files (x86)\MSBuild\14.0\Bin` to your path

### Build and run using Visual Studio Code
1. Open this project in Visual Studio and run the task `Build Beryl (Windows Release)`
2. (Optional) Run the task `Run Tests`
3. Run the task `Run Game`
4. Game is running! Press ` to access the ingame CLI

### Build and run without Visual Studio Code
1. In `crystal\source\code\beryl`, open a command prompt and execute `msbuild /p:Configuration=Release`
2. Copy the resulting dll from `crystal\source\code\beryl\bin\Release` to `crystal\game`
3. (Optional) Open a command prompt in `crystal\game` and execute `luajit Tests.lua`
4. Open a command prompt in `crystal\game` and execute `love .`
5. Game is running! Press ` to access the ingame CLI