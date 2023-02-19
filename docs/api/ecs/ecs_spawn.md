---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# ECS:spawn

Instantiates a new [Entity](entity).

## Usage

```lua
ecs:spawn(class, ...)
```

### Arguments

| Name    | Type                     | Description                                                       |
| :------ | :----------------------- | :---------------------------------------------------------------- |
| `class` | `string` or entity class | The entity class to instantiate, as a `string` or as a reference. |
| `...`   | `any`                    | Arguments that are passed to the entity's constructor.            |

### Returns

| Name     | Type             | Description                           |
| :------- | :--------------- | :------------------------------------ |
| `entity` | [Entity](entity) | Entity that was created by this call. |

## Example

```lua
local Character = Class("Character", crystal.Entity);
Character.init = function(self, name)
	self.name = name;
end

local ecs = crystal.ECS:new();
local onion_knight = ecs:spawn(Character, "Sigmeyer");
print(onion_knight.name); -- prints "Sigmeyer"
```
