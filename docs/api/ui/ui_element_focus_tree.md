---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:focus_tree

Gives focus to the first focusable element within this one (including itself) which can also [receive input](ui_element_can_receive_input). The new element to focus is found by traversing descendents. If no suitable element is found, this function has no effect.

If applicable, this function first unfocuses a focused and active element under the same root, effectively transfering focus.

## Usage

```lua
ui_element:focus_tree(player_index)
```

### Arguments

| Name           | Type     | Description                        |
| :------------- | :------- | :--------------------------------- |
| `player_index` | `number` | Player whose focus is being moved. |

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

sell_items:focus_tree(1);
assert(helmet:is_focused(1));
assert(not sword:is_focused(1));
```
