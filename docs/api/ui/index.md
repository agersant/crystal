---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.ui

## Functions

| Name                    | Description                                                |
| :---------------------- | :--------------------------------------------------------- |
| [crystal.ui.font](font) | Returns a registered [font](https://love2d.org/wiki/Font). |

## Classes

| Name                                      | Description                                                                                                                              |
| :---------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------- |
| [crystal.BasicJoint](basic_joint)         | A [Joint](joint) with common padding and alignment options.                                                                              |
| [crystal.Border](border)                  | A [UI element](ui_element) which draws a border.                                                                                         |
| [crystal.Container](container)            | A [UI element](ui_element) which can contain multiple child elements.                                                                    |
| [crystal.HorizontalList](horizontal_list) | A [Container](container) which aligns children horizontally.                                                                             |
| [crystal.Image](image)                    | A [UI element](ui_element) which draws a texture or a solid color.                                                                       |
| [crystal.Joint](joint)                    | Defines how a [UI element](ui_element) should be laid out by its parent.                                                                 |
| [crystal.ListJoint](list_joint)           | A [Joint](joint) specifying how elements should be positioned in a [HorizontalList](horizontal_list) or a [VerticalList](vertical_list). |
| [crystal.Overlay](overlay)                | A [Container](container) which aligns children relatively to itself.                                                                     |
| [crystal.Padding](padding)                | A class storing up/down/left/right padding amounts.                                                                                      |
| [crystal.Painter](painter)                | A [Wrapper](wrapper) which applies a shader to its child.                                                                                |
| [crystal.RoundedCorners](rounded_corners) | A [Painter](painter) which crops the corners of its child.                                                                               |
| [crystal.Switcher](switcher)              | A [Container](container) which draws only one child at a time.                                                                           |
| [crystal.Text](text)                      | A [UI element](ui_element) which draws text.                                                                                             |
| [crystal.UIElement](ui_element)           | Base class for all UI building blocks.                                                                                                   |
| [crystal.VerticalList](vertical_lsit)     | A [Container](container) which aligns children vertically.                                                                               |
| [crystal.Widget](widget)                  | A [Wrapper](wrapper) which manages a [Script](/crystal/api/script/script).                                                               |
| [crystal.Wrapper](wrapper)                | A [UI element](ui_element) which can contain one child element.                                                                          |

## Enums

| Name                                        | Description                                  |
| :------------------------------------------ | :------------------------------------------- |
| [HorizontalAlignment](horizontal_alignment) | Distinct ways to align content horizontally. |
| [VerticalAlignment](vertical_alignment)     | Distinct ways to align content vertically.   |
