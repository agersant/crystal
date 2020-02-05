[![Actions Status](https://github.com/agersant/crystal/workflows/Build/badge.svg)](https://github.com/agersant/crystal/actions)

This project is a playground for me to write Lua and C game code, experimenting with ideas (old and new) and focusing on features I want to explore outside of a shipping project.

This project uses Love 2D to access SDL's rendering and input polling capabilities from Lua.

Some code highlights:

- Ref-counted [asset loading/unloading system](game/engine/resources/Assets.lua) with support for hot-reload
- Co-routine based [scripting system](game/engine/script/Script.lua) which makes it easy to write gameplay features synchronously (example: [Basic NPC](game/content/NPC.lua), [Dash skill](game/content/skill/Dash.lua))
- 'Many to Many' [keybinding system](game/engine/input/InputDevice.lua)

# Feature Screenshots

## Collisions

Maps are authored using the [Tiled](http://www.mapeditor.org/) map-editor, which can embed collision data per tile. Physics in Love 2D are implemented using Box2D, but it would be very inefficient to spawn a Box2D object for each collidable tile. Instead, Crystal joins tiles on the map into larger polygons, as illustrated below:

<img src="docs/readme/crystal_physics_overlay.gif?raw=true" height="429"/>

Crystal is very accepting of elaborate collision data. A single tile can have multiple collision shapes, and they can be any polygonal shapes which isn't self-intersecting.

## Navmesh Generation

Because the collision data is so free-form, we would be losing a lot of precision from using grid-based pathfinding. This was a great excuse to implement pathfinding using navmeshes. This project includes a C module called Beryl (under `lib/beryl`) whose sole responsabilities are generating and querying navmeshes. At the moment, the mesh generation is performed upon map load but could easily move to some offline build phase.

<img src="docs/readme/crystal_navmesh_overlay.gif?raw=true" height="429"/>

## Spawning entities

This screenshot illustrates usage of the dev CLI to spawn entities of various types (using the same sprite), and a tidbit of combat and UI.

<img src="docs/readme/crystal_spawn.gif?raw=true" height="429"/>

# Build instructions

## Windows

### Dependencies
1. Install the 64-bit version of [Love2D](https://love2d.org/) (0.11.3 as of this writing)
2. Install the [Visual C++ Build Tools](http://landinghub.visualstudio.com/visual-cpp-build-tools), selecting `Desktop Development With C++`
3. Install [Meson](https://github.com/mesonbuild/meson/releases)
4. Add `C:\Program Files\LOVE` to your path
4. Add `C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build` to your path (this may be slightly inaccurate if you didn't install the community edition of the Visual C++ build tools)

### Build and run without Visual Studio Code
1. From the top level of this repository, execute the `build_beryl_windows.ps1` Powershell script
2. From `crystal\game`, execute `love .`
3. Game is running! Press ` to access the ingame CLI

### Build and run using Visual Studio Code
1. Open this project in Visual Studio and run the task `Build Beryl`
2. Run the task `Launch Game`
3. Game is running! Press ` to access the ingame CLI

