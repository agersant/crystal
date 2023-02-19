---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Query:added_entities

Returns all entities that started matching this query during the last call to [ECS:update](ecs_update).

Entities can start match a query because they spawned with the required set of components. They can also start matching a query later through their lifecycle, when they eventually receive the expected set of components via [Entity:add_component](entity_add_component).

## Usage

```lua
query:added_entities()
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
  for entitity in pairs(self.query:added_entities()) do
    print((tostring(entity)) .. " just got poisoned");
  end
end
```
