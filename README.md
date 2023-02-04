[![Actions Status](https://github.com/agersant/crystal/workflows/Build/badge.svg)](https://github.com/agersant/crystal/actions) [![codecov.io](http://codecov.io/github/agersant/crystal/branch/master/graphs/badge.svg)](http://codecov.io/github/agersant/crystal)

This project is a playground for me to write Lua and Rust game code, experimenting with ideas (old and new) and focusing on features I want to explore outside of a shipping project.

This project uses Love 2D to access SDL's rendering and input polling capabilities from Lua.

Some code highlights:

- Ref-counted [asset loading/unloading system](game/engine/resources/Assets.lua) with support for hot-reload
- Co-routine based [scripting system](game/engine/script/Script.lua) which makes it easy to write gameplay features synchronously (example: [Basic NPC](game/arpg/content/NPC.lua), [Dash skill](game/arpg/content/job/warrior/Dash.lua))
- 'Many to Many' [keybinding system](game/engine/input/InputDevice.lua)

# Feature Screenshots

## Collisions

Maps are authored using the [Tiled](http://www.mapeditor.org/) map-editor, which can embed collision data per tile. Physics in Love 2D are implemented using Box2D, but it would be very inefficient to spawn a Box2D object for each collidable tile. Instead, Crystal joins tiles on the map into larger polygons, as illustrated below. For performance, this merging of collision data is implemented in a Rust module called `Diamond`, located under `lib/diamond`.

<img src="readme/crystal_physics_overlay.gif?raw=true" height="429"/>

## Navmesh Generation

Because the collision data is so free-form, we would be losing a lot of precision from using grid-based pathfinding. This was a great excuse to implement pathfinding using navmeshes. At the moment, the mesh generation is performed upon map load but could easily move to some offline build phase. Just like collision mesh generation, this is handled by the Rust module `Diamond`.

<img src="readme/crystal_navmesh_overlay.gif?raw=true" height="429"/>

## Spawning entities

This screenshot illustrates usage of the dev CLI to spawn entities of various types (using the same sprite), and a tidbit of combat and UI.

<img src="readme/crystal_spawn.gif?raw=true" height="429"/>

# Build instructions

1. Install the stable version of the [Rust compiler](https://www.rust-lang.org/learn/get-started) (pick MSVC toolchain if prompted)
2. Clone this repository and submodules
3. From the top level of this repository, execute `.\build.ps1`. This downloads the correct version of Love2D and compiles crystal native libraries.
4. From the top level of this repository, execute `.\bin\love.exe game` to launch the game
