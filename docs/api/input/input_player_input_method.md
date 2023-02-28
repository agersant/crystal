---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputPlayer:input_method

Returns the input method last used by this player. This value is `nil` until the player has pressed a keyboard key or gamepad button mapped to an action.

When a player's input method is `"gamepad"` and their gamepad becomes [unassigned](unassign_gamepad), the input method is reset to `nil`.

## Usage

```lua
input_player:input_method()
```

### Returns

| Name           | Type                        | Description                            |
| :------------- | :-------------------------- | :------------------------------------- |
| `input_method` | [InputMethod](input_method) | Input method last used by this player. |

## Examples

```lua
local player = crystal.input.player(1);
player:set_bindings({
  space = { "jump" },
  dpad_a = { "jump" },
});

print(player:input_method()); -- Prints "nil"
love.keypressed("space", "space", false);
print(player:input_method()); -- Prints "keyboard_and_mouse"
love.gamepadpressed(love.input.getJoysticks()[1], "a");
print(player:input_method()); -- Prints "gamepad"
```
