---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputPlayer:bindings

Defines which actions are bound to which inputs for this player.

## Usage

```lua
input_player:set_bindings(bindings)
```

### Returns

| Name       | Type    | Description                           |
| :--------- | :------ | :------------------------------------ |
| `bindings` | `table` | Lists of actions bound to each input. |

Keys in the `bindings` table can be:

- Any [love.KeyConstant](https://love2d.org/wiki/KeyConstant).
- Any [love.GamepadAxis](https://love2d.org/wiki/GamepadAxis).
- Any [love.GamepadButton](https://love2d.org/wiki/GamepadButton), except `a`, `b`, `x` and `y`, which should be replaced by `btna`, `btnb`, `btnx`, `btny`.

Values associated with these keys are lists of actions as strings. Actions should be specific to your game title (eg. `jump`, `attack`, `dodge`, etc.). If players in your game can accomplish different things by pressing a single key (eg. talking to an NPC or jumping, depending on context), you should define an action for each of these outcomes and map them all to the same key.

## Examples

```lua
local player = crystal.input.player(1);
player:set_bindings({
  -- Keyboard
  space = { "jump", "talk" },
  x = { "attack" },
  -- Gamepad
  dpad_a = { "jump", "talk" },
  dpad_x = { "attack" },
});
```