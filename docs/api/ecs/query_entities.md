---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Query:entities

Returns all entities matching this query.

## Usage

```lua
query:entities();
```

### Returns

| Name       | Type    | Description                                     |
| :--------- | :------ | :---------------------------------------------- |
| `entities` | `table` | A table where every key is an [Entity](entity). |

## Example

```lua
local Health = Class("Health", crystal.Component);
local HealthSystem = Class("HealthSystem", crystal.System);

HealthSystem.init = function(self)
  self.query = self:add_query({ "Health" });
end

HealthSystem.do_things = function(self)
  for entity in pairs(self.query:entities()) do
    -- Do something with entity that has a health component
  end
end
```
