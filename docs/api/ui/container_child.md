---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Container:child

Returns a child element by index.

## Usage

```lua
container:child(index)
```

### Arguments

| Name    | Type     | Description            |
| :------ | :------- | :--------------------- |
| `index` | `number` | Child index (1-based). |

### Returns

| Name    | Type                             | Description                           |
| :------ | :------------------------------- | :------------------------------------ |
| `child` | [UIElement](ui_element) \| `nil` | Child at the specified index, if any. |

## Examples

```lua
local list = crystal.VerticalList:new();
local sword = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/sword.png")));
local shield = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/shield.png")));
local armor = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/armor.png")));
assert(list:child(2) == shield);
```
