---
parent: crystal.ecs
grand_parent: API Reference
---

# crystal.Entity

## Methods

| Name               | Description                                                                 |
| :----------------- | :-------------------------------------------------------------------------- |
| `add_component`    | Instantiates and adds a new [Component](component) to this entity.          |
| `component`        | Returns a [Component](component) of a specific class or inheriting from it. |
| `components`       | Returns all components of a specific class or inheriting fom it.            |
| `create_event`     | Instantiates and creates a new [Event](event) associated with this entity.  |
| `despawn`          | Unregisters this entity from the [ECS](ecs).                                |
| `ecs`              | Returns the [ECS](ecs) this entity belongs to.                              |
| `is_valid`         | Returns whether this entity has despawned.                                  |
| `remove_component` | Removes a component from this entity.                                       |
