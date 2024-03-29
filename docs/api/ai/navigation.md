---
parent: crystal.ai
grand_parent: API Reference
---

# crystal.Navigation

A [Component](/crystal/api/ecs/component) which allows entities to find and follow paths.

This component only works with the following setup:

- The entity also has a [Body](/crystal/api/physics/body) component.
- The entity also has a [Movement](/crystal/api/physics/movement) component.

{: .note}
Even though methods on this component return [threads](/crystal/api/script/thread), the entity does not need a [ScriptRunner](/crystal/api/script/script_runner) component. The Navigation component manages its own Script, and updates it via [update_navigation](navigation_update_navigation).

## Constructor

Like all other components, Navigation components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component).

The constructor for Navigation expects an argument of type [Map](/crystal/api/assets/map).

## Methods

| Name                                                      | Description                                                                   |
| :-------------------------------------------------------- | :---------------------------------------------------------------------------- |
| [align_with_entity](navigation_align_with_entity)         | Begins moving to align itself vertically or horizontally with another entity. |
| [navigate_to_entity](navigation_navigate_to_entity)       | Begins moving towards another entity.                                         |
| [navigate_to](navigation_navigate_to)                     | Begins moving towards a specific location.                                    |
| [set_acceptance_radius](navigation_set_acceptance_radius) | Sets the default acceptance radius for navigation requests on this component. |
| [set_repath_delay](navigation_set_repath_delay)           | Sets the default repath delay for navigation requests on this component.      |
| [update_navigation](navigation_update_navigation)         | Sets heading to follow current path.                                          |

## Examples

```lua
local map = crystal.assets.get("assets/map/castle_courtyard.lua");
local ecs = crystal.ECS:new();
local physics_system = ecs:add_system(crystal.PhysicsSystem);
local ai_system = ecs:add_system(crystal.AISystem, map);

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Body);
entity:add_component(crystal.Movement);
entity:add_component(crystal.Navigation);
entity:navigate_to(60, 120);

-- During update:
physics_system:simulate_physics(dt);
ai_system:update_ai(dt);
```
