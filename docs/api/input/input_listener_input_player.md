---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputListener:input_player

Returns the [InputPlayer](input_player) associated with this InputListener.

## Usage

```lua
input_listener:input_player()
```

### Arguments

| Name           | Type                        | Description                                                     |
| :------------- | :-------------------------- | :-------------------------------------------------------------- |
| `input_player` | [InputPlayer](input_player) | [InputPlayer](input_player) associated with this InputListener. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.InputListener, 1);
assert(entity:input_player() == crystal.input.player(1));
```
