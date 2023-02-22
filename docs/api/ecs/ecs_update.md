---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# ECS:update

Clears [events](event) and updates all [queries](query).

{: .note}
You should call this method at the beginning of every frame. Failing to do so would allow events to pile-up between frames and make queries return outdated results.

## Usage

```lua
ecs:update()
```

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:update();
```
