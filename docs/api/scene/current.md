---
parent: crystal.scene
grand_parent: API Reference
nav_order: 1
---

# crystal.scene.current

Returns the current scene. If a scene [transition](transition) is currently in progress, this returns the scene being transitioned to.

## Usage

```lua
crystal.scene.current();
```

### Returns

| Name            | Type                   | Description        |
| :-------------- | :--------------------- | :----------------- |
| `current_scene` | [crystal.Scene](scene) | The current scene. |

## Examples

```lua
local my_scene = crystal.Scene:new();
crystal.scene.replace(my_scene);
assert(crystal.scene.current() == my_scene);
```
