---
parent: crystal.hot_reload
grand_parent: API Reference
nav_order: 1
---

# crystal.hot_reload.persist

Makes a piece of data persist through hot reloads.

How this works:

1. When the game is about to hot reload, all the `save` functions registered with `crystal.hot_reload.persist` are executed. The results are stored in a table, alongside their keys.
2. All engine and game files are unloaded and reloaded.
3. For every piece of data that was saved, we check that a `load` function with the same key was registered by the **reloaded** code. If there is one, it is called with the saved data as its argument.

{: .warning}
You should only save basic data (strings, numbers, booleans, or tables combining them) using this system. Attempting to save objects, entities, components, or functions will most likely not behave as intended.

## Usage

```lua
crystal.hot_reload.persist(key, save, load)
```

### Arguments

| Name   | Type       | Description                                                                                                              |
| :----- | :--------- | :----------------------------------------------------------------------------------------------------------------------- |
| `key`  | `string`   | A key identifying the saved data across the hot reload. Re-using a keys overwrites the previous `save`/`load` functions. |
| `save` | `function` | Returns the data to save.                                                                                                |
| `load` | `function` | Makes used of the saved data to restore state.                                                                           |

## Examples

This example from Crystal's [AI](/crystal/api/ai) module illustrates how the navigation debug overlay can stay active even after a hot reload:

```lua
local draw_navigation = false;
crystal.cmd.add("ShowNavigationOverlay", function() draw_navigation = true; end);
crystal.cmd.add("HideNavigationOverlay", function() draw_navigation = false; end);
crystal.hot_reload.persist("navigation_overlay",
	function() return draw_navigation end,
	function(d) draw_navigation = d end
);
```

This example illustrates how you could make a character position persist through hot reload:

```lua
local Player = Class("Player", crystal.Entity);

Player.init = function(self)
  self:add_component(crystal.Body);
  crystal.hot_reload.persist("player_position",
    function() return { self:position() } end,
    function(p) return self:set_position(p[1], p[2]) end
  );
end
```
