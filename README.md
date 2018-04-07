[![Build Status](https://travis-ci.org/agersant/crystal.svg?branch=master)](https://travis-ci.org/agersant/crystal)

This project is a playground for me to write Lua and C game code, experimenting with ideas (old and new) and focusing on features I want to explore outside of a shipping project.

This project uses Love 2D to access SDL's rendering and input polling capabilities from Lua.

Some code highlights:

- Ref-counted [asset loading/unloading system](game/src/resources/Assets.lua) with support for hot-reload
- Co-routine based [scripting system](game/src/scene/Script.lua) which makes it easy to write gameplay features synchronously (example: [Basic NPC](game/src/content/NPC.lua), [Dash skill](game/src/content/skill/Dash.lua))
- 'Many to Many' [keybinding system](game/src/input/InputDevice.lua)

# Feature Screenshots

## Collisions

Maps are authored using the [Tiled](http://www.mapeditor.org/) map-editor, which can embed collision data per tile. Physics in Love 2D are implemented using Box2D, but it would be very inefficient to spawn a Box2D object for each collidable tile. Instead, Crystal joins tiles on the map into larger polygons, as illustrated below:

<img src="docs/readme/crystal_physics_overlay.gif?raw=true" height="429"/>

Crystal is very accepting of elaborate collision data. A single tile can have multiple collision shapes, and they can be any polygonal shapes which isn't self-intersecting.

## Navmesh Generation

Because the collision data is so free-form, we would be losing a lot of precision from using grid-based pathfinding. This was a great excuse to implement pathfinding using navmeshes. This project includes a C module called Beryl (under `source/code/beryl`) whose sole responsabilities are generating and querying navmeshes. At the moment, the mesh generation is performed upon map load but could easily move to some offline build phase.

<img src="docs/readme/crystal_navmesh_overlay.gif?raw=true" height="429"/>

## Spawning entities

This screenshot illustrates usage of the dev CLI to spawn entities of various types (using the same sprite), and a tidbit of combat and UI.

<img src="docs/readme/crystal_spawn.gif?raw=true" height="429"/>

# Build instructions

## Windows

### Dependencies
1. Install the 32-bit version of [Love2D](https://love2d.org/) (0.10.2 as of this writing)
2. Download the [Visual C++ Build Tools](http://landinghub.visualstudio.com/visual-cpp-build-tools)
3. Run the installer, making sure the "Windows 8.1 SDK" feature is part of the installation (even on Windows 10)
4. Add `C:\Program Files (x86)\LOVE` to your path
5. Add `C:\Program Files (x86)\MSBuild\14.0\Bin` to your path

### Build and run using Visual Studio Code
1. Open this project in Visual Studio and run the task `Build Beryl (Windows Release)`
2. (Optional) Run the task `Run Tests`
3. Run the task `Run Game`
4. Game is running! Press ` to access the ingame CLI

### Build and run without Visual Studio Code
1. In `crystal\source\code\beryl`, open a command prompt and execute `msbuild /p:Configuration=Release`
2. Copy the resulting dll from `crystal\source\code\beryl\bin\Release` to `crystal\game`
3. (Optional) Open a command prompt in `crystal\game` and execute `love . /test`
4. Open a command prompt in `crystal\game` and execute `love .`
5. Game is running! Press ` to access the ingame CLI
