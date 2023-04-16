---
parent: crystal.scene
grand_parent: API Reference
nav_order: 2
---

# crystal.Transition

Base class for transitions to inherit from. Transitions are used to decorate scene changes or camera changes. Some example transitions are color fades or screen wipes.

This class is of little use on its own as the default transition is an abrupt cut. You should implement your own sublasses, or use the built-in transitions described on this page.

## Constructor

```lua
crystal.Transition:new(duration, easing)
```

- The `duration` parameter is a `number` in seconds.
- The `easing` parameter is an easing function, such as those provided in the [math](/crystal/extensions/math) Lua extension.

```lua
local MyTransition = Class("MyTransition", crystal.Transition);

MyTransition.init = function(self, duration, easing)
  MyTransition.super.init(duration, easing);
end

local my_transition = MyTransition:new(0.2, math.ease_in_cubic);
```

## Methods

| Name                            | Description                                                  |
| :------------------------------ | :----------------------------------------------------------- |
| [duration](transition_duration) | Returns the duration of the transition, in seconds.          |
| [easing](transition_easing)     | Returns the easing function used to smooth the transition.   |
| [draw](transition_draw)         | Draws the transition. This method is meant to be overridden. |

## Built-in Transitions

A few common transitions are included with Crystal.

- `crystal.Transition.FadeToBlack`
- `crystal.Transition.FadeFromBlack`
- `crystal.Transition.ScrollLeft`
- `crystal.Transition.ScrollRight`
- `crystal.Transition.ScrollUp`
- `crystal.Transition.ScrollDown`

These transitions can be constructed with duration and easing parameters. Their default values are `0.2` seconds and `math.ease_linear`.

## Examples

This example uses the `ScrollRight` built-in transition:

```lua
local old_scene = MyScene:new();
crystal.scene.replace(old_scene);

local new_scene = OtherScene:new();
local transition = crystal.Transition.ScrollRight:new(0.5, math.ease_in_out_cubic);
crystal.scene.replace(new_scene, transition);
```

This example reimplements the `FadeToBlack` and `FadeFromBlack` built-in transitions:

```lua
local MyFadeToBlack = Class("MyFadeToBlack", crystal.Transition);
MyFadeToBlack.draw = function(self, progress, width, height, draw_before, draw_after)
  draw_before();
  love.graphics.setColor(crystal.Color.black:alpha(progress));
  love.graphics.rectangle("fill", 0, 0, width, height);
end

local MyFadeFromBlack = Class("MyFadeFromBlack", crystal.Transition);
MyFadeFromBlack.draw = function(self, progress, width, height, draw_before, draw_after)
  draw_after();
  love.graphics.setColor(crystal.Color.black:alpha(progress));
  love.graphics.rectangle("fill", 0, 0, width, height);
end
```
