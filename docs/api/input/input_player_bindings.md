---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputPlayer:bindings

Returns a table describing which actions are bound to which inputs for this player.

## Usage

```lua
input_player:bindings()
```

### Returns

| Name       | Type    | Description                           |
| :--------- | :------ | :------------------------------------ |
| `bindings` | `table` | Lists of actions bound to each input. |

This table has the same structure as the argument to [set_bindings](input_player_set_bindings).

## Examples

```lua
local player = crystal.input.player(1);
player:set_bindings({
  space = { "jump" },
  x = { "attack" },
});
player:set_bindings(player:bindings()); -- noop
```
