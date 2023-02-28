---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputPlayer:is_action_active

Returns whether any input mapped to a specific action is currently being pressed.

## Usage

```lua
input_player:is_action_active(action)
```

### Arguments

| Name     | Type     | Description                 |
| :------- | :------- | :-------------------------- |
| `action` | `string` | Action to check inputs for. |

### Returns

| Name     | Type      | Description                                                                   |
| :------- | :-------- | :---------------------------------------------------------------------------- |
| `active` | `boolean` | True if any input mapped to the action is currently pressed. False otherwise. |

## Examples

```lua
local player = crystal.input.player(1);
player:set_bindings({ space = { "jump" } });
print(player:is_action_active("jump")); -- Prints "false"
```
