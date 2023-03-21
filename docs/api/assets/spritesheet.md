---
parent: crystal.assets
grand_parent: API Reference
nav_order: 2
---

# crystal.Spritesheet

## Overview

Spritesheets are the combination of a texture holding multiple frames of animation, and metadata on how to play said animations.

A few definitions:

- A spritesheet contains a number of animations. There should be one spritesheet for each animated character or object in your game.
- An animation is an action the character or object can perform, like `"walk` or `"jump"`. Each animation is composed of multiple sequences, showing the same action from different angles (eg. facing left vs facing right).
- A sequence is a list of keyframes (images) to play in order to see the character perform the action in a specific direction. Keyframes contain metadata like visual duration, offset and hitboxes.

The recommended way to create spritesheets in a format Crystal can load is to use [Tiger](https://agersant.itch.io/tiger). To export a spritesheet that is compatible with Crystal, you must:

- Use this premade [Tiger template](crystal.template) in Tiger's `Export As` dialog.
- Also in Tiger's `Export As` dialog, select the folder containing you game's `main.lua` as the `Metadata Path Root`.
- Name the metadata file with a `.lua` extension.

If you are looking to generate spritesheets manually or through other means, you can infer the format from this [minimal example](example_spritesheet.lua).

## Constructor

You cannot construct spritesheets manually. Use [crystal.assets.get](get) to load them from disk.

## Methods

| Name                               | Description                                                                |
| :--------------------------------- | :------------------------------------------------------------------------- |
| [animation](spritesheet_animation) | Retrieves an animation by name.                                            |
| [image](spritesheet_image)         | Returns the `love.Image` containing the texture data for this spritesheet. |

## Examples

```lua
local spritesheet = crystal.assets.get("assets/sprites/hero.lua");
local walk = spritesheet:animation("walk");
local sequence = walk:sequence(0);
print(sequence:duration());
```
