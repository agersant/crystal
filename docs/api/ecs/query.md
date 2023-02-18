---
parent: crystal.ecs
grand_parent: API Reference
---

# crystal.Query

## Methods

| Name                 | Description                                                                                          |
| :------------------- | :--------------------------------------------------------------------------------------------------- |
| `added_components`   | Returns all components that became part of a match for this query during the last ECS update.        |
| `added_entities`     | Returns all entities that started matching this query during the last ECS update.                    |
| `contains`           | Returns whether a specific [Entity](entity) matches this query.                                      |
| `entities`           | Returns all entities matching this query.                                                            |
| `removed_components` | Returns all components that stopped being part of a match for this query during the last ECS update. |
| `removed_entities`   | Returns all entities that stopped matching this query during the last ECS update.                    |
