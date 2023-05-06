---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:on_unfocus

Called when this element loses focus.

## Usage

```lua
ui_element.on_unfocus = function(self, player_index)
  -- your code here
end
```

### Arguments

| Name           | Type     | Description                                                                               |
| :------------- | :------- | :---------------------------------------------------------------------------------------- |
| `player_index` | `number` | Number identifying the [player](/crystal/api/input/input_player) unfocusing this element. |

## Examples

```lua
local buy_menu = crystal.VerticalList:new();

local sword = buy_menu:add_child(crystal.Image:new(crystal.assets.get("sword.png")));
sword:set_focusable(true);

local shield = buy_menu:add_child(crystal.Image:new(crystal.assets.get("shield.png")));
shield:set_focusable(true);

sword.on_focus = function()
  print("Focused sword");
end

sword.on_unfocus = function()
  print("Unfocused sword");
end

buy_menu:focus_tree(1); -- Prints "Focused sword"
buy_menu:handle_input(1, "+ui_down"); -- Prints "Unfocused sword"
```
