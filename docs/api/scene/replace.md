---
parent: crystal.scene
grand_parent: API Reference
nav_order: 1
---

# crystal.scene.replace

Plays transitions and changes the current scene. This function can be used with zero or more transitions. Transitions play in a sequence before the scene change is complete.

During transitions, the old and the new scenes both receive `Scene:update` callbacks. Only the new scene receives input callbacks.

## Usage

```lua
crystal.scene.replace(new_scene, ...);
```

### Arguments

| Name        | Type                             | Description             |
| :---------- | :------------------------------- | :---------------------- |
| `new_scene` | [crystal.Scene](scene)           | Scene to transition to. |
| `...`       | [crystal.Transition](transition) | Transitions to play.    |

### Returns

| Name     | Type                     | Description                                                |
| :------- | :----------------------- | :--------------------------------------------------------- |
| `thread` | [crystal.Thread](thread) | A thread that completes when all transitions are finished. |

## Examples

```lua
local new_scene = crystal.Scene:new();
crystal.scene.replace(
  new_scene,
  crystal.Transition.FadeToBlack:new(),
  crystal.Transition.FadeFromBlack:new(),
);
```
