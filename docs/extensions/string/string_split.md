---
parent: String Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# string.split

Splits a string into a table, matching on specific delimiters.

## Usage

```lua
string.split(my_string, delimiters)
```

### Arguments

| Name         | Type     | Description                                                 |
| :----------- | :------- | :---------------------------------------------------------- |
| `my_string`  | `string` | String to split.                                            |
| `delimiters` | `string` | String whose individual characteres are used as delimiters. |

### Returns

| Name           | Type    | Description                         |
| :------------- | :------ | :---------------------------------- |
| `split_result` | `table` | List of components after the split. |

## Examples

```lua
local sentence = "Welcome to my shop, adventurer!";
local words = sentence:split(" ,!");
for _, word in ipairs(words) do
  -- Sequentially prints "welcome", "to", "my", "shop" and "adventurer"
  print(word);
end
```
