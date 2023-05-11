---
has_children: false
has_toc: false
nav_order: 1
---

# Getting Started

## Setup Instructions

Crystal is only supported on Windows.

1. Download Crystal's [latest release](https://github.com/agersant/crystal/releases)
2. Extract the archive
3. From the top-level directory of the archive, run `bin\lovec.exe game`. This should display a `Hello World` window.
4. Start making changes to `game\main.lua` and they should be immediately reflected in the game window.

## Project Structure

In addition to `main.lua` and a suggested directory to store [assets](/crystal/api/assets), the starter project also comes with:

- A `bin` directory you should leave alone (other than possibly adding other `dll` your game needs).
- A `.github` directory containing a Github Actions CI setup to runs tests (if any) and build the game on every push. Feel free to edit this or remove it entirely.
- A game packaging script (`package.ps1`) used by the above CI process to [package](https://love2d.org/wiki/Game_Distribution) the game together. Feel free to edit this or remove it entirely.
- A `crystal.json` and default program icon used by the packaging script.

The vast majority of you work should happen under the `/game` directory, which is a regular LOVE project with the `crystal` Lua library added.

## Crystal & LOVE

Crystal is not a replacement for LOVE. Everything available in LOVE is also usable within a Crystal project.

You can use as much or as little as you want from the [Crystal API](https://agersant.github.io/crystal/). Similar to LOVE, Crystal gives you tools to build your game without imposing too much predetermined structure.

By default, Crystal overwrites the following LOVE callbacks:

- `love.load`
- `love.update`
- `love.draw`
- `love.run` (only when running [tests](/crystal/api/test))
- `love.keypressed`
- `love.keyreleased`
- `love.gamepadpressed`
- `love.gamepadreleased`
- `love.textinput`

If you choose to implement these callbacks yourself, make sure to call the `crystal.*` equivalent before or after your own code:

```lua
love.update = function(dt)
  -- Your update code here
  crystal.update(dt);
end

love.daw = function()
  crystal.draw();
  -- Your draw code here
end
```
