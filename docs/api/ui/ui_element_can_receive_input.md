---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:can_receive_input

Returns whether this element can currently receive input actions. This implies the following conditions:

- This element and all its ancestors are [active](ui_element_set_active).
- This element and all its ancestors are not [exclusive to another player](ui_element_set_player_index).

## Usage

```lua
ui_element:can_receive_input(player_index)
```

### Arguments

| Name           | Type     | Description                                                                          |
| :------------- | :------- | :----------------------------------------------------------------------------------- |
| `player_index` | `number` | Number identifying the [player](/crystal/api/input/player) whose inputs to consider. |

### Returns

| Name          | Type      | Description                                               |
| :------------ | :-------- | :-------------------------------------------------------- |
| `can_receive` | `boolean` | True if this element can receive inputs, false otherwise. |

## Examples

```lua
local menu = crystal.Overlay:new();
print(menu:can_receive_input(1)); -- Prints "true"
menu:set_player_index(2);
print(menu:can_receive_input(1)); -- Prints "false"
```
