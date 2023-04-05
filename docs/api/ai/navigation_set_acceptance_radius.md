---
parent: crystal.ai
grand_parent: API Reference
nav_exclude: true
---

# Navigation:set_acceptance_radius

Sets how close this entity needs to get to its goal before considering navigation successful. The default acceptance radius is 4 units.

Individual navigation calls like [navigate_to_entity](navigation_navigate_to_entity) may specify their own acceptance_radius.

## Usage

```lua
navigation:set_acceptance_radius(radius)
```

### Arguments

| Name     | Type     | Description                                                       |
| :------- | :------- | :---------------------------------------------------------------- |
| `radius` | `number` | Distance from the goal where navigation is considered successful. |

## Examples

```lua
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Body);
entity:add_component(crystal.Movement);
entity:add_component(crystal.Navigation);
entity:set_acceptance_radius(8);
```
