---
parent: crystal.input
grand_parent: API Reference
nav_order: 1
---

# crystal.input.configure_autorepeat

Defines which actions emit events while inputs are being held, and how frequently. By default, actions emit a `"+action"` (eg. `"+jump"`) event when the corresponding input is pressed, and a `"-action"` event when it is released. With autorepeat, it is possible to configure an action to also emit periodic `"+action"` events while the input is being held.

## Usage

```lua
crystal.input.configure_autorepeat(configuration)
```

### Arguments

| Name            | Type    | Description                                                   |
| :-------------- | :------ | :------------------------------------------------------------ |
| `configuration` | `table` | Table describing which actions should emit autorepeat events. |

Each key in the `configuration` table is an action, like `jump` or `attack`. Each of these keys maps to a table with two fields:

- `initial_delay`: `number` of seconds between the input being pressed (initial `"+action"` event) and the first repeat event being emitted.
- `period`: `number` of seconds between additional `"+action"` events while the input is being held

## Examples

```lua
-- Map each arrow key to two actions: move_* to move the player character, and ui_* to navigate in a menu
crystal.input.player(1):set_bindings({
	up = { "move_up", "ui_up" },
	down = { "move_down", "ui_down" },
	left = { "move_left", "ui_left" },
	right = { "move_right", "ui_right" },
});

-- Setup autorepeat so that holding up/down allows fast navigation in UI lists
crystal.input.configure_autorepeat({
	ui_up = { initial_delay = 0.5, period = 0.1 },
	ui_down = { initial_delay = 0.5, period = 0.1 },
});
```
