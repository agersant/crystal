---
parent: crystal.ecs
grand_parent: API Reference
---

# crystal.Entity

Base class to inherit from to define entities.

{: .note}
In addition to the methods documented on this page, entities transparently expose all methods defined on their components. If multiple components share a method name, attempting to call it on the entity will emit an error detailing the ambiguity.

## Methods

| Name                                        | Description                                                                 |
| :------------------------------------------ | :-------------------------------------------------------------------------- |
| [add_component](entity_add_component)       | Instantiates and adds a new [Component](component) to this entity.          |
| [context](entity_context)                   | Retrieves a value added via [ecs:add_context](ecs_add_context).             |
| [component](entity_component)               | Returns a [Component](component) of a specific class or inheriting from it. |
| [components](entity_components)             | Returns all components of a specific class or inheriting fom it.            |
| [create_event](entity_create_event)         | Instantiates and creates a new [Event](event) associated with this entity.  |
| [despawn](entity_despawn)                   | Unregisters this entity from the [ECS](ecs).                                |
| [ecs](entity_ecs)                           | Returns the [ECS](ecs) this entity belongs to.                              |
| [is_valid](entity_is_valid)                 | Returns whether this entity is still in play (ie. not despawned).           |
| [remove_component](entity_remove_component) | Removes a component from this entity.                                       |

## Examples

```lua
local Slime = Class("Slime", crystal.Entity);

Slime.init = function(self)
  self:add_component("OozeTrail");
end

local ecs = crystal.ECS:new();
ecs:spawn("Slime");
```

```lua
local Health = Class("Health", crystal.Component);
Health.init = function(self)
  self.amount = 100;
end

Health.take_damage(self, damage)
  self.amount = math.max(0, self.amount - damage);
end

local Slime = Class("Slime", crystal.Entity);

Slime.init = function(self)
  self:add_component("Health", 100);
end

local ecs = crystal.ECS:new();
local slime = ecs:spawn("Slime");
-- shorthand for slime:component("Health"):take_damage(10);
slime:take_damage(10);
```
