---
parent: crystal.ecs
grand_parent: API Reference
---

# crystal.Event

Base class to inherit from to define events.

Events are a complement to the traditional ECS pattern which allows systems to generate information for downstream systems. For example, a combat-related [System](system) may emit damage events when players or monsters get hit. A UI-related system can pick up these events later in the frame to draw damage numbers on the screen.

The only way to create events is to call [Entity:create_event](entity_create_event). You can retrieve and filter events by calling the [ECS:events](ecs_events) method. Events are cleared when calling [ECS:update](ecs_update), which you should be doing at the start of every frame.

{: .info }
> This pattern is a bit different from the eventing system in most game engines. In most engines, events support some kind of subscription mechanism to bind callback functions. In Crystal, the only way to respond to events is to poll them by calling [ECS:events](ecs_events). While this approach is more restrictive, it makes it easier to write systems which:
>
> - Have consistent order of operation
> - Are easier to profile (event-handling code is not nested inside event-emitting code)
> - Are easier to debug

## Methods

| Name     | Description                                           |
| :------- | :---------------------------------------------------- |
| `entity` | Returns the [Entity](entity) that emitted this event. |

## Example

```lua
local DragonSpawned = class("DragonSpawned", crystal.Event);
local Dragon = class("Dragon", crystal.Entity);
Dragon.init = function(self)
	self:create_event(DragonSpawned);
end

local ecs = crystal.ECS:new();
ecs:spawn(Dragon);
for event in pairs(ecs:events("DragonSpawned")) do
	print(event);
end
```
