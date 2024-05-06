---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.input

The classes and functions in this module allow you to:

- Manage which physical buttons correspond to which actions in your game.
- Manage which input devices are assigned to which player (in a multiplayer game).
- Route input events to specific game [entities](/crystal/api/ecs/entity) like player characters.
- Implement [areas](mouse_area) that react to mouse inputs.

A player can have bindings to both keyboard and gamepad buttons at the same time. This allows them to seemlessly switch between input methods. For singleplayer games, you do not have to do anything related to [assigning](assign_gamepad) or [unassigning](unassign_gamepad) gamepads.

After configuring bindings, player inputs can be handled via [Scene:action_pressed](/crystal/api/scene/scene_action_pressed)/[Scene:action_released](/crystal/api/scene/scene_action_released). More conveniently, you can use these callbacks to forward the inputs to an [InputSystem](input_system) and rely on [InputListener](input_listener) components to implement actual responses.

## Functions

### Reading Inputs

| Name                                                       | Description                                                                            |
| :--------------------------------------------------------- | :------------------------------------------------------------------------------------- |
| [crystal.input.axis_action_value](axis_action_value)       | Returns the current value of a gamepad axis associated with a specific action.         |
| [crystal.input.current_mouse_target](current_mouse_target) | Returns the [mouse target](add_mouse_target) the mouse pointer is currently on top of. |
| [crystal.input.gamepad_id](gamepad_id)                     | Returns the gamepad assigned to the specified player, if any.                          |
| [crystal.input.input_method](input_method)                 | Returns the input method last used by the specified player.                            |
| [crystal.input.is_action_down](is_action_down)             | Returns whether any input mapped to a specific action is currently being pressed.      |
| [crystal.input.mouse_player](mouse_player)                 | Returns the player index of the player using the mouse.                                |

### Configuration

| Name                                                                           | Description                                                                                  |
| :----------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------- |
| [crystal.input.add_mouse_target](add_mouse_target)                             | Registers a rectangular area that supports mouse interaction.                                |
| [crystal.input.assign_gamepad](assign_gamepad)                                 | Assigns a gamepad to a player.                                                               |
| [crystal.input.assign_mouse](assign_mouse)                                     | Assigns the mouse to a player.                                                               |
| [crystal.input.bindings](bindings)                                             | Returns a table describing which actions are bound to which inputs for the specified player. |
| [crystal.input.configure_autorepeat](configure_autorepeat)                     | Defines which actions emit events while inputs are being held, and how frequently.           |
| [crystal.input.map_axis_to_actions](map_axis_to_actions)                       | Map positions on gamepad analog axis to binary actions.                                      |
| [crystal.input.set_bindings](set_bindings)                                     | Sets which actions are bound to which inputs for the specified player.                       |
| [crystal.input.set_unassigned_gamepad_handler](set_unassigned_gamepad_handler) | Defines a callback function which runs when a button is pressed on an unassigned gamepad.    |
| [crystal.input.unassign_gamepad](unassign_gamepad)                             | Unassigns a player's current gamepad.                                                        |

## Classes

| Name                                    | Description                                                                                               |
| :-------------------------------------- | :-------------------------------------------------------------------------------------------------------- |
| [crystal.InputListener](input_listener) | A [Component](/crystal/api/ecs/component) which allows an entity to receive input events.                 |
| [crystal.InputSystem](input_system)     | A [System](/crystal/api/ecs/system) which dispatches input events.                                        |
| [crystal.InputSystem](mouse_area)       | A [Component](/crystal/api/ecs/component) which allows an entity to receive mouse hover and click events. |

## Enums

| Name                             | Description                         |
| :------------------------------- | :---------------------------------- |
| [InputMethod](input_method_enum) | Device being used to play the game. |
