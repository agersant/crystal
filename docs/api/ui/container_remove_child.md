---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Container:remove_child

Removes a child element.

This function will error if the child passed in is not a child of this container.

## Usage

```lua
container:remove_child(child)
```

### Arguments

| Name    | Type                    | Description              |
| :------ | :---------------------- | :----------------------- |
| `child` | [UIElement](ui_element) | Child element to remove. |

## Examples

```lua
local list = crystal.VerticalList:new();
local sword = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/sword.png")));
local shield = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/shield.png")));
local armor = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/armor.png")));

list:remove_child(shield);
assert(shield:parent() == nil);
```
