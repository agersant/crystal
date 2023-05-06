---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:is_focused

Returns whether this element is currently focused by a specific player.

## Usage

```lua
ui_element:is_focused(player_index)
```

### Arguments

| Name           | Type     | Description                             |
| :------------- | :------- | :-------------------------------------- |
| `player_index` | `number` | Player whose focus is being considered. |

### Returns

| Name      | Type      | Description                               |
| :-------- | :-------- | :---------------------------------------- |
| `focused` | `boolean` | True if the element is currently focused. |

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
assert(sword:is_focused(1));
assert(not helmet:is_focused(1));
```
