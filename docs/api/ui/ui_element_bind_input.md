---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:bind_input

Binds an input action to a callback function.

Callback functions are executed during calls to [action_pressed](ui_element_action_pressed) and [action_released](ui_element_action_released).

## Usage

```lua
ui_element:bind_input(input, relevance, details, callback)
```

### Arguments

| Name        | Type                                      | Description                                                                                                                                                                                     |
| :---------- | :---------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `input`     | `string`                                  | [Input action](/crystal/api/input/input_player_set_bindings) which can trigger the callback. Prefix the action with `+` to execute the callback on press, or with `-` to execute it on release. |
| `relevance` | [BindingRelevance](binding_relevance)     | Describes when the binding is relevant.                                                                                                                                                         |
| `details`   | `any`                                     | Optional information describing this binding (eg. display name, icon, etc.).                                                                                                                    |
| `callback`  | `function(player_index: number): boolean` | Function to execute when the binding is triggered by its input action.                                                                                                                          |

When a callback function returns `true`, additional callbacks will not be executed for this input.

## Examples

```lua
local menu = crystal.Overlay:new();
menu:bind_input("+ui_ok", "always", nil, function()
  print("Binding Executed");
end);
menu:action_pressed(1, "ui_ok"); -- Prints "Binding Executed"
```
