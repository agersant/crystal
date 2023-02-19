---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Query:removed_entities

Returns all entities that stopped matching this query during the last call to [ECS:update](ecs_update).

Entities stop matching a query when they despawn, or when they lose enough components to no longer have the complete set required by this query.

{: .warning}
This method can return entities that were just despawned.

## Usage

```lua
query:removed_entities()
```

### Returns

| Name       | Type    | Description                                     |
| :--------- | :------ | :---------------------------------------------- |
| `entities` | `table` | A table where every key is an [Entity](entity). |

## Example

```lua
local Poison = Class("Poison", crystal.Component);
local PoisonSystem = Class("PoisonSystem", crystal.System);

PoisonSystem.init = function(self)
  self.query = self:add_query({ "Poison" });
end

PoisonSystem.frame = function(self)
  for entity in pairs(self.query:added_components()) do
    print((tostring(entity)) .. " is no longer poisoned");
  end
end
```
