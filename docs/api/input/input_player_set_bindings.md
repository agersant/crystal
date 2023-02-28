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

## Examples

```lua
local player = crystal.input.player(1);
player:set_bindings({
  space = { "jump" },
  x = { "attack" },
  dpad_a = { "jump" },
  dpad_x = { "attack" },
});
```
