---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Thread:script

Returns the script owning this thread.

## Usage

```lua
thread:script()
```

### Returns

| Name     | Type             | Description                |
| :------- | :--------------- | :------------------------- |
| `script` | [Script](script) | Script owning this thread. |

## Examples

````lua

```lua
local script = crystal.Script:new();

script:run_thread(function(self)
  assert(self:script() == script);
end);
````
