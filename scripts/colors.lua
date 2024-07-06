#!/usr/bin/env lua
package.path = package.path .. ';./src/?.lua;./src/?/init.lua'
local system = require('system')
local math = require('math')
local util = require('replace.util')
local COLORS = require('replace.colors')

---@diagnostic disable-next-line
---@type boolean, number, number
local ok, _lines, columns = pcall(system.termsize)
if not ok then columns = 0 end
print('Available colors:')
---@type string[]
local colors = {}
local maxlen = 0
---@diagnostic disable-next-line
for name, _ in pairs(COLORS.FG) do
  maxlen = math.max(maxlen, #name)
  table.insert(colors, name)
end
local len, sep = 0, ''
table.sort(colors)
for _index, name in pairs(colors) do
  if name == 'ColorOff' or name == 'clear' then goto continue end
  ---@type string
  local color = COLORS.FG[name]
  local pname = util.padright(name, maxlen)
  if len + #pname + #sep > columns then
    len, sep = 0, ''
    print('')
  end
  io.write(sep .. color .. pname .. COLORS.ColorOff)
  len = len + #pname + #sep
  sep = ' '
  ::continue::
end
print('')

-- vim: set fdm=marker fmr=--#region,--#endregion sts=2 sw=2:
