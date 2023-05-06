---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.ui

This module contains building blocks to create interactive menus and HUDs, with the [UIElement](ui_element) class as its cornerstone.

## Overview

The UI system implemented by this module is a retained mode UI toolkit, in which you maintain and update trees of [UI elements](ui_element). Different types of UI elements have different functionality, like drawing [images](image), [text](text), or [positioning child elements](vertical_list) relative to each other.

One unusual design choice in this system is that it does not have the concept of a single root UI element that all other elements are transitively parented to. Instead, any element without a parent is a root and works on its own as long as you call [update_tree](ui_element_update_tree) and [draw_tree](ui_element_draw_tree) on it (usually every frame). For example, you can make a game scene that manages a HUD and a pause menu completely independently (example below). This also means UI elements can exist [as drawable components](/crystal/api/graphics/world_widget) and be drawn as part of a game world.

```lua
local HUD = Class("HUD", crystal.Widget);
local PauseMenu = Class("PauseMenu", crystal.Widget);
-- Implement HUD and PauseMenu widgets here

local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.hud = HUD:new();
  self.pause_menu = PauseMenu:new();
end

MyScene.update = function(self, dt)
  local player_index = 1;
  for _, input in ipairs(crystal.input.player(player_index):events()) do
    self.pause_menu:handle_input(player_index, input);
  end
  self.hud:update_tree(dt);
  self.pause_menu:update_tree(dt);
end

MyScene.draw = function(self)
  self.hud:draw_tree();
  self.pause_menu:draw_tree(dt);
end
```

### Layout Concepts

The layout logic in this UI system works in two passes within [update_tree](ui_element_update_tree):

1. One bottom-up pass where elements report their desired size, which parent elements use to compute their own desired size.
2. One top-down pass where elements are given their final size based on how much is available.

When an element is parented to another, their relationship is represented by a [Joint](joint). Joints are used to specify child-specific properties on how they should be laid out by their parent. Because different types of container elements ([HorizontalList](horizontal_list), [VerticalList](vertical_list), [Overlay](overlay), etc.) offer different options, they also work with different joint types. The documentation type for elements that can have child elements always mentions what type of joints they create for their children.

For convenience, methods on an element's joint can be accessed transparently through the element itself. This is the same [aliasing](/crystal/extensions/oop/#aliasing) mechanism which allows [Component](/crystal/api/ecs/component) methods to be called through entities.

```lua
local inventory_item = crystal.Overlay:new();
local icon = inventory_item:add_child(crystal.Image:new(crystal.assets.get("sword.png")));
local equipped_checkmark = inventory_item:add_child(crystal.Image:new(crystal.assets.get("checkmark.png")));
-- `set_alignment` is a method defined on OverlayJoint
-- We could also access it as icon:joint():set_alignment()
icon:set_alignment("center", "center");
equipped_checkmark:set_alignment("right", "bottom");
```

### Player Interactions

UI elements can respond to the mouse pointer being on or away from them with a number of [callbacks](ui_element.html#callbacks).

UI elements can also have action inputs [bound](ui_element_bind_input) to them, to be executed either any time the corresponding key is pressed or only while they are [focused](/crystal/api/ui/ui_element_is_focused). These input bindings are processed whenever you ask a tree of UI element to [handle an input](ui_element_handle_input).

### Animation

This module does not provide any functionality specific to animation. However, [Widget](widget) elements have a [script](/crystal/api/script/script) associated with them, which you can use to drive change over time. The example below illustrates how to implement a flashing image:

```lua
local FlashingImage = Class("FlashingImage", crystal.Widget);

FlashingImage.init = function(self, texture)
  FlashingImage.super.init(self);
  local image = self:set_child(crystal.Image:new(texture));
  self:script():run_thread(function(self)
    while true do
      image:set_opacity(math.cos(self:time()));
      self:wait_frame();
    end
  end);
end
```

### Adding Custom Elements

Most of the time, you will be building HUD widgets and menus by combining existing element types. However, it is possible your game needs to draw or layout content in a way that is not achievable with built-in element types. In this situation, you can implement you own element types by inheriting from [UIElement](ui_element), [Wrapper](wrapper), or [Container](container).

If you do, make sure to consult the [advanced UI Element methods](/crystal/api/ui/ui_element.html#implementing-custom-elements) you are likely to need in the process.

- To implement a new leaf element (like [Border](border) or [Text](text)), you should reference the implementation of [Image](image).
- To implement a new single-child element (like [Painter](painter) or [Widget](widget)), you should reference the implementations of [Widget](widget) and its [Wrapper](wrapper) parent class.
- To implement a new multi-child element (like [Overlay](overlay) or [VerticalList](vertical_list)), you should reference the implementations of [Overlay](overlay) and its [Container](container) parent class.

## Functions

| Name                                      | Description                                                           |
| :---------------------------------------- | :-------------------------------------------------------------------- |
| [crystal.ui.font](font)                   | Returns a previously registered [font](https://love2d.org/wiki/Font). |
| [crystal.ui.register_font](register_font) | Registers a [font](https://love2d.org/wiki/Font).                     |

## Classes

### Leaf UI elements

| Name                            | Description                                                        |
| :------------------------------ | :----------------------------------------------------------------- |
| [crystal.Border](border)        | A [UI element](ui_element) which draws a border around itself.     |
| [crystal.Image](image)          | A [UI element](ui_element) which draws a texture or a solid color. |
| [crystal.Text](text)            | A [UI element](ui_element) which draws text.                       |
| [crystal.UIElement](ui_element) | Base class for all UI building blocks.                             |

### Containers & Wrappers

| Name                                      | Description                                                                |
| :---------------------------------------- | :------------------------------------------------------------------------- |
| [crystal.Container](container)            | A [UI element](ui_element) which can contain multiple child elements.      |
| [crystal.HorizontalList](horizontal_list) | A [Container](container) which aligns children horizontally.               |
| [crystal.Overlay](overlay)                | A [Container](container) which aligns children relatively to itself.       |
| [crystal.Painter](painter)                | A [Wrapper](wrapper) which applies a shader to its child.                  |
| [crystal.RoundedCorners](rounded_corners) | A [Painter](painter) which crops the corners of its child.                 |
| [crystal.Switcher](switcher)              | A [Container](container) which draws only one child at a time.             |
| [crystal.VerticalList](vertical_list)     | A [Container](container) which aligns children vertically.                 |
| [crystal.Widget](widget)                  | A [Wrapper](wrapper) which manages a [Script](/crystal/api/script/script). |
| [crystal.Wrapper](wrapper)                | A [UI element](ui_element) which can contain one child element.            |

### Joints

| Name                                                 | Description                                                                                     |
| :--------------------------------------------------- | :---------------------------------------------------------------------------------------------- |
| [crystal.BasicJoint](basic_joint)                    | A [Joint](joint) with common padding and alignment options.                                     |
| [crystal.HorizontalListJoint](horizontal_list_joint) | A [Joint](joint) specifying how elements are positioned in a [HorizontalList](horizontal_list). |
| [crystal.Joint](joint)                               | Defines how a [UI element](ui_element) should be laid out by its parent.                        |
| [crystal.Padding](padding)                           | Utility class storing up/down/left/right padding amounts.                                       |
| [crystal.VerticalListJoint](vertical_list_joint)     | A [Joint](joint) specifying how elements are positioned in a [VerticalList](vertical_list).     |

## Enums

| Name                                        | Description                                                  |
| :------------------------------------------ | :----------------------------------------------------------- |
| [BindingRelevance](binding_relevance)       | Describes in which context an input binding can be executed. |
| [Direction](direction)                      | A cardinal direction.                                        |
| [HorizontalAlignment](horizontal_alignment) | Distinct ways to align content horizontally.                 |
| [VerticalAlignment](vertical_alignment)     | Distinct ways to align content vertically.                   |
