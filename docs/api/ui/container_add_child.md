---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Container:add_child

Adds a child element to this container.

## Usage

```lua
container:add_child(child)
```

### Arguments

| Name    | Type                    | Description           |
| :------ | :---------------------- | :-------------------- |
| `child` | [UIElement](ui_element) | Child element to add. |

### Returns

| Name    | Type                    | Description                                        |
| :------ | :---------------------- | :------------------------------------------------- |
| `child` | [UIElement](ui_element) | Same child element that was passed in as argument. |

## Examples

```lua
local list = crystal.VerticalList:new();
local sword = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/sword.png")));
local shield = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/shield.png")));
local armor = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/armor.png")));
```
