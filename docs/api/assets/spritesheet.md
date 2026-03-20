---
parent: crystal.assets
grand_parent: API Reference
nav_order: 2
---

# crystal.Spritesheet

Spritesheets are the combination of a texture holding multiple frames of animation, and metadata on how to play said animations. The recommended way to create spritesheets in a format Crystal can load is to export them from [Aseprite](https://www.aseprite.org/).

When exporting, make sure to:

- Check both `Output File` and `JSON Data`
- Under `JSON Data`, select `Array` and not `Hash`

![aseprite-export-dialog.png]

When loading the resulting `.json` file in Crystal, each Aseprite Tag is imported as an [Animation](animation). If the timeline has nested tags, the inner tags will become [Sequence](sequence) instead. For example, consider this timeline setup in Aseprite:

![aseprite-timeline.png]

In Crystal this becomes:

- One `idle` animation containing 4 sequences (`S`, `E`, `N`, `W`).
- One `walk` animation containing 4 sequences (`S`, `E`, `N`, `W`).
- One `win-pose` animation containing a single sequence named `default`.

{: .note}
The [AnimatedSprite](/crystal/api/graphics/animated_sprite) component can drive playback of spritesheet animations and draw them over time.

## Constructor

You cannot construct spritesheets manually. Use [crystal.assets.get](get) to load them from disk.

## Methods

| Name                               | Description                                                                |
| :--------------------------------- | :------------------------------------------------------------------------- |
| [animation](spritesheet_animation) | Retrieves an animation by name.                                            |
| [image](spritesheet_image)         | Returns the `love.Image` containing the texture data for this spritesheet. |

## Examples

```lua
local spritesheet = crystal.assets.get("assets/sprites/hero.json");
local walk = spritesheet:animation("walk");
local sequence = walk:sequence("N");
print(sequence:duration());
```

```lua
local spritesheet = crystal.assets.get("assets/sprites/hero.json");
local win_pose = spritesheet:animation("win_pose");
local sequence = win_pose:sequence(); -- This animation only has one sequence, so we can omit its name
print(sequence:duration());
```
