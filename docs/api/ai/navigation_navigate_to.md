---
parent: crystal.ai
grand_parent: API Reference
nav_exclude: true
---

# Navigation:navigate_to

Begins moving towards a specific location.

While navigation is in progress, a new path will be computed every 2s.

## Usage

```lua
navigation:navigate_to(x, y, acceptance_radius)
```

### Arguments

| Name                | Type     | Description                                                                                                           |
| :------------------ | :------- | :-------------------------------------------------------------------------------------------------------------------- |
| `x`                 | `number` | X coordinate to move towards.                                                                                         |
| `y`                 | `number` | Y coordinate to move towards.                                                                                         |
| `acceptance_radius` | `number` | How close from the destination this entity must be to consider the navigation complete. Defaults to 4 if unspecified. |

### Returns

| Name     | Type                                 | Description                                                            |
| :------- | :----------------------------------- | :--------------------------------------------------------------------- |
| `thread` | [Thread](/crystal/api/script/thread) | A thread which will terminate when the entity reaches its destination. |

## Examples

```lua
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Body);
entity:add_component(crystal.Movement);
entity:set_position(80, 60);
entity:navigate_to(100, 120); -- Begins moving towards (100, 120)
```
