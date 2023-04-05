---
parent: crystal.ai
grand_parent: API Reference
nav_exclude: true
---

# Navigation:set_repath_delay

Sets how frequently this component should compute an updated path while navigation is in progress. The default repath delay is set to 1 second.

Individual navigation calls like [navigate_to_entity](navigation_navigate_to_entity) may specify their own repath delay.

## Usage

```lua
navigation:set_repath_delay(delay)
```

### Arguments

| Name    | Type     | Description                                        |
| :------ | :------- | :------------------------------------------------- |
| `delay` | `number` | Duration between path re-computations, in seconds. |

## Examples

```lua
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Body);
entity:add_component(crystal.Movement);
entity:add_component(crystal.Navigation);
entity:set_repath_delay(2);
```
