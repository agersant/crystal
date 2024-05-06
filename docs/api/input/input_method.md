---
parent: crystal.input
grand_parent: API Reference
nav_order: 1
---

# crystal.input.input_method

Returns the input method last used by the specified player. This value is `nil` until the player has pressed a keyboard key or gamepad button mapped to an action.

When a player's input method is `"gamepad"` and their gamepad becomes [unassigned](unassign_gamepad), their input method is reset to `nil`.

## Usage

```lua
crystal.input.input_method(player_index)
```

### Arguments

| Name           | Type     | Description                  |
| :------------- | :------- | :--------------------------- |
| `player_index` | `number` | Number identifying a player. |

### Returns

| Name           | Type                        | Description                            |
| :------------- | :-------------------------- | :------------------------------------- |
| `input_method` | [InputMethod](input_method) | Input method last used by this player. |

## Examples

```lua
crystal.input.set_bindings(1, {
  space = { "jump" },
  btna = { "jump" },
});

print(crystal.input.input_method(1)); -- Prints "nil"
love.keypressed("space", "space", false);
print(crystal.input.input_method(1)); -- Prints "keyboard"
love.gamepadpressed(love.input.getJoysticks()[1], "a");
print(crystal.input.input_method(1)); -- Prints "gamepad"
```
