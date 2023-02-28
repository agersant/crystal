---
parent: crystal.tool
grand_parent: API Reference
nav_order: 1
---

# crystal.tool.is_visible

Returns whether a tool is currently visible or not.

## Usage

```lua
crystal.tool.is_visible(tool_name)
```

### Arguments

| Name        | Type     | Description                               |
| :---------- | :------- | :---------------------------------------- |
| `tool_name` | `string` | Name of the tool to check visibility for. |

### Returns

| Name      | Type      | Description                                             |
| :-------- | :-------- | :------------------------------------------------------ |
| `visible` | `boolean` | True if the tool is currently visible, false otherwise. |

## Examples

```lua
local MyTool = Class("MyTool", crystal.Tool);
crystal.tool.add(MyTool:new());
assert(crystal.tool.is_visible("MyTool"));
```
