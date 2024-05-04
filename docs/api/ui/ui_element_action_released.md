---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:action_released

Executes callbacks [bound](ui_element_bind_input) to an action being released. Only callbacks owned by elements within this root and which can [receive input](ui_element_can_receive_input) are executed.

The only guarantee on callback execution order is that callbacks with the `"when_focused"` relevance execute before those with the `"always"` relevance. If any callback returns `true`, this function exits early.

{: .warning}
This method can only be called on elements that have no parent.

## Usage

```lua
ui_element:action_released(player_index, action)
```

### Arguments

| Name           | Type     | Description                                                                       |
| :------------- | :------- | :-------------------------------------------------------------------------------- |
| `player_index` | `number` | Number identifying the [player](/crystal/api/input/player) who emitted the input. |
| `action`       | `string` | Input action that was released (eg. `"jump"`).                                    |

### Returns

| Name      | Type      | Description                                                                                                        |
| :-------- | :-------- | :----------------------------------------------------------------------------------------------------------------- |
| `handled` | `boolean` | True if any bound callback for this input returned true or focus was moved by a built-in handler, false otherwise. |

## Examples

```lua
local menu = crystal.Overlay:new();
menu:bind_input("-ui_ok", "always", nil, function()
  print("Binding Executed");
end);
menu:action_released(1, "ui_ok"); -- Prints "Binding Executed"
```
