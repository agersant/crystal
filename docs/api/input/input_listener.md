---
parent: crystal.input
grand_parent: API Reference
---

# crystal.InputListener

A [Component](/crystal/api/ecs/component) which allows an entity to receive input events.

## Constructor

Like all other components, InputListener are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component).

## Methods

| Name                   | Description                                                                                         |
| :--------------------- | :-------------------------------------------------------------------------------------------------- |
| `input_player`         | Returns the [InputPlayer](input_player) associated with this InputListener.                         |
| `add_input_handler`    | Registers a function to handle action events.                                                       |
| `remove_input_handler` | Unregisters a function handling action events.                                                      |
| `dispatch_inputs`      | Executes input handler callbacks for all events held by the associated [InputPlayer](input_player). |

## Examples
