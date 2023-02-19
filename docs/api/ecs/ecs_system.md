---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# ECS:system

Returns an existing [System](system) of a specific class or inheriting from it.

## Usage

```lua
ecs:system(class)
```

### Arguments

| Name    | Type                     | Description                                                    |
| :------ | :----------------------- | :------------------------------------------------------------- |
| `class` | `string` or system class | The system class to look for, as a `string` or as a reference. |

### Returns

| Name     | Type             | Description                                              |
| :------- | :--------------- | :------------------------------------------------------- |
| `system` | [System](system) | A system of the specified class (or inheriting from it). |

If no matching system exists, this method returns `nil`.

If multiple systems match the requested class, any of them may be returned.

## Example

```lua
local MySystem = Class("MySystem", crystal.System);
local ecs = crystal.ECS:new();
local my_system = ecs:add_system("MySystem");
assert(my_system == ecs:system("MySystem"));
```
