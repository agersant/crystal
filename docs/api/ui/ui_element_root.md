---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:root

Returns this element's root.

## Usage

```lua
ui_element:root()
```

### Returns

| Name           | Type                    | Description   |
| :------------- | :---------------------- | :------------ |
| `root_element` | [UIElement](ui_element) | Root element. |

## Examples

```lua
local shop = crystal.Overlay:new();
local items = shop:add_child(crystal.VerticalList:new());
local sword = items:add_child(crystal.Image:new(crystal.assets.get("sword.png")));
local potion = items:add_child(crystal.Image:new(crystal.assets.get("potion.png")));
assert(sword:root() == shop);
assert(items:root() == shop);
assert(shop:root() == shop);
```
