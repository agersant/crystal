---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputSystem:action_pressed

Routes an input to the relevant [input handlers](input_listener_add_input_handler). The event seen by input listeners is a string with the `"+action"` format - where the `+` sign indicates the action is being pressed and `action` is the name of an action registered via [set_bindings](set_bindings).

## Usage

```lua
input_system:action_pressed(player_index, action)
```

### Arguments

| Name           | Type     | Description                                         |
| :------------- | :------- | :-------------------------------------------------- |
| `player_index` | `number` | Index identifying the player who emitted the input. |
| `action`       | `string` | Action that was pressed (eg. `jump`).               |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.ecs = crystal.ECS:new();
  self.input_system = self.ecs:add_system(crystal.InputSystem);
end

MyScene.action_pressed = function(self, player_index, action)
  self.input_system:action_pressed(player_index, action);
end

MyScene.action_released = function(self, player_index, action)
  self.input_system:action_released(player_index, action);
end
```
