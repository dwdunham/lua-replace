package.path = package.path .. ';./src/?.lua;./src/?/init.lua'
local math = require('math')
local brace = require('replace.brace')
local util = require('replace.util')
local colors = require('replace.colors')
FG = colors.FG
BG = colors.BG
UL = colors.UL
ColorOff = colors.ColorOff

-- TODO: Allow to choose whether to use colors or not.
local patterns = {
  -- edge cases (where no expansion occurs or mismatching braces
  { ['abc'] = 'abc' },
  { ['{ab}'] = '{ab}' },
  { ['}a{'] = '}a{' },
  { ['{a'] = '{a' },
  { ['}a{b,c}'] = '}ab }ac' },
  { ['a\\{b,c}d'] = 'a{b,c}d' },
  { ['a{b\\,c}d'] = 'a{b,c}d' },
  { ['a{b,c\\}d'] = 'a{b,c}d' },
  -- single simple expansions
  { ['{a,b}c'] = 'ac bc' },
  { ['a{b,c}'] = 'ab ac' },
  { ['a{b,c}e'] = 'abe ace' },
  -- simple adjacent expansions
  { ['a{r,t}{,s}i'] = 'ari arsi ati atsi' },
  { ['a{r,t}b{,s}i'] = 'arbi arbsi atbi atbsi' },
  { ['a{b,c}d{e,f}'] = 'abde abdf acde acdf' },
  -- simple recursive expansions
  { ['a{t{o,v,e},c}i'] = 'atoi atvi atei aci' },
  { ['a{e{b,c},d}j'] = 'aebj aecj adj' },
  { ['a{e{b,c}f,d}j'] = 'aebfj aecfj adj' },
  { ['a{b,c{d,e}f,g}h'] = 'abh acdfh acefh agh' },
  { ['{a{b{c,d},},}e'] = 'abce abde ae e' },
  { ['a{b{c,d,e}f,g,h}i'] = 'abcfi abdfi abefi agi ahi' },
  { ['a{b{c{d,e},},}'] = 'abcd abce ab a' },
  { ['a{b,c{d,{e,f}g},h}i'] = 'abi acdi acegi acfgi ahi' },
  { ['a{b,c{d,{e,f{g,h},i}j,k},l,m}'] = 'ab acd acej acfgj acfhj acij ack al am' },
  { ['a{b,c{d,{e,f{g,{a,b},h},i}j,k},l,m}'] = 'ab acd acej acfgj acfaj acfbj acfhj acij ack al am'},
  { ['a{b,{d,{e,f{g,{a,b},h},i},k},m}'] = 'ab ad ae afg afa afb afh ai ak am'},
  -- complex mixture of recursive and adjacent expansions
  { ['a{b,c{d,{e,f}{g,h},i}j}k'] = 'abk acdjk acegjk acehjk acfgjk acfhjk acijk' },
  { ['a{b{c,d},e{f,g}h}i'] = 'abci abdi aefhi aeghi' },
  { ['{a{b{c,d},},}e{f,{g,h},i}j'] = 'abcefj abcegj abcehj abceij abdefj abdegj abdehj abdeij aefj aegj aehj aeij efj egj ehj eij' },
  -- expand range tests
  { ['{a{g..m},}b'] = 'agb ahb aib ajb akb alb amb b' },
  { ['{a{g,h,i,j,k,l,m},}b'] = 'agb ahb aib ajb akb alb amb b' },
  { ['{a..c}'] = 'a b c' },
  { ['{a..c}{d..f}'] = 'ad ae af bd be bf cd ce cf' },
  { ['{a..f..2}'] = 'a c e' },
  { ['a{b,{c..e}f,g}r'] = 'abr acfr adfr aefr agr' },
  { ['{..,c,a}b'] = '..b cb ab' },
  { ['{a,..,a}b'] = 'ab ..b ab' },
  { ['{.,{a,..}}'] = '. a ..' },
  { ['{..,{a,..}}'] = '.. a ..' },
  { ['{.,{a,.}}'] = '. a .' },
  { ['{.,{a,.},\\\\}'] = '. a . \\\\' }, -- TODO: known issue can't pass through a single \
  { ['{.,{a,.},'] = '{.,a, {.,.,' },
  { ['{\\\\..a}'] = '\\ ] ^ _ ` a' },
  { ['{a..\\\\}'] = 'a ` _ ^ ] \\' },
  { ['{.,a}'] = '. a' },
  { ['{1..3}'] = '1 2 3' },
  { ['{3..1}'] = '3 2 1' },
  { ['{1..3..2}'] = '1 3' },
  { ['{3..1..2}'] = '3 1' },
  { ['{9..:}' ] = '9 :' },
  { ['{9..12}' ] = '9 10 11 12' },
  { ['{19..12}' ] = '19 18 17 16 15 14 13 12' },
};

--#region Testing
---comment
---@param isDebug boolean should debugging be printed to screen.
---@param filter function
---@param failed_only boolean
---@param func function
local function Tests(isDebug, filter, failed_only, func)
  util.DEBUG = isDebug or false
  local count, indent = 1, 5;
  for _, inner in pairs(patterns) do
    if not filter(count) then goto continue end
    PrintTestcase(inner, count, indent, failed_only, func)
    ::continue::
    count = count + 1
  end
end
--#endregion
--#region busted
local _, a = pcall(function() return type(describe) == "function" end)
--print(util.dump(x), util.dump(a))
if a then
  describe('brace should', function()
    for _, testcase in pairs(patterns) do
      for case, expected in pairs(testcase) do
        it('expand: "' .. case .. '" to "' .. expected .. '"', function()
          local result_table = brace.expand(case)
          local result = util.join(result_table, ' ')
          print("'" .. util.dump(result) .. "'", type(result), "'" .. util.dump(expected) .. "'", type(expected))
          assert.are.equal(expected, result)
        end)
      end
    end
  end);
end
--#endregion busted

--#region Debugging
local function rprint(...)
  print(...)
  io.write(colors.ColorOff)
end

--- Print stats case
---@param data string[]
---@param expected string
---@param first_line string
---@param second_line string
---@param count integer
---@param pattern string
---@param failed_only boolean
local function print_testcase_result(data, expected, first_line, second_line, count, pattern, failed_only)
  local str = expected
  local ds, ss = util.dumpv(data), util.join(util.split(str, ' '), ', ')
  local success = ds == ss
  if success and failed_only then return end
  local c = success and FG.LimeGreen or FG.FireBrick
  local d = success and FG.SeaGreen or FG.FireBrick
  local third_line = util.padright(c .. count .. d, 5) .. pattern
  local size = math.max(#ds, #ss)
  ds, ss = util.padright(ds, size), util.padright(ss, size)
  rprint('------------------------------------------' .. ColorOff)
  rprint(third_line)
  --local q = util.split(str, ' '); table.sort(q);
  --local s = clone_table(data); table.sort(s)
  rprint(second_line .. '|actual:   ' .. ds) -- .. '   |  actual:   ' .. util.join(s, ', '))
  rprint(first_line  .. '|expected: ' .. ss) -- .. '   |  expected: ' .. util.join(q, ', '))
end

---comment
--- @param block { [string]: string } table with one entry, the argument to give to expand and the expected list of strings.
--- @param count number
--- @param indent number
--- @param failed_only boolean
--- @param func function
function PrintTestcase(block, count, indent, failed_only, func)
  func = func or brace.expand
  for pattern, expected in pairs(block) do
    local first_line = util.padright('', indent)
    local second_line = util.padright('', indent)
    for i = 1, #pattern, 1 do
      first_line = first_line .. tostring(math.floor(i/10))
      second_line = second_line .. tostring(i%10)
    end;
    ---@type boolean, string[]
    local ok, data = xpcall(func, debug.traceback, pattern)
    if ok then
      local ok2, data2 = xpcall(print_testcase_result, debug.traceback, data, expected, first_line, second_line, count, pattern, failed_only)
      if not ok2 then
        rprint('Result:', util.dump(data))
        rprint(data2)
      end
    else
      local third_line =  FG.DarkRed .. util.padright(count, 5) .. pattern .. '\t' .. expected .. ColorOff
      rprint(third_line)
      rprint('error:', data)
    end
  end
end
--#endregion Debugging

--#region as command
---@class BraceTest.TestCaseState
---@field broken table<number,boolean>
---@field print_debug boolean
---@field runalloverride boolean
---@field failed_only boolean
---@field runall boolean
---@field func function
---@field exit boolean

if debug and not pcall(debug.getlocal, 4, 1) then
  --print("args:")
  local function parse_args(arg) -- ##usage
    -- #_# allows choice of which tests to run
    ---@type BraceTest.TestCaseState
    local out = {
      broken = {},
      exit = false,
      print_debug = false,
      failed_only = false,
      runalloverride = false,
      func = brace.expand,
      runall = true
    }
    for i = 1, #arg, 1 do
      ---@type string
      local v = arg[i]
      if v == '-tc' then -- #_# <# # ...> ## list of test cases
        out.runall = false
        while true do
          i = i + 1
          if i > #arg then goto continue end
          ---@type string
          v = arg[i]
          if v:find('[^0-9]') ~= nil then goto next end
          ---@diagnostic disable-next-line
          out.broken[tonumber(v)] = true
        end
      elseif v == '--debug' then -- #_## print debug information
        out.print_debug = true
      elseif v == '--quiet' then -- #_## don't print debug information
        out.print_debug = false
      elseif v == '--runall' then -- #_## run all test cases
        out.runall = true
        out.runalloverride = true
      elseif v == '-b' then -- #_## don't run all test cases
        out.runall = false
--      elseif v == '--swap' then
--        out.func = expand.expand
      elseif v == '--failed-only' or v == '-f' then -- #_## only show results for failed tests
        out.failed_only = true
      elseif v == '--help' or v == '-h' then -- #_## print this message
        util.usage(arg[0], 'parse_args', arg[0]);
        out.exit = true
        return out;
      end
      ::next::
      --print(v)
      -- #_# This file can also be run as a busted test suite.
    end -- ## end usage
    ::continue::
    if out.runalloverride then out.runall = true end
    return out
  end
  local state = parse_args(arg)
  if state.exit then goto exit end

  local function runBroken(broken, print_debug, failed_only, func)
    --Tests(true, function(count) return count > 14 end)
    Tests(print_debug, function(count) return broken[count] or false end, failed_only, func)
  end
  if state.broken ~= {} then
    runBroken(state.broken, state.print_debug, state.failed_only, state.func)
  end
  if state.runall then
    Tests(false, function() return true end, state.failed_only, state.func)
  end
  --print('state: ', util.dump(state), #state.broken)
  ::exit::
end

-- vim: set fdm=marker fmr=--#region,--#endregion sts=2 sw=2:
