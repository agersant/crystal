---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# RoundedCorners:set_radius

Sets the corner radius for all corners at once.

## Usage

```lua
rounded_corners:set_radius(radius)
```

### Arguments

| Name     | Type     | Description                         |
| :------- | :------- | :---------------------------------- |
| `radius` | `number` | Corner radius for all four corners. |

## Usage

```lua
rounded_corners:set_radius(top_left, top_right, bottom_right, bottom_left)
```

### Arguments

| Name           | Type     | Description                 |
| :------------- | :------- | :-------------------------- |
| `top_left`     | `number` | Top left corner radius.     |
| `top_right`    | `number` | Top right corner radius.    |
| `bottom_right` | `number` | Bottom left corner radius.  |
| `bottom_left`  | `number` | Bottom right corner radius. |

## Examples

Using a single value for all corners:

```lua
local rounded_corners = crystal.RoundedCorners:new();
rounded_corners:set_radius(8);
```

Using individual values for each corner:

```lua
local rounded_corners = crystal.RoundedCorners:new();
rounded_corners:set_radius(0, 8, 8, 0);
```
