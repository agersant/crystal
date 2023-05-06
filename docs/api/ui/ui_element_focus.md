---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:focus

Gives focus to this element.

If applicable, this function first unfocuses a focused and active element under the same root, effectively transfering focus.

This function will emit an error when called on an element that is not focusable or cannot currently [receive input](ui_element_can_receive_input).

## Usage

```lua
ui_element:focus(player_index)
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

sword:focus(1);
assert(sword:is_focused(1));

armor:focus(1);
assert(armor:is_focused(1));
assert(not sword:is_focused(1));
```
