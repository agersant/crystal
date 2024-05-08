---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputListener:player_index

Returns the player index whose inputs this components responds to.

## Usage

```lua
input_listener:player_index()
```

### Returns

| Name    | Type     | Description                                            |
| :------ | :------- | :----------------------------------------------------- |
| `index` | `number` | Player index whose inputs this components responds to. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.InputListener, 2);
print(entity:player_index()); -- Prints "2"
```
