#!/usr/bin/env lua
package.path = package.path .. ';./src/?.lua;./src/*/init.lua'
local util = require('replace.util')
local swap = require('replace.swap')
--#region as command
--- @class SwapWord.CallState
--- @field print_debug boolean
--- @field call string?
--- @field value string[]
--- @field as_test_case boolean
--- @field exit boolean

-- luacov: disable
local function parse_args(arg) -- ##usage
  -- #_# allows choice of which tests to run
  ---@type SwapWord.CallState
  local out = {
    exit = false,
    print_debug = false,
    value = {},
    as_test_case = false,
  }
  for i = 1, #arg, 1 do
    ---@type string
    local v = arg[i]
    if v == '--debug' then -- #_## print debug information
      out.print_debug = true
    elseif v == '--quiet' then -- #_## don't print debug information
      out.print_debug = false
    elseif v == 'swap' then -- #_## use the swap words function
      out.call = v
    elseif v == '--testcase' then -- #_## print out result as a test case
      out.as_test_case = true
    elseif v == '-v' or v == '--value' then -- #_## value # set the string argument
      table.insert(out.value, #arg > i and arg[i+1] or '')
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
elseif state.call == 'swap' then
  if #state.value < 3 then
    print('Unable to run not enough arguments')
    goto exit
  end
  if state.print_debug then util.DEBUG = true end
  local text, pattern, repl, options = table.unpack(state.value)
  options = options or 'i'
  local a = swap.swap_words(text, pattern, repl, options)
  io.write(util.ldump('DarkCyan', state.value) .. ' ')
  print(a);
end
::exit::
-- luacov: enable
--#endregion as command

-- vim: set fdm=marker fmr=--#region,--#endregion sts=2 sw=2:
