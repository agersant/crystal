---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.Padding

Utility class storing up/down/left/right padding amounts. This is often used by [Joint](joint) subclasses, and rarely instantiated directly in game code.

## Constructor

```lua
crystal.Padding:new()
```

## Methods

| Name                                             | Description                              |
| :----------------------------------------------- | :--------------------------------------- |
| [padding_bottom](padding_padding_bottom)         | Returns the bottom padding amount.       |
| [padding_left](padding_padding_left)             | Returns the left padding amount.         |
| [padding_right](padding_padding_right)           | Returns the right padding amount.        |
| [padding_top](padding_padding_top)               | Returns the top padding amount.          |
| [padding](padding_padding)                       | Returns all four padding amounts.        |
| [set_padding_bottom](padding_set_padding_bottom) | Sets the bottom padding amount.          |
| [set_padding_left](padding_set_padding_left)     | Sets the left padding amount.            |
| [set_padding_right](padding_set_padding_right)   | Sets the right padding amount.           |
| [set_padding_top](padding_set_padding_top)       | Sets the top padding amount.             |
| [set_padding_x](padding_set_padding_x)           | Sets the left and right padding amounts. |
| [set_padding_y](padding_set_padding_y)           | Sets the top and bottom padding amounts. |
| [set_padding](padding_set_padding)               | Sets all four padding amounts.           |

## Examples

In this example, an [Image](image) is added to an [Overlay](overlay) container. Overlay containers use [BasicJoint](basic_joint) to configure their children, and [BasicJoint] transparently exposes a `Padding` object.

```lua
local overlay = crystal.Overlay:new();
local image = overlay:add_child(crystal.Image:new());
image:set_padding_x(20);
```
