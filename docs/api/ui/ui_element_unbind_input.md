---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:unbind_input

Removes a previously [bound](ui_element_bind_input) input callback.

## Usage

```lua
ui_element:unbind_input(input)
```

### Arguments

| Name    | Type     | Description                                                                           |
| :------ | :------- | :------------------------------------------------------------------------------------ |
| `input` | `string` | [Input action](/crystal/api/input/input_player_set_bindings) whose bindings to clear. |

## Examples

```lua
local menu = crystal.Overlay:new();
menu:bind_input("+ui_ok", "always", nil, function()
  print("Binding Executed");
end);
menu:unbind_input("+ui_ok");
menu:handle_input(1, "+ui_ok"); -- Nothing is printed
```
