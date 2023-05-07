---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Container:children

Returns the list of child elements.

## Usage

```lua
container:children()
```

### Returns

| Name   | Type    | Description                            |
| :----- | :------ | :------------------------------------- |
| `list` | `table` | List of child [UIElement](ui_element). |

## Examples

```lua
local list = crystal.VerticalList:new();
local sword = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/sword.png")));
local shield = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/shield.png")));
local armor = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/armor.png")));

for _, child in list:children() do
  child:set_opacity(0.5);
end
```
