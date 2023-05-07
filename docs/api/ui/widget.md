---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.Widget

A [Wrapper](wrapper) which manages a [Script](/crystal/api/script/script). This is a good base class to inherit from when implementing UI components that need animation or other time-based logic.

The child of a `Widget` has a [Basic Joint](basic_joint) to adjust positioning preferences (padding, alignment, etc.).

## Constructor

```lua
crystal.Widget:new()
```

## Methods

| Name                    | Description                                |
| :---------------------- | :----------------------------------------- |
| [script](widget_script) | Returns the script managed by this widget. |

## Examples

This example implements a widget which can make an image pulsate over time.

```lua
local FlashingImage = Class("FlashingImage", crystal.Widget);

FlashingImage.init = function(self, texture)
  FlashingImage.super.init(self);
  self.image = self:set_child(crystal.Image:new(texture));
  self.pulsating = false;
end

FlashingImage.begin_pulse = function(self)
	if not self.pulsating then
	  local image = self.image;
      self:script():run_thread(function(self)
        while true do
          image:set_opacity(math.cos(self:time()));
          self:wait_frame();
        end
      end);
	end
end

FlashingImage.end_pulse = function(self)
  self:script():stop_all_threads();
  self.image:set_opacity(1);
end
```
