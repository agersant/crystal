---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.input

## Functions

| Name                                                                           | Description                                                                               |
| :----------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------- |
| [crystal.input.player](player)                                                 | Returns the [InputPlayer](input_player) representing a player.                            |
| [crystal.input.assign_gamepad](assign_gamepad)                                 | Assigns a gamepad to a player.                                                            |
| [crystal.input.map_axis_to_binary_actions](map_axis_to_binary_actions)         | Map analog positions on gamepad sticks (axis) to binary actions.                          |
| [crystal.input.configure_autorepeat](configure_autorepeat)                     | Defines which actions emit events while inputs are being held, and how frequently.        |
| [crystal.input.set_unassigned_gamepad_handler](set_unassigned_gamepad_handler) | Defines a callback function which runs when a button is pressed on an unassigned gamepad. |
| [crystal.input.unassign_gamepad](unassign_gamepad)                             | Unassigns a player's current gamepad.                                                     |

## Classes

| Name                                    | Description                                                                               |
| :-------------------------------------- | :---------------------------------------------------------------------------------------- |
| [crystal.InputListener](input_listener) | A [Component](/crystal/api/ecs/component) which allows an entity to receive input events. |
| [crystal.InputSystem](input_system)     | A [System](/crystal/api/ecs/system) which dispatches input events.                        |
| [InputPlayer](input_player)             | Object handling keybinds and input events for a player.                                   |
