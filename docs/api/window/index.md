---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.window

This module handles scaling and letterboxing to support arbitrary window sizes.

To use this module effectively:

1. Set a native height for your game with [window.set_native_height](set_native_height). This is will be your unscaled viewport height.
2. Specify the aspect ratios you want to support via [set_aspect_ratio_limits](set_aspect_ratio_limits).
3. Choose how your game should be upscaled via [set_scaling_mode](set_scaling_mode) and (optionally) [set_safe_area](set_safe_area).

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
- The `crop_or_squish` scaling mode automatically chooses between upscaling by an integer factor that can cover the whole window (cropping some content), or upscaling by a non-integer factor. The cropping strategy is selected if the amount to crop does not exceed the [safe area](set_safe_area).  
  For example, a safe area of `0.95` will allow up to 5% of the screen to get cropped in order to use an integer scaling factor. If the window size is such that more than 5% of the game would get cropped, the viewport is scaled by a non-integer factor instead.

## Functions

| Name                                                              | Description                                                                          |
| :---------------------------------------------------------------- | :----------------------------------------------------------------------------------- |
| [crystal.window.draw](draw)                                       | Draws on the screen with scaling and letterboxing transforms applied.                |
| [crystal.window.draw_native](draw_native)                         | Draws on a viewport-sized canvas, and then draws the canvas on the screen.           |
| [crystal.window.set_aspect_ratio_limits](set_aspect_ratio_limits) | Sets the narrowest and widest aspect ratios the game supports.                       |
| [crystal.window.set_native_height](set_native_height)             | Sets the game's native-height (in pixels) from which it can be upscaled.             |
| [crystal.window.set_safe_area](set_safe_area)                     | Sets how much of the game can be cropped to preserve pixel-perfect scaling.          |
| [crystal.window.set_scaling_mode](set_scaling_mode)               | Sets how the game draws at resolutions larger than its native size.                  |
| [crystal.window.viewport_scale](viewport_scale)                   | Returns the integer scaling factor applied to the game when upscaling it.            |
| [crystal.window.viewport_size](viewport_size)                     | Returns the width and height at which the game is being rendered (before upscaling). |
