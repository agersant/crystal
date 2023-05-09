---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.hot_reload

This module restarts the game every time assets or source files are saved. This allows you to iterate on code or assets without having to constantly close the game window and launch it again.

{: .note}
Hot reload is not available in [fused builds](https://love2d.org/wiki/love.filesystem.isFused).

## Functions

| Name                                  | Description                                        |
| :------------------------------------ | :------------------------------------------------- |
| [crystal.hot_reload.disable](disable) | Disables hot reloading.                            |
| [crystal.hot_reload.enable](enable)   | Enables hot reloading.                             |
| [crystal.hot_reload.persist](persist) | Makes a piece of data persist through hot reloads. |

## Console Commands

| Name               | Description               |
| :----------------- | :------------------------ |
| `DisableHotReload` | Calls [disable](disable). |
| `EnableHotReload`  | Calls [enable](enable).   |
