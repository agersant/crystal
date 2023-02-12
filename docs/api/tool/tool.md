---
parent: crystal.tool
grand_parent: API Reference
---

# crystal.Tool

Base class for tools to inherit from.

## Fields

| Name      | Type      | Description                                                                                                                                                 |
| :-------- | :-------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `visible` | `boolean` | _(read-only)_ Indicates whether the tool is currently visible. Use [crystal.tool.show](show) or [crystal.tool.hide](hide) instead of writing to this field. |

## Methods

| Name          | Description                                                                                                                                                  |
| :------------ | :----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `draw`        | Called every frame while the tool is visible. Default implementation does nothing.                                                                           |
| `hide`        | Called when the tool stops being visible. Default implementation does nothing.                                                                               |
| `key_pressed` | Called when the tool receives a key press. Arguments after `self` are the same as those of [love.keypressed](https://love2d.org/wiki/love.keypressed).       |
| `text_input`  | Called when the tool receives text input. Arguments after `self` are the same as those of [love.textinput](https://love2d.org/wiki/love.textinput).          |
| `show`        | Called when the tool becomes visible. Default implementation does nothing.                                                                                   |
| `update`      | Called every frame. Default implementation does nothing. Arguments after `self` are the same as those of [love.update](https://love2d.org/wiki/love.update). |
