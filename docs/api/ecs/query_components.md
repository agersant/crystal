---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Query:components

Returns all components that are currently contributing to a successful match for this query.

{: .info}
This method is mostly useful when working with queries that match against a single component class. For queries working with multiple component classes, it is often more convenient to call [entities](query_entities).

## Usage

```lua
query:components()
```

### Returns

| Name         | Type    | Description                                          |
| :----------- | :------ | :--------------------------------------------------- |
| `components` | `table` | A table where every key is a [Component](component). |

## Example

```lua
local Regen = Class("Regen", crystal.Component);
local RegenSystem = Class("RegenSystem", crystal.System);

RegenSystem.init = function(self)
  self.query = self:add_query({ "Regen" });
end

RegenSystem.frame = function(self)
  for regen in pairs(self.query:components()) do
    -- Regeneration logic goes here
  end
end
```
