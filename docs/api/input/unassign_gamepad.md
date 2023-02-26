---
parent: crystal.input
grand_parent: API Reference
nav_order: 1
---

# crystal.input.unassign_gamepad

Unassigns a player's current gamepad. Gamepad button presses will no longer be tracked by this player's [InputPlayer](input_player).

In addition:

- This method puts all inputs for the affected player in a released state.
- If the player's [input method](input_player_input_method) was `gamepad`, it is set to `nil`.

This method has no effect if the player had no assigned gamepad.

## Usage

```lua
crystal.input.unassign_gamepad(player_index)
```

### Arguments

| Name           | Type     | Description                  |
| :------------- | :------- | :--------------------------- |
| `player_index` | `number` | Number identifying a player. |

## Examples

```lua
local player_index = 1;
crystal.input.unassign_gamepad(player_index);
```
