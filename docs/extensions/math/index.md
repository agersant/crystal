---
parent: Lua Extensions
has_children: true
has_toc: false
---

# Math Extensions

This module contains mathematical utility functions. All functions are registered on the global `math` table and can be accessed as `math.example()`.

## Constants

| Name     | Description                                   |
| :------- | :-------------------------------------------- |
| math.tau | 360 degrees in radians (equals `2 * math.pi`) |

## Functions

| Name                                             | Description                                                                        |
| :----------------------------------------------- | :--------------------------------------------------------------------------------- |
| [math.angle_between](math_angle_between)         | Returns the shortest rotation between two vectors.                                 |
| [math.angle_delta](math_angle_delta)             | Returns the shortest rotation between two angles.                                  |
| [math.angle_to_cardinal](math_angle_to_cardinal) | Converts an angle into the closest cardinal directions (including intercardinals). |
| [math.clamp](math_clamp)                         | Clamps a number between a minimum and maximum value.                               |
| [math.cross_product](math_cross_product)         | Computes the length of the cross product between two `(x, y, 0)` 3D vectors.       |
| [math.damp](math_damp)                           | Exponential decay interpolation.                                                   |
| [math.distance](math_distance)                   | Computes the distance between two 2D points.                                       |
| [math.distance_squared](math_distance_squared)   | Computes the squared distance between two 2D points.                               |
| [math.dot_product](math_dot_product)             | Computes the dot product between 2D vectors.                                       |
| [math.index_to_xy](math_index_to_xy)             | Converts an integer into coordinates into a 2D array.                              |
| [math.length](math_length)                       | Computes the length of a 2D vector.                                                |
| [math.length_squared](math_length_squared)       | Computes the squared length of a 2D vector.                                        |
| [math.lerp](math_lerp)                           | Linear interpolation between two numbers.                                          |
| [math.normalize](math_normalize)                 | Scales a 2D vector to length 1.                                                    |
| [math.round](math_round)                         | Rounds a number to the nearest integer.                                            |

### Easing Functions

For a visual reference of easing functions, see [https://easings.net/](https://easings.net/). Note that the `bounce` easing functions in Crystal have a few more bounces to them than these illustrations.

All easing functions expect a value between 0 and 1, and return a value between 0 and 1 with easing applied.

- `math.ease_linear`
- `math.ease_in_quadratic`
- `math.ease_out_quadratic`
- `math.ease_in_out_quadratic`
- `math.ease_in_cubic`
- `math.ease_out_cubic`
- `math.ease_in_out_cubic`
- `math.ease_in_quartic`
- `math.ease_out_quartic`
- `math.ease_in_out_quartic`
- `math.ease_in_quintic`
- `math.ease_out_quintic`
- `math.ease_in_out_quintic`
- `math.ease_in_bounce`
- `math.ease_out_bounce`
- `math.ease_in_out_bounce`
