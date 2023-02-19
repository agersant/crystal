---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Entity:create_event

Instantiates and creates a new [Event](event) associated with this entity.

## Usage

```lua
entity:create_event(class, ...)
```

### Arguments

| Name    | Type                    | Description                                                      |
| :------ | :---------------------- | :--------------------------------------------------------------- |
| `class` | `string` or event class | The event class to instantiate, as a `string` or as a reference. |
| `...`   | `any`                   | Arguments that are passed to the event's constructor.            |

### Returns

| Name    | Type           | Description                          |
| :------ | :------------- | :----------------------------------- |
| `event` | [Event](event) | Event that was created by this call. |

## Example

```lua
local DamageEvent = class("DamageEvent", crystal.Event);
DamageEvent.init = function(self, amount)
  self.amount = amount;
end

local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
local event = entity:create_event(DamageEvent, 50);
assert(event.amount == 50);
```
