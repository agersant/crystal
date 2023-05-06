---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:focused_element

Returns a focused element within this one (including itself). Only elements which can [receive input](ui_element_can_receive_input) are eligible.

{: .note}
This method does not incur a tree traversal.

## Usage

```lua
ui_element:focused_element(player_index)
```

### Arguments

| Name           | Type     | Description                             |
| :------------- | :------- | :-------------------------------------- |
| `player_index` | `number` | Player whose focus is being considered. |

### Returns

| Name      | Type                             | Description                                 |
| :-------- | :------------------------------- | :------------------------------------------ |
| `element` | [UIElement](ui_element) \| `nil` | Focused descendent which can receive input. |

## Examples

```lua
local menu = crystal.HorizontalList:new();

local buy_items = menu:add_child(crystal.VerticalList:new());
local sword = buy_items:add_child(crystal.Image:new(crystal.assets.get("sword.png")));
local shield = buy_items:add_child(crystal.Image:new(crystal.assets.get("shield.png")));

local sell_items = menu:add_child(crystal.VerticalList:new());
local helmet = sell_items:add_child(crystal.Image:new(crystal.assets.get("helmet.png")));
local armor = sell_items:add_child(crystal.Image:new(crystal.assets.get("armor.png")));

sword:set_focusable(true);
shield:set_focusable(true);
helmet:set_focusable(true);
armor:set_focusable(true);

menu:focus_tree(1);
assert(menu:focused_element(1) == sword);
```
