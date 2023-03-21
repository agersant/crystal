---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Entity:context

Retrieves a value added via [ecs:add_context](ecs_add_context).

## Usage

```lua
entity:context(name);
```

### Arguments

| Name   | Type     | Description                 |
| :----- | :------- | :-------------------------- |
| `name` | `string` | Name of the context object. |

### Returns

| Name    | Type  | Description                  |
| :------ | :---- | :--------------------------- |
| `value` | `any` | Value of the context object. |

## Examples

```lua
local ecs = crystal.ECS:new();

local map = crystal.assets.get("assets/map/dungeon.lua");
ecs:add_context("map", map);

local Hero = Class("Hero", crystal.Entity);
Hero.init = function(self)
  local map = self:context("map");
  -- do things with map
end
```
