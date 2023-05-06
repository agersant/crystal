---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:active_bindings

Returns a table of active input bindings within this element for a given player. A binding is considered active for a player when:

- The element can [receive input](ui_element_can_receive_input)
- Its [relevance](ui_element_bind_input) condition is met.

Since the output of this function changes based on what is currently focused, you may use it to implement indicators telling the player what actions are currently available to them by pressing which buttons.

## Usage

```lua
ui_element:active_bindings(player_index)
```

### Arguments

| Name           | Type     | Description                                                                            |
| :------------- | :------- | :------------------------------------------------------------------------------------- |
| `player_index` | `number` | Number identifying the [player](/crystal/api/input/player) whose bindings to consider. |

### Returns

| Name       | Type    | Description               |
| :--------- | :------ | :------------------------ |
| `bindings` | `table` | Table of active bindings. |

Keys into the `bindings` table are [action names](crystal.input.input_player_set_bindings). Values are lists of bindings, where each binding is itself a table with the following content:

- `owner`: [UI Element](ui_element) which registered the binding.
- `relevance`: [BindingRelevance](binding_relevance) the binding was registered with.
- `details`: optional payload passed in to [add_binding](ui_element_bind_input).
- `callback`: function to execute when this input is handled.

## Examples

```lua
local buy_menu = crystal.Overlay:new();
buy_menu:bind_input("+ui_cancel", "always", "Exit Buy Menu", function()
  -- Logic to exit buy menu here
end);

local bindings = buy_menu:active_bindings(1);
assert(bindings["+ui_cancel"][1].details == "Exit Buy Menu");
```
