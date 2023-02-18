---
parent: crystal.ecs
grand_parent: API Reference
---

# crystal.ECS

## Constructor

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
| `update`         | Updates the internal state of the ECS to reflect changes to entities and components.               |
