---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# ECS:add_system

Instantiates a new [System](system).

## Usage

```lua
ecs:add_system(class, ...);
```

### Arguments

| Name    | Type                     | Description                                                       |
| :------ | :----------------------- | :---------------------------------------------------------------- |
| `class` | `string` or system class | The system class to instantiate, as a `string` or as a reference. |
| `...`   | `any`                    | Arguments that are passed to the system's constructor.            |

### Returns

| Name     | Type             | Description                           |
| :------- | :--------------- | :------------------------------------ |
| `system` | [System](system) | System that was created by this call. |

## Example

```lua
local MySystem = Class("MySystem", crystal.System);
MySystem.init = function(self, color)
	self.color = color;
end

local ecs = crystal.ECS:new();
local my_system = ecs:add_system("MySystem", "blue");
print(my_system.color); --prints "blue"
```
