---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Query:contains

Returns whether a specific [Entity](entity) was matched by this query.

{: .warning}
Like other query methods, results of this function are only updated when calling [ECS:update](ecs_update).

## Usage

```lua
query:contains(entity)
```

### Arguments

| Name     | Type             | Description                                               |
| :------- | :--------------- | :-------------------------------------------------------- |
| `entity` | [Entity](entity) | The entity which may or may not be matched by this query. |

### Returns

| Name        | Type      | Description                                   |
| :---------- | :-------- | :-------------------------------------------- |
| `contained` | `boolean` | True if the entity was matched by this query. |

## Examples

```lua
local Health = Class("Health", crystal.Component);
local HealthSystem = Class("HealthSystem", crystal.System);

HealthSystem.init = function(self)
  self.query = self:add_query({ "Health" });
end

HealthSystem.do_things = function(self)
  for entity in pairs(self.query:entities()) do
    assert(self.query:contains(entity));
  end
end
```
