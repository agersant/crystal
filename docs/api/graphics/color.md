---
parent: crystal.graphics
grand_parent: API Reference
---

# crystal.Color

A color, with RGBA components.

{: .note}
Color components are stored in the array part of these objects. This makes them compatible with LOVE functions that expect colors as `{r, g, b}` or `{r, g, b, a}` tables.

## Constructor

```lua
crystal.Color:new(hex_rgb, alpha)
```

- The `hex_rgb` parameter is a `number` (not a `string`!) listing the RGB components of the color (8 bits per channel). If `nil` or omitted, it defaults to `0x000000` (black).
- The alpha parameter is a number between 0 and 1 indicating the color opacity. If `nil` or omitted, it defaults to 1 (fully opaque).

```lua
local black_opaque  = crystal.Color:new();
local pink_opaque  = crystal.Color:new(0xFFC0CB, 1);
local turquoise_transparent  = crystal.Color:new(0x30D5C8, 0.5);
```

## Methods

| Name                 | Description                                                            |
| :------------------- | :--------------------------------------------------------------------- |
| [alpha](color_alpha) | Creates a new color with the same RGB components and a specific alpha. |

## Constants

### Debug Palette

These colors are used by Crystal to draw debug information on top of the game, such as collision shapes or navigation polygons.

| Name                                  | RGB        | Preview                                                                                                        |
| :------------------------------------ | :--------- | :------------------------------------------------------------------------------------------------------------- |
| `crystal.Color.sunflower`             | `0xFFC312` | <div style="width: 24px; height:24px; background: #FFC312; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.radiant_yellow`        | `0xF79F1F` | <div style="width: 24px; height:24px; background: #F79F1F; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.puffins_bill`          | `0xEE5A24` | <div style="width: 24px; height:24px; background: #EE5A24; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.red_pigment`           | `0xEA2027` | <div style="width: 24px; height:24px; background: #EA2027; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.energos`               | `0xC4E538` | <div style="width: 24px; height:24px; background: #C4E538; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.android_green`         | `0xA3CB38` | <div style="width: 24px; height:24px; background: #A3CB38; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.pixelated_grass`       | `0x009432` | <div style="width: 24px; height:24px; background: #009432; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.turkish_aqua`          | `0x006266` | <div style="width: 24px; height:24px; background: #006266; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.blue_martina`          | `0x12CBC4` | <div style="width: 24px; height:24px; background: #12CBC4; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.mediterranean_sea`     | `0x1289A7` | <div style="width: 24px; height:24px; background: #1289A7; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.merchant_marine_blue`  | `0x0652DD` | <div style="width: 24px; height:24px; background: #0652DD; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.leagues_under_the_sea` | `0x1B1464` | <div style="width: 24px; height:24px; background: #1B1464; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.lavender_rose`         | `0xFDA7DF` | <div style="width: 24px; height:24px; background: #FDA7DF; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.lavender_tea`          | `0xD980FA` | <div style="width: 24px; height:24px; background: #D980FA; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.forgotten_purple`      | `0x9980FA` | <div style="width: 24px; height:24px; background: #9980FA; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.circumorbital_ring`    | `0x5758BB` | <div style="width: 24px; height:24px; background: #5758BB; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.bara_red`              | `0xED4C67` | <div style="width: 24px; height:24px; background: #ED4C67; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.very_berry`            | `0xB53471` | <div style="width: 24px; height:24px; background: #B53471; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.hollyhock`             | `0x833471` | <div style="width: 24px; height:24px; background: #833471; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.magenta_purple`        | `0x6F1E51` | <div style="width: 24px; height:24px; background: #6F1E51; border: 2px solid #444; border-radius: 4px;"></div> |

### Tools Palette

Unstable
{: .label-yellow}

These colors are used by crystal to draw interactive tools like the [console](/crystal/tools/console).

| Name                  | RGB        | Preview                                                                                                        |
| :-------------------- | :--------- | :------------------------------------------------------------------------------------------------------------- |
| `crystal.Color.black` | `0x000000` | <div style="width: 24px; height:24px; background: #000000; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.white` | `0xFFFFFF` | <div style="width: 24px; height:24px; background: #FFFFFF; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.red`   | `0xFF5733` | <div style="width: 24px; height:24px; background: #FF5733; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.green` | `0x84D728` | <div style="width: 24px; height:24px; background: #84D728; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.cyan`  | `0x00B3CC` | <div style="width: 24px; height:24px; background: #00B3CC; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.grey0` | `0x11121D` | <div style="width: 24px; height:24px; background: #11121D; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.greyA` | `0x1A1B2B` | <div style="width: 24px; height:24px; background: #1A1B2B; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.greyB` | `0x22263D` | <div style="width: 24px; height:24px; background: #22263D; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.greyC` | `0x373C53` | <div style="width: 24px; height:24px; background: #373C53; border: 2px solid #444; border-radius: 4px;"></div> |
| `crystal.Color.greyD` | `0xB0BED5` | <div style="width: 24px; height:24px; background: #B0BED5; border: 2px solid #444; border-radius: 4px;"></div> |

## Examples

```lua
local orange = crystal.Color:new(0xFFA500);
love.graphics.setColor(orange);
love.graphics.rectangle("fill", 20, 50, 60, 120);
```
