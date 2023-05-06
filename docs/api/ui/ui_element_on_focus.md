---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:on_focus

Called when this element gains focus.

## Usage

```lua
ui_element.on_focus = function(self, player_index)
  -- your code here
end
```

### Arguments

| Name           | Type     | Description                                                                             |
| :------------- | :------- | :-------------------------------------------------------------------------------------- |
| `player_index` | `number` | Number identifying the [player](/crystal/api/input/input_player) focusing this element. |

## Examples

```lua
local buy_menu = crystal.VerticalList:new();

local sword = buy_menu:add_child(crystal.Image:new(crystal.assets.get("sword.png")));
sword:set_focusable(true);
sword.on_focus = function()
  print("Focused sword");
end

local shield = buy_menu:add_child(crystal.Image:new(crystal.assets.get("shield.png")));
shield:set_focusable(true);
shield.on_focus = function()
  print("Focused shield");
end

buy_menu:focus_tree(1); -- Prints "Focused sword"
buy_menu:handle_input(1, "+ui_down"); -- Prints "Focused shield"
```
