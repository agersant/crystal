---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:unfocus_tree

Unfocuses all elements within this one (including itself).

{: .note}
Despite its name, this method does not incur a tree traversal.

## Usage

```lua
ui_element:unfocus_tree(player_index)
```

### Arguments

| Name           | Type     | Description                          |
| :------------- | :------- | :----------------------------------- |
| `player_index` | `number` | Player whose focus is being removed. |

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

menu:unfocus_tree(1);
assert(not sword:is_focused(1));
```
