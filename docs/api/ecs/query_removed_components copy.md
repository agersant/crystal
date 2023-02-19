---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Query:removed_components

Returns all components that stopped being part of a match for this query during the last call to [ECS:update](ecs_update).

Components appear in this list when they meet 2 conditions:

1. Component is or was on an entity matched by this query
2. One of the following events happen:
   - Entity was despawned
   - Component was removed from its entity
   - Other components were removed from the entity so that it no longer matches the query

{: .warning}
This method can return components on entities that were just despawned.

## Usage

```lua
query:removed_components()
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
    print((tostring(poison:entity())) .. " is no longer poisoned");
  end
end
```
