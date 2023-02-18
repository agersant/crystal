---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.ecs

## Overview

[Entity Component System](https://en.wikipedia.org/wiki/Entity_component_system) is a popular pattern to structure game programming.

In the context of Crystal, game objects like characters, enemies, collectable items, etc. should be implemented by inheriting from [crystal.Entity](entity). Crystal provides a number of components which can be added to these entities to grant them functionality, like drawing sprites or moving around the world. You can define you own components by making classes that inherit from [crystal.Component](component). Accompanying systems can be defined by inheriting from [crystal.System](system).

The ECS pattern is often described in contrast to Object Oriented Programming (OOP), but they are not mutually exclusive. In Crystal, you can subclass your entities, components or even systems. Crystal's ECS module was designed with this usage in mind.

## Performance

The main goals of this ECS implementation are flexibility and usability over performance. It is entirely written in Lua, does not implement [SoA](https://en.wikipedia.org/wiki/AoS_and_SoA), and will not win any benchmark contests. However, the overhead is almost entirely frontloaded in entity/component creation.

## Example

The following example illustrates basic functionality of the [Entity](entity)/[Component](component)/[System](system) trifecta. You can find more examples throughout the documentation of this module.

```lua
local Bark = Class("Bark", crystal.Component);

local Dog = Class("Dog", crystal.Entity);
Dog.init = function(self)
  self:add_component("Bark");
end

local BarkSystem = Class("BarkSystem", crystal.System);
BarkSystem.init = function(self)
  self.query = self:add_query({ "Bark" });
end

BarkSystem.run_systems = function(self) -- this function name is arbitrary but needs to match the call below to `notify_systems`
  for entity in pairs(self.query:entities()) do -- iterates on all entities with a Bark component
    print("bark bark");
  end
end

-- Outside of a toy example, this would belong in your scene's constructor
local ecs = crystal.ECS:new();
ecs:add_system("BarkSystem");

-- This could be part of a scene's constructor too, or it could happen during gameplay
ecs:spawn("Dog");
ecs:spawn("Dog");

-- This would be called every frame in your scene's update() method
ecs:update(); -- makes the query in the BarkSystem aware of the newly spawned dogs
ecs:notify_systems("run_systems"); -- prints "bark bark" 2 times
```

## Classes

| Name                           | Description                                                                |
| :----------------------------- | :------------------------------------------------------------------------- |
| [crystal.Component](component) | Base class to inherit from to define components.                           |
| [crystal.ECS](ecs)             | Entry-point to this module. Manages a set of entities, systems and events. |
| [crystal.Entity](entity)       | Base class to inherit from to define entities.                             |
| [crystal.Event](event)         | Base class to inherit from to define events.                               |
| [crystal.Query](query)         | Gives access to entities and components relevant to a system.              |
| [crystal.System](system)       | Base class to inherit from to define systems.                              |
