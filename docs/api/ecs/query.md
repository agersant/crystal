---
parent: crystal.ecs
grand_parent: API Reference
---

# crystal.Query

Queries are used to keep track of all entities that have a predefined set of components. In this documention, entities with all the required components are referred to as matching the query. The only way to create a query is to call [System:add_query](system_add_query), passing in a table listing the required components.

{: .note}
Freshly created or destroyed entities/components will not immediately appear in query results. Query results are updated during [ECS:update()](ecs_update), which you should be calling at the beginning of each frame. In addition to helping performance, this prevents systems from having to handle entities that may be in inconsistent state due to spawning partway through a frame.

## Methods

| Name                 | Description                                                                                          |
| :------------------- | :--------------------------------------------------------------------------------------------------- |
| `added_components`   | Returns all components that became part of a match for this query during the last ECS update.        |
| `added_entities`     | Returns all entities that started matching this query during the last ECS update.                    |
| `components`         | Returns all components that are part of a match for this query.                                      |
| `contains`           | Returns whether a specific [Entity](entity) matches this query.                                      |
| `entities`           | Returns all entities matching this query.                                                            |
| `removed_components` | Returns all components that stopped being part of a match for this query during the last ECS update. |
| `removed_entities`   | Returns all entities that stopped matching this query during the last ECS update.                    |

## Example

```lua
local Health = Class("Health", crystal.Component);
local HealthSystem = Class("HealthSystem", crystal.System);

HealthSystem.init = function(self)
  self.query = self:add_query({ "Health" });
end

HealthSystem.do_things = function(self)
 for health in pairs(self.query:components()) do
	-- Do something with each health component
  end

  for entity in pairs(self.query:entities()) do
	-- Do something with each entity that has a Health component
  end
end
```
