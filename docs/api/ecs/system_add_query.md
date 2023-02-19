---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# System:add_query

Instantiates and registers a new [Query](query).

## Usage

```lua
system:add_query(classes)
```

### Arguments

| Name      | Type    | Description                                                   |
| :-------- | :------ | :------------------------------------------------------------ |
| `classes` | `table` | List of component classes this query uses to filter entities. |

Each entry in the `classes` table can be either a component subclass, or its name as a `string`.

### Returns

| Name    | Type           | Description                          |
| :------ | :------------- | :----------------------------------- |
| `query` | [Query](query) | Query that was created by this call. |

## Example

```lua
local Health = Class("Health", crystal.Component);
local Poison = Class("Poison", crystal.Component);
local PoisonSystem = Class("MySystem", crystal.System);

PoisonSystem.init = function(self)
  self.query = self:add_query({ "Health", Poison });
end
```
