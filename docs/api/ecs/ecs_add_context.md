---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# ECS:add_context

Makes a value available to all entities created by this ECS. This is useful to give entities access to global-ish values, like the scene they belong to.

There are two ways to retrieve these values at a later time:

1. Calling the [entity:context](entity_context) method (eg. `my_entity:context("my_context")`)
2. Calling the [ecs:context](ecs_context) method (eg. `my_ecs:context("my_context")`)

## Usage

```lua
ecs:add_context(name, value);
```

### Arguments

| Name    | Type     | Description                  |
| :------ | :------- | :--------------------------- |
| `name`  | `string` | Name of the context object.  |
| `value` | `any`    | Value of the context object. |

## Examples

```lua
local ecs = crystal.ECS:new();

local map = crystal.assets.get("assets/map/dungeon.lua");
ecs:add_context("map", map);

assert(ecs:context("map") == map);
```

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
