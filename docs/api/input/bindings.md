---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# crystal.input.bindings

Returns a table describing which actions are bound to which inputs for the specified player.

## Usage

```lua
crystal.input.bindings(player_index)
```

### Arguments

| Name           | Type     | Description                  |
| :------------- | :------- | :--------------------------- |
| `player_index` | `number` | Number identifying a player. |

### Returns

| Name       | Type    | Description                           |
| :--------- | :------ | :------------------------------------ |
| `bindings` | `table` | Lists of actions bound to each input. |

This table has the same structure as the argument to [set_bindings](set_bindings).

## Examples

```lua
crystal.input.set_bindings(1, {
  space = { "jump" },
  x = { "attack" },
});
crystal.input.set_bindings(crystal.input.bindings(1)); -- noop
```
