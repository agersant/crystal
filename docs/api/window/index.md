---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.window

This module handles scaling and letterboxing to support arbitrary window sizes. It is designed to support arbitrary resolutions, while preserving integrity of pixel-art games and supporting arbitrary aspect ratios.

To use this module effectively:

1. Set a native height for your game with [crystal.window.set_native_height](set_native_height). This is will be your unscaled viewport height.
2. Specify the aspect ratios you want to support via [crystal.window.set_aspect_ratio_limits](set_aspect_ratio_limits).
3. Choose how your game should be upscaled via [crystal.window.set_scaling_mode](set_scaling_mode) and (optionally) [crystal.window.set_safe_area](set_safe_area).
4. Draw game content through [crystal.window.draw_upscaled](draw_upscaled) and debug content through [crystal.window.draw_native](draw_native).

## Example

Let's walk through an example of setting up a 2D platformer or metroidvania game in the style of the Super Nintendo:

1. Our artwork is originally designed for a resolution of `256x240` so our native height is `240`.
2. `256x240` is already a very narrow aspect ratio (almost square!) so we can settle for that (`256/240` or `1.066`) as our minimum aspect ratio. In general, you can decide on a minimum aspect ratio by picturing a dialog between two characters in your game. How narrow can you let the screen get before the characters are no longer both on screen and the scene makes no sense?
3. For the maximum aspect ratio, consider a fixed scene in an open field. How wide can you let the scene get before you run out of visuals to display and resort to black bars? This is your maximum aspect ratio. Most computer monitors are `16/9` or wider so it's often a good idea to support at least that. Ultrawide monitors often have an aspect ratio of `21/9` so that's also a good upper limit if you want to almost all players to experience your game with no letterboxing. Assuming we go with `16/9`, our game viewport will be anywhere from `256x240` to `427x240`.
4. We don't want to compromise on our pixel art at all (no cropping, no rescaling) so we set the scaling mode to `pixel_perfect`.

## Understanding scaling modes

Scaling the game viewport (anywhere from `256x240` to `427x240` in the example above) to the window size is easy when the window size is an integer multiple of the viewport size: we simply upscale the visuals with this integer zoom and the visuals are perfectly crisp.

When the window size is not a multiple of the viewport size, the scaling mode decides how to resize the game:

- The `none` scaling mode does not upscale the game at all. The viewport is centered in the game window.
- The `pixel_perfect` scaling mode scales the game by the largest possible integer (2x, 3x, etc.) without cropping it.
- The `crop_or_squish` scaling mode scales the game by the an integer factor sufficient to cover the whole screen, and then either crops it or squishes it to fit on the screen. Cropping is selected if the cropped content is outside of the [safe area](set_safe_area). For example, a safe area of `0.95` will allow 5% of the screen to get cropped to preserve pixel-perfect rendering.

## Understanding draw_upscaled VS draw_native

Both of these functions expect you to draw content within the [game viewport](viewport_size). The difference is:

[crystal.window.draw_upscaled](draw_upscaled) renders to an intermediate (viewport-sized) canvas before upscaling to the screen. This ensures circles or other geometric shapes drawn via LOVE drawing functions are pixelated like the rest of the game. This also sidesteps potential issues related to texture bleeding or small gaps between tiles.

[crystal.window.draw_native](draw_native) draws directly to the game screen using an appropriate [love.graphics.scale](https://love2d.org/wiki/love.graphics.scale) transform. This allows circles or other geometric shapes drawn via LOVE drawing function to look crisp (high-resolution). Since LOVE point size is unaffected by scale transforms, you can multiply values by the [crystal.window.viewport scale](viewport_scale) when [setting point sizes](https://love2d.org/wiki/love.graphics.setPointSize).

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
