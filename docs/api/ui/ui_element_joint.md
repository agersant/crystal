---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:joint

Returns the [joint](joint) specifying how this element should be laid out by its parent.

This method emits an error when called on an element with no parent.

{: .note}
This method is rarely needed, as you can call joint methods transparently from the corresponding UI Element (eg. `element:padding()` instead of `element:joint():padding()`).

## Usage

```lua
ui_element:joint()
```

### Returns

| Name    | Type                    | Description                                                                       |
| :------ | :---------------------- | :-------------------------------------------------------------------------------- |
| `joint` | [Joint](joint) \| `nil` | Joint linking this element to its parent, or `nil` if this element has no parent. |

## Examples

```lua
local parent = crystal.Overlay:new();
local child = parent:add_child(crystal.Image:new());
local joint = child:joint();
print(joint:horizontal_alignment()); -- Prints "left"
```
