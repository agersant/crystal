---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:player_index

Returns which player is allowed to focus and emit inputs to this element and its descendents. By default, elements do not have a specific player associated with them.

## Usage

```lua
ui_element:player_index()
```

### Returns

| Name    | Type              | Description                                                                                      |
| :------ | :---------------- | :----------------------------------------------------------------------------------------------- |
| `index` | `number` \| `nil` | Number identifying the player who has sole control over this element's focus and inputs, if any. |

## Examples

```lua
local PreferencesMenu = Class("PreferencesMenu", crystal.Widget);
-- PreferencesMenu implementation goes here

local player_2_preferences = PreferencesMenu:new();
player_2_preferences:set_player_index(2);
print(player_2_preferences:player_index()); -- Prints "2"

player_2_preferences:focus_tree(2);
```
