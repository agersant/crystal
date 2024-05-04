---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# Scene:action_pressed

Called from [love.update](https://love2d.org/wiki/love.update) when a player presses a key or button [bound to an action](/crystal/api/input/set_bindings).

A common usage of this callback is to forward calls to your scene's [InputSystem](/crystal/api/input/input_system_action_pressed).

## Usage

```lua
scene:action_pressed(player_index, action)
```

### Arguments

| Name           | Type     | Description                                               |
| :------------- | :------- | :-------------------------------------------------------- |
| `player_index` | `number` | Identifier for which player initiated the action.         |
| `action`       | `string` | Action that was pressed (eg. `"jump"`, `"attack"`, etc.). |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.action_pressed = function(self, player_index, action)
  print("Player #" .. player_index .. " pressed " .. action .. ".");
end
```
