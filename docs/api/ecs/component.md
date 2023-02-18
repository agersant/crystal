---
parent: crystal.ecs
grand_parent: API Reference
---

# crystal.Component

Base class to inherit from to define components.

## Methods

| Name     | Description                                             |
| :------- | :------------------------------------------------------ |
| `entity` | Returns the [Entity](entity) this component belongs to. |

## Example

```lua
local Health = Class("Health", crystal.Component);
Health.init = function(self, value)
  self.value = value;
end

local Dragon = class("Dragon", crystal.Entity);
Dragon.init = function(self)
  self:add_component("Health", 400);
end
```
