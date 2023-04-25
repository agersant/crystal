---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputSystem:handle_input

Routes an input to the relevant [input handlers](input_listener_add_input_handler).

## Usage

```lua
input_system:handle_input(player_index, input)
```

### Arguments

| Name           | Type     | Description                                         |
| :------------- | :------- | :-------------------------------------------------- |
| `player_index` | `number` | Index identifying the player who emitted the input. |
| `input`        | `string` | Input event (eg. `+jump`).                          |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.ecs = crystal.ECS:new();
  self.input_system = self.ecs:add_system(crystal.InputSystem);
end

MyScene.update = function(self, delta_time)
  local player_index = 1;
  for _, input in ipairs(crystal.input.player(player_index):events()) do
			self.input_system:handle_input(player_index, input);
	end
end
```
