---
parent: crystal.ai
grand_parent: API Reference
nav_exclude: true
---

# Navigation:navigate_to_entity

Begins moving towards another entity.

While navigation is in progress, a new path will be computed every 0.5s.

## Usage

```lua
navigation:navigate_to_entity(entity, acceptance_radius)
```

### Arguments

| Name                | Type                              | Description                                                                                                           |
| :------------------ | :-------------------------------- | :-------------------------------------------------------------------------------------------------------------------- |
| `entity`            | [Entity](/crystal/api/ecs/entity) | Entity to move towards. Must have a [Body](/crystal/api/physics/body) component.                                      |
| `acceptance_radius` | `number`                          | How close from the destination this entity must be to consider the navigation complete. Defaults to 4 if unspecified. |

### Returns

| Name     | Type                                 | Description                                                            |
| :------- | :----------------------------------- | :--------------------------------------------------------------------- |
| `thread` | [Thread](/crystal/api/script/thread) | A thread which will terminate when the entity reaches its destination. |

## Examples

```lua
local target = ecs:spawn(crystal.Entity);
target:add_component(crystal.Body);
target:set_position(100, 100);

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Body);
entity:add_component(crystal.Movement);
entity:set_position(80, 60);
entity:align_with_entity(target); -- Begins moving towards (100, 100)
```
