---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.window

This module handles scaling and letterboxing to support arbitrary window sizes. It is designed to preserve integrity of pixel-art and support multiple aspect ratios.

To use this module effectively:

1. Set a native height for your game with [window.set_native_height](set_native_height). This is will be your unscaled viewport height.
2. Specify the aspect ratios you want to support via [set_aspect_ratio_limits](set_aspect_ratio_limits).
3. Choose how your game should be upscaled via [set_scaling_mode](set_scaling_mode) and (optionally) [set_safe_area](set_safe_area).
4. Draw game content using [draw_upscaled](draw_upscaled). Draw debug content using [draw_native](draw_native).

## Example

Let's walk through an example of setting up a 2D platformer or metroidvania game in the style of the Super Nintendo:

1. Our artwork is originally designed for a resolution of `256x224` so our native height is `224`.
2. `256x224` is already a very narrow aspect ratio (almost square!) so we can settle for that as our minimum aspect ratio. In general, you can decide on a minimum aspect ratio by picturing a scene in your game. How much can you crop on the sides until crucial gameplay or narrative elements go missing?
3. For the maximum aspect ratio: how much can you expand a scene horizontally before you run out of visuals to display? This is your maximum aspect ratio.  
   Most computer monitors are `16/9` or wider so we will make sure to support that by making it our maximum aspect ratio. This means our game viewport will be anywhere from `256x224` to `398x224`, depending on the window aspect ratio.  
   If you want to support only one specific aspect ratio, you can use the same value for the minimum and maximum limits.
4. We don't want to compromise on our pixel art at all (no cropping, only integer scaling) so we set the scaling mode to `pixel_perfect`.

```lua
crystal.window.set_native_height(224);
crystal.window.set_aspect_ratio_limits(256/224, 16/9);
crystal.window.set_scaling_mode("pixel_perfect");
```

## Understanding scaling modes

Scaling modes come into play when the window size is not an integer multiple of the viewport size:

- The `none` scaling mode does not upscale the game at all. The viewport is centered in the game window.
- The `pixel_perfect` scaling mode upscales the game by the largest possible integer (2x, 3x, etc.) without cropping it. The upscaled result is centered in the game window.
- The `crop_or_squish` scaling mode upscales the game by the an integer factor sufficient to cover the window, and then either crops it or squishes it. Cropping is selected if the amount to crop does not exceed the [safe area](set_safe_area).  
  For example, a safe area of `0.95` will allow up to 5% of the screen to get cropped in order to preserve pixel-perfect rendering. If the window size is such that more than 5% of the game would get cropped, the upscaled viewport is squished instead (with a non-integer factor!).

## Understanding draw_upscaled VS draw_native

Both of these functions expect you to draw content within the [game viewport](viewport_size). The difference is:

[draw_upscaled](draw_upscaled) renders to an intermediate (viewport-sized) canvas before upscaling to the screen. This ensures circles or other geometric shapes drawn via LOVE drawing functions are pixelated like the rest of the game. This also sidesteps potential issues related to texture bleeding or small gaps between tiles.

[draw_native](draw_native) draws directly to the game screen using an appropriate [love.graphics.scale](https://love2d.org/wiki/love.graphics.scale) transform. This allows circles or other geometric shapes drawn via LOVE drawing function to look crisp (high-resolution). Since LOVE point size is unaffected by scale transforms, you can multiply values by the [viewport scale](viewport_scale) when [setting point sizes](https://love2d.org/wiki/love.graphics.setPointSize).

If your game does not use pixel-art, you may draw everything via [draw_native](draw_native).

## Functions

| Name                                                              | Description                                                                          |
| :---------------------------------------------------------------- | :----------------------------------------------------------------------------------- |
| [crystal.window.draw_native](draw_native)                         | Draws on the screen with scaling and letterboxing transforms applied.                |
| [crystal.window.draw_upscaled](draw_upscaled)                     | Draws on a native-height canvas, then applies scaling and letterboxing transforms.   |
| [crystal.window.set_aspect_ratio_limits](set_aspect_ratio_limits) | Sets the narrowest and widest aspect ratios the game support.                        |
| [crystal.window.set_native_height](set_native_height)             | Sets the game's native-height (in pixels) from which it can be upscaled.             |
| [crystal.window.set_safe_area](set_safe_area)                     | Sets how much of the game can be cropped to preserve pixel-perfect scaling.          |
| [crystal.window.set_scaling_mode](set_scaling_mode)               | Sets how the game should draw at resolutions larger than its native size.            |
| [crystal.window.viewport_scale](viewport_scale)                   | Returns the integer scaling factor applied to the game when upscaling it.            |
| [crystal.window.viewport_size](viewport_size)                     | Returns the width and height at which the game is being rendered (before upscaling). |
