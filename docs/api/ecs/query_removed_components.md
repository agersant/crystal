---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Query:removed_components

Returns all components of a specific class (or inheriting from it) that stopped being part of a match for this query during the last call to [ECS:update](ecs_update).

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
query:removed_components(class)
```

### Arguments

| Name    | Type                        | Description                                                                                        |
| :------ | :-------------------------- | :------------------------------------------------------------------------------------------------- |
| `class` | `string` or component class | Base class of the newly removed components that will be returned, as a `string` or as a reference. |

### Returns

| Name         | Type    | Description                                                                                                           |
| :----------- | :------ | :-------------------------------------------------------------------------------------------------------------------- |
| `components` | `table` | A table where every key is a removed [Component](component). . Table values are the entities owning these components. |

## Examples

```lua
local Poison = Class("Poison", crystal.Component);
local PoisonSystem = Class("PoisonSystem", crystal.System);

PoisonSystem.init = function(self)
  self.query = self:add_query({ "Poison" });
end

PoisonSystem.frame = function(self)
  for poison in pairs(self.query:removed_components("Poison")) do
    print((tostring(poison:entity())) .. " is no longer poisoned");
  end
end
```
