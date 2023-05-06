---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:set_player_index

Sets or clears which player is allowed to focus and emit inputs to this element and its descendents.

{: .warning}
This function does not retro-actively clear focus if a different player's focus is currently within this one.

## Usage

```lua
ui_element:set_player_index(player_index)
```

### Arguments

| Name           | Type              | Description                                                                                              |
| :------------- | :---------------- | :------------------------------------------------------------------------------------------------------- |
| `player_index` | `number` \| `nil` | Number identifying the player who should have sole control over this element's focus and inputs, if any. |

## Examples

```lua
local PreferencesMenu = Class("PreferencesMenu", crystal.Widget);
-- PreferencesMenu implementation goes here

local player_2_preferences = PreferencesMenu:new();
player_2_preferences:set_player_index(2);
player_2_preferences:focus_tree(2);
```
