#!/usr/bin/env lua
package.path = './src/?.lua;./src/*/init.lua;' .. package.path
local util = require('replace.util')
local swap = require('replace.swap')
local colors = require('replace.colors')
--#region as command
--- @class SwapWord.CallState
--- @field print_debug boolean
--- @field call string?
--- @field as_test_case boolean
--- @field exit boolean
--- @field options string
--- @field pattern string
--- @field repl string
--- @field text string
--- @field ints integer[]
--- @field expected string?

-- luacov: disable
local function parse_args(arg) -- ##usage
  -- #_# allows choice of which tests to run
  ---@type SwapWord.CallState
  local out = {
    exit = false,
    print_debug = false,
    --- @diagnostic disable
    pattern = nil,
    repl = nil,
    text = nil,
    --- @diagnostic enable
    ints = {},
    options = 'a',
    as_test_case = false,
  }
  local funcs = { swap = true, bitand = true, bitor = true }
  for i = 1, #arg, 1 do
    ---@type string
    local v = arg[i]
    if funcs[v] then -- #_## swap|bitand|bitor -- use the named function
      out.call = v
    elseif v == '--debug' then -- #_## print debug information
      out.print_debug = true
    elseif v == '--quiet' then -- #_## don't print debug information
      out.print_debug = false
    elseif v == '--options' or v == '-o' then -- #_# option_string ## pass option string defaults to `ai`
      out.options = arg[i+1]; i = i + 1
    elseif v == '--pattern' or v == '-p' then -- #_# matching pattern ## pass matching pattern
      out.pattern = arg[i+1]; i = i + 1
    elseif v == '--replacement' or v == '-r' then -- #_# replacment_pattern ## pass replacement pattern
      out.repl = arg[i+1]; i = i + 1
    elseif v == '--text' or v == '-t' then -- #_# original_text ## pass text string
      out.text = arg[i+1]; i = i + 1
    elseif v == '--int' or v == '-i' then -- #_# integer ## add an integer for testing bitand/bitor
      i = i + 1
      local int = tonumber(arg[i])
      if int ~= nil then table.insert(out.ints, int) end
    elseif v == '--testcase' then -- #_## print out result as a test case
      out.as_test_case = true
    elseif v == '--expected' or v == '-e' then -- #_# string ## what the replacement should be
      out.expected = arg[i+1]; i = i + 1
    elseif v == '--help' or v == '-h' then -- #_## print this message
      util.usage(arg[0], 'parse_args', arg[0]);
      out.exit = true
      return out
    end
    -- #_## Named functions:
    -- #_##    swap
    -- #_##    bitand
    -- #_##    bitor
    -- #_## Case and option names:
    -- #_##    c -- camelCase
    -- #_##    d -- dot.case
    -- #_##    k -- kebab-case
    -- #_##    n -- snake_case (n because s is used by POSIX)
    -- #_##    p -- PascalCase
    -- #_##    u -- uppercase
    -- #_##    l -- lowercase
    -- #_##    i -- case insensitive (also a regex option sowmewhat equivalent to ul)
    -- #_##    smix -- regex options
    -- #_##    a -- all cases equivalent of cdknpi
  end -- ## end usage
  -- Test state...
  --- @type string[]
  local errors = {}
  if out.call == 'swap' then
    if out.pattern == nil then table.insert(errors, 'missing matching pattern (-p)') end
    if out.text == nil then table.insert(errors, 'missing text (-t)') end
    if out.repl == nil then table.insert(errors, 'missing replacement pattern (-r)') end
  elseif out.call == 'bitand' or out.call == 'bitor' then
    if #out.ints < 2 then table.insert(errors, 'not enough integers to test') end
  end
  if #errors > 0 then
    out.exit = true
    local error_string = '';
    local sep = ' '
    for _, e in pairs(errors) do error_string = error_string .. sep .. e; sep = ', ' end
    print('Unable to run' .. error_string)
  end
  return out
end

local state = parse_args(arg)
if state.exit then goto exit end
if not state.call then
  print('Unable to run a function no call set')
elseif state.call == 'bitand' then
  local a = swap.bitand(state.ints[1], state.ints[2])
  print('bitand result:', a, 'from', state.ints[1], state.ints[2])
elseif state.call == 'bitor' then
  local a = swap.bitor(state.ints[1], state.ints[2])
  print('bitor result:', a, 'from', state.ints[1], state.ints[2])
elseif state.call == 'swap' then
  if state.print_debug then util.DEBUG = true end
  local a = swap.swap_words(state.text, state.pattern, state.repl, state.options)
  --local txt = { original_text = state.text, pattern = state.pattern, replacement = state.repl, options = state.options }
  print(util.ldump('DarkCyan', state.pattern, state.repl, 'options: "' .. state.options .. '" '))
  local color = state.expected == nil and '' or a == state.expected and 'Green' or 'Red'
  local rest =  state.expected and ' "' .. state.expected .. '"' or ''
  --print(util.ldump('DarkCyan', txt) .. ' ' .. util.ldump(color, '"' .. a .. '"', rest))
  print(util.ldump(color, '"' .. a .. '"', rest))
end
::exit::
-- luacov: enable
--#endregion as command

-- vim: set fdm=marker fmr=--#region,--#endregion sts=2 sw=2:
