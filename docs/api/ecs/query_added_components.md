---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Query:added_components

Returns all components that became part of a match for this query during the last call to [ECS:update](ecs_update).

A component is considered part of a match when two conditions are met:

1. The component's class or one of its parent classes is a requirement for this query.
2. One of the following events happen:
   - Component belongs to an entity which was just spawned and matches the query.
   - Component was just added to an existing entity, and was the missing piece for the entity to match the query.
   - Component was already on the entity. Another component was just added and made the entity match the query.
   - Entity was already matching the query. This component was just added and also happens to be one of the requested classes for this query.

{: .info}
This method is mostly useful when working with queries that match against a single component class. For queries working with multiple component classes, it is often more convenient to call [added_entities](query_added_entities).

## Usage

```lua
query:added_components()
```

### Returns

| Name         | Type    | Description                                          |
| :----------- | :------ | :--------------------------------------------------- |
| `components` | `table` | A table where every key is a [Component](component). |

## Example

```lua
local Poison = Class("Poison", crystal.Component);
local PoisonSystem = Class("PoisonSystem", crystal.System);

PoisonSystem.init = function(self)
  self.query = self:add_query({ "Poison" });
end

PoisonSystem.frame = function(self)
  for poison in pairs(self.query:added_components()) do
    print((tostring(poison:entity())) .. " just got poisoned");
  end
end
```
