---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# ECS:context

Retrieves a value added via [add_context](ecs_add_context).

## Usage

```lua
ecs:context(name);
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

assert(ecs:context("map") == map);
```
