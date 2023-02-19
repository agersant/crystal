---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# ECS:events

Returns a list of events of a specific class or inheriting from it. Use this method to poll for [Events](event) of a specific type created earlier in the frame.

## Usage

```lua
ecs:events(class)
```

### Arguments

| Name    | Type                    | Description                                                                        |
| :------ | :---------------------- | :--------------------------------------------------------------------------------- |
| `class` | `string` or event class | The event class whose instances will be returned, as a `string` or as a reference. |

### Returns

| Name     | Type    | Description       |
| :------- | :------ | :---------------- |
| `events` | `table` | A list of events. |

## Example

```lua
local DragonSpawned = Class("DragonSpawned", crystal.Event);
local Dragon = Class("Dragon", crystal.Entity);
Dragon.init = function(self, noise)
  self:create_event(DragonSpawned);
end

local ecs = crystal.ECS:new();
ecs:spawn(Dragon);
for event in pairs(ecs:events("DragonSpawned")) do
  print(event);
end
```
