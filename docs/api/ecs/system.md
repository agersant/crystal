---
parent: crystal.ecs
grand_parent: API Reference
---

# crystal.System

Base class to inherit from to define systems.

Systems are meant to run logic every frame to update all entities that have a specific combination of components. The only way to create systems is to call [ECS:add_system](ecs_add_system).

The important questions to think about when defining a system are:

1. What subset of components should entities have for this system to operate on them?  
   With the answer to this question, you can call [System:add_query](system_add_query) in your system's constructor. The returned [Query](query) object maintains a list of entities with the desired components. Note that you can create multiple queries in a single system. However, all queries must be created before any entity is spawned.

2. At which point during a frame should this system run?  
   Systems do not have an `update` method. Their logic may be defined in methods with any name. System methods run when you call [ECS:notify_systems](ecs_notify_systems) with the corresponding method name.  
   More concretely, your scenes' `update` method should be calling [ECS:notify_systems](ecs_notify_systems) several times, with arguments naming the different stages of your game frame.

## Methods

| Name        | Description                                      |
| :---------- | :----------------------------------------------- |
| `add_query` | Instantiates and registers a new [Query](query). |
| `ecs`       | Returns the [ECS](ecs) this system belongs to.   |

## Example

This example implements a `System` which operates on entities that have two components: a `Health` component and a `Poison` component. This system substract 1 health every frame on each poisoned entity. Note that outside of this toy example, it would be unwise to tie the poison's efficacy to the framerate of your game.

```lua
-- Poison component
local Poison = Class("Poison", crystal.Component);

-- Health Component
local Health = Class("Health", crystal.Component);

Health.init = function(self)
  self.amount = 100;
end

Health.take_damage(self, damage)
  self.amount = math.max(0, self.amount - damage);
end

-- Poison system
local PoisonSystem = Class("PoisonSystem", crystal.System);

PoisonSystem.init = function(self)
  self.query = self:add_query("Health", "Poison");
end

PoisonSystem.combat = function(self)
  for entity in pairs(self.query:entities()) do
    -- Poisoned entities take 1 damage per frame
    entity:take_damage(1);
  end
end

-- Somewhere in your scene's update code:
my_ecs:update();
my_ecs:notify_systems("input");
my_ecs:notify_systems("physics");
my_ecs:notify_systems("combat"); -- poison logic runs here
my_ecs:notify_systems("draw");
```
