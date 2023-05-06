---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:handle_input

Executes callbacks [bound](ui_element_add_binding) to an input action, only considering callbacks owned by elements within this root which can [receive input](ui_element_can_receive_input).

The only guarantee on callback execution order is that callback with the `"when_focused` relevance execute before those with the `"always"` relevance. If any callback returns `true`, this function exits early.

If no callback has returned `true`, this function falls back to built-in input logic. Supported built-in inputs are `"+ui_left"`, `"+ui_right"`, `"+ui_down"` and `"+ui_up"`, which can all move focus in the corresponding direction.

{: .warning}
This method can only be called on elements that have no parent.

## Usage

```lua
ui_element:handle_input(player_index, input)
```

### Arguments

| Name           | Type     | Description                                                                       |
| :------------- | :------- | :-------------------------------------------------------------------------------- |
| `player_index` | `number` | Number identifying the [player](/crystal/api/input/player) who emitted the input. |
| `input`        | `string` | Input action that was pressed or released.                                        |

### Returns

| Name      | Type      | Description                                                                                  |
| :-------- | :-------- | :------------------------------------------------------------------------------------------- |
| `handled` | `boolean` | True if any bound callback for this input returned true or focus was moved, false otherwise. |

## Examples

```lua
local menu = crystal.Overlay:new();
menu:bind_input("+ui_ok", "always", nil, function()
  print("Binding Executed");
end);
menu:handle_input(1, "+ui_ok"); -- Prints "Binding Executed"
```
