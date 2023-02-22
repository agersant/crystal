---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Script:delta_time

Returns the delta time that was passed to the last [Script:update](script_update) call.

{: .note}
Scripts do not always run within a [Script:update](script_update) call where this `delta_time` value makes sense. For example, scripts can run in response to a [Script:signal](script_signal) call.

## Usage

```lua
script:delta_time()
```

### Returns

| Name         | Type     | Description            |
| :----------- | :------- | :--------------------- |
| `delta_time` | `number` | Delta time in seconds. |

## Example

```lua
local script = crystal.Script:new(function(self)
  print(self:delta_time());
end);
script:update(0.01); -- prints 0.01
```
