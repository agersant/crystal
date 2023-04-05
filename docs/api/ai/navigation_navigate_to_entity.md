---
parent: crystal.ai
grand_parent: API Reference
nav_exclude: true
---

# Navigation:navigate_to_entity

Begins moving towards another entity.

## Usage

```lua
navigation:navigate_to_entity(entity, acceptance_radius, repath_delay)
```

### Arguments

| Name                | Type                              | Description                                                                                                                                                                  |
| :------------------ | :-------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `entity`            | [Entity](/crystal/api/ecs/entity) | Entity to move towards. Must have a [Body](/crystal/api/physics/body) component.                                                                                             |
| `acceptance_radius` | `number`                          | How close from the destination this entity must be to consider the navigation complete. Defaults to [component-wide value](navigation_set_acceptance_radius) if unspecified. |
| `repath_delay`      | `number`                          | How often a new path will be computed while navigation is in progress. Defaults to [component-wide value](navigation_set_repath_delay) if unspecified.                       |

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
entity:add_component(crystal.Navigation);
entity:set_position(80, 60);
entity:align_with_entity(target); -- Begins moving towards (100, 100)
```
