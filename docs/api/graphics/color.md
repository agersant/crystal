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

| Name                                  | Value                                                                                                                                              |
| :------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| `crystal.Color.sunflower`             | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #FFC312; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0xFFC312` |
| `crystal.Color.radiant_yellow`        | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #F79F1F; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0xF79F1F` |
| `crystal.Color.puffins_bill`          | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #EE5A24; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0xEE5A24` |
| `crystal.Color.red_pigment`           | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #EA2027; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0xEA2027` |
| `crystal.Color.energos`               | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #C4E538; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0xC4E538` |
| `crystal.Color.android_green`         | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #A3CB38; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0xA3CB38` |
| `crystal.Color.pixelated_grass`       | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #009432; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x009432` |
| `crystal.Color.turkish_aqua`          | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #006266; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x006266` |
| `crystal.Color.blue_martina`          | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #12CBC4; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x12CBC4` |
| `crystal.Color.mediterranean_sea`     | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #1289A7; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x1289A7` |
| `crystal.Color.merchant_marine_blue`  | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #0652DD; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x0652DD` |
| `crystal.Color.leagues_under_the_sea` | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #1B1464; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x1B1464` |
| `crystal.Color.lavender_rose`         | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #FDA7DF; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0xFDA7DF` |
| `crystal.Color.lavender_tea`          | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #D980FA; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0xD980FA` |
| `crystal.Color.forgotten_purple`      | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #9980FA; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x9980FA` |
| `crystal.Color.circumorbital_ring`    | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #5758BB; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x5758BB` |
| `crystal.Color.bara_red`              | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #ED4C67; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0xED4C67` |
| `crystal.Color.very_berry`            | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #B53471; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0xB53471` |
| `crystal.Color.hollyhock`             | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #833471; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x833471` |
| `crystal.Color.magenta_purple`        | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #6F1E51; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x6F1E51` |

### Tools Palette

Unstable
{: .label-yellow}

These colors are used by crystal to draw interactive tools like the [console](/crystal/tools/console).

| Name                  | Value                                                                                                                                              |
| :-------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| `crystal.Color.black` | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #000000; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x000000` |
| `crystal.Color.white` | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #FFFFFF; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0xFFFFFF` |
| `crystal.Color.red`   | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #FF5733; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0xFF5733` |
| `crystal.Color.green` | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #84D728; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x84D728` |
| `crystal.Color.cyan`  | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #00B3CC; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x00B3CC` |
| `crystal.Color.grey0` | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #11121D; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x11121D` |
| `crystal.Color.greyA` | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #1A1B2B; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x1A1B2B` |
| `crystal.Color.greyB` | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #22263D; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x22263D` |
| `crystal.Color.greyC` | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #373C53; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0x373C53` |
| `crystal.Color.greyD` | <span class="d-inline-block p-2 mr-1 v-align-middle" style="background: #B0BED5; border: 2px solid #EEEBEE; border-radius: 4px;"></span>`0xB0BED5` |

## Examples

```lua
local orange = crystal.Color:new(0xFFA500);
love.graphics.setColor(orange);
love.graphics.rectangle("fill", 20, 50, 60, 120);
```
