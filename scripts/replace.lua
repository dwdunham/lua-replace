#!/usr/bin/env lua
package.path = package.path .. ';./src/?.lua;./src/?/init.lua'
local util = require('replace.util')
local brace = require('replace.brace')

--#region as command
--- @class Braces.CallState
--- @field print_debug boolean
--- @field call string?
--- @field value string?
--- @field as_test_case boolean
--- @field exit boolean

-- luacov: disable
local function parse_args(arg) -- ##usage
  -- #_# allows choice of which tests to run
  --- @type Braces.CallState
  local out = {
    exit = false,
    print_debug = false,
    as_test_case = false,
  }
  for i = 1, #arg, 1 do
    --- @type string
    local v = arg[i]
    if v == '--debug' then -- #_## print debug information
      out.print_debug = true
    elseif v == '--quiet' then -- #_## don't print debug information
      out.print_debug = false
    elseif v == 'expand' then -- #_## use the expand function
      out.call = v
    elseif v == '--testcase' then -- #_## print out result as a test case
      out.as_test_case = true
    elseif v == '-v' or v == '--value' then -- #_## value # set the string argument
      out.value = #arg > i and arg[i+1] or '';
      i = i + 1
    elseif v == '--help' or v == '-h' then -- #_## print this message
      util.usage(arg[0], 'parse_args', arg[0]);
      out.exit = true
      return out;
    end
  end -- ## end usage
  return out
end
local state = parse_args(arg)
if state.exit then goto exit end
if not state.call then
  print('Unable to run a function no call set')
elseif state.call == 'expand' then
  if state.print_debug then util.DEBUG = true end
  local a = brace.expand(state.value)
  local sep = ''
  if state.as_test_case then
    local result = '';
    for _, v in pairs(a) do result = result .. sep .. v; sep = ' '; end
    print("{ ['"..state.value.."'] = '" .. result .. "' },")
  else
    io.write(FG.DarkCyan .. state.value .. ColorOff)
    for _, v in pairs(a) do io.write(' ' .. v) end
    print('')
  end
end
::exit::
-- luacov: enable
--#endregion as command

-- vim: set fdm=marker fmr=--#region,--#endregion sts=2 sw=2:
