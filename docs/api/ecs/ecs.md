---
parent: crystal.ecs
grand_parent: API Reference
---

# crystal.ECS

Entry-point to the [crystal.ecs](index) module. Instances of this class manage a living set of entities and their components, as well as systems and queries to update them.

## Constructor

```lua
local ecs = crystal.ECS:new();
```

## Methods

| Name             | Description                                                                                        |
| :--------------- | :------------------------------------------------------------------------------------------------- |
| `add_system`     | Instantiates and registers a new [System](system).                                                 |
| `components`     | Returns all components of a specific class or inheriting from it.                                  |
| `despawn`        | Destroys an [Entity](entity).                                                                      |
| `entities_with`  | Returns all entities that have a [Component](component) of a specific class or inheriting from it. |
| `events`         | Returns a list of events of a specific class or inheriting from it.                                |
| `notify_systems` | Calls a method by name on all systems that support it.                                             |
| `spawn`          | Instantiates and registers a new [Entity](entity).                                                 |
| `system`         | Returns a [System](system) of a specific class or inheriting from it.                              |
| `update`         | Clears events and updates all queries.                                                             |

## Example

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
