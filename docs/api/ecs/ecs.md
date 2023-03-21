---
parent: crystal.ecs
grand_parent: API Reference
---

# crystal.ECS

Entry-point to the [crystal.ecs](index) module. Instances of this class manage a living set of entities and their components, as well as systems and queries to update them.

## Constructor

```lua
crystal.ECS:new()
```

## Methods

| Name                                 | Description                                                                                        |
| :----------------------------------- | :------------------------------------------------------------------------------------------------- |
| [add_context](ecs_add_context)       | Makes a value available to all entities created by this ECS.                                       |
| [add_system](ecs_add_system)         | Instantiates a new [System](system).                                                               |
| [context](ecs_context)               | Retrieves a value added via [add_context](ecs_add_context).                                        |
| [components](ecs_components)         | Returns all components of a specific class or inheriting from it.                                  |
| [despawn](ecs_despawn)               | Unregisters an [Entity](entity) from this ECS.                                                     |
| [entities_with](ecs_entities_with)   | Returns all entities that have a [Component](component) of a specific class or inheriting from it. |
| [events](ecs_events)                 | Returns a list of events of a specific class or inheriting from it.                                |
| [notify_systems](ecs_notify_systems) | Calls a method by name on all systems that support it.                                             |
| [spawn](ecs_spawn)                   | Instantiates a new [Entity](entity).                                                               |
| [system](ecs_system)                 | Returns an existing [System](system) of a specific class or inheriting from it.                    |
| [update](ecs_update)                 | Clears [events](event) and updates all [queries](query).                                           |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function()
  self.ecs = crystal.ECS:new();
end

MyScene.update = function(self, dt)
  self.ecs:update();
  self.ecs:notify_systems("input");
  self.ecs:notify_systems("physics");
  self.ecs:notify_systems("draw");
end
```
