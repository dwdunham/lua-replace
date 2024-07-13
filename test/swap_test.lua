local __t = false;
package.path = './src/?.lua;./src/?/init.lua;' .. package.path;
local math = require('math')
local swap = require('replace.swap')
local util = require('replace.util')
local colors = require('replace.colors')
local M = {}
-- TODO: add unit tests for the various options.
-- TODO: fix for busted

--- @class Swap.TestCase
--- @field name string
--- @field busted_name string
--- @field text string
--- @field pattern string
--- @field replacement string
--- @field options string
--- @field expected string

-- --- Change a list of strings to a test case
-- --- @param name string
-- --- @param text string
-- --- @param pattern string
-- --- @param replacement string
-- --- @param options string
-- --- @param expected string
-- --- @return Swap.TestCase
-- local function to_testcase(name, text, pattern, replacement, options, expected)
--   return {
--     name = name,
--     text = text,
--     pattern = pattern,
--     replacement = replacement,
--     options = options,
--     expected = expected
--   }
-- end

--- @class Swap.AlmostTestCase
--- @field text string -- original text
--- @field pattern string? -- if not set use test suite pattern
--- @field replacement string? -- if not set use test suite replacement
--- @field expected string? -- if not set use original text
--- @field options string? -- if not set use test suite options
--- @field name string?

--- @class Swap.TestSuite
--- @field name string
--- @field name_prefix string
--- @field pattern string
--- @field replacement string
--- @field options string
--- @field tests Swap.AlmostTestCase[]

--- Use the suite to build the set of test cases
--- @param suite Swap.TestSuite
--- @return Swap.TestCase[]
local function build_testcases(suite)
  local out = {}
  for i = 1, #suite.tests, 1 do
    local case = suite.tests[i]
    local opts = case.options or suite.options
    --- @type Swap.TestCase
    local test = {
      text = case.text,
      pattern = case.pattern or suite.pattern,
      options = opts,
      expected = case.expected or case.text,
      replacement = case.replacement or suite.replacement,
      name = case.name or suite.name_prefix .. ' case: ' .. opts,
      busted_name = ''
    }
    test.busted_name = 'text:' .. test.text
      .. ', pattern:' .. test.pattern
      .. ', replacement:' .. test.replacement
      .. ', options:' .. test.options
    table.insert(out, test)
  end
  return out
end

--- @type Swap.TestSuite[]
local test_suites = {
  {
    name = 'kebab-suite',
    name_prefix = 'kebab',
    pattern = 'TestSuite',
    replacement = 'UseCase',
    options = 'k',
    tests = {
      { text = 'TEST-SUITE' },
      { text = 'TEST-SUITE', expected = 'USE-CASE', options = 'kIu' },
      { text = 'TEST-SUITE', expected = 'USE-CASE', options = 'ki' },
      { text = 'TEST-SUITE', expected = 'USE-CASE', options = 'ku' },
      { text = 'TEST-SUITE', pattern = 'test-suite', replacement = 'use-case' },
      { text = 'TEST-SUITE', options = 'kI' },
      { text = 'Test-Suite', expected = 'Use-Case' },
      { text = 'Test-Suite', options = 'kI' },
      { text = 'Test-Suite', pattern = 'test-suite', replacement = 'use-case' },
      { text = 'test-suite' },
      { text = 'test-suite', expected = 'use-case', options = 'kIl' },
      { text = 'test-suite', expected = 'use-case', options = 'ki' },
      { text = 'test-suite', expected = 'use-case', options = 'kl' },
      { text = 'test-suite', expected = 'use-case', pattern = 'test-suite', replacement = 'use-case' },
      { text = 'test-suite', options = 'kI' },
      { text = 'TestSuite' },
      { text = 'TESTSUITE' },
      { text = 'testSuite' },
      { text = 'testsuite' },
      { text = 'TESTSUITE' },
      { text = 'TestSuite' },
      { text = 'testSUite' },
      { text = 'test_suite' },
      { text = 'TEST_SUITE' },
      { text = 'Test_Suite' },
      { text = 'test.suite' },
      { text = 'TEST.SUITE' },
      { text = 'Test.Suite' },
    }
  },
  {
    name = 'snake_suite',
    name_prefix = 'all',
    pattern = 'TestSuite',
    replacement = 'UseCase',
    options = 'n',
    tests = {
      { text = 'test-suite' }, -- kebab
      { text = 'Test-Suite' },
      { text = 'TEST-SUITE' },
      { text = 'TestSuite' }, -- cp
      { text = 'TESTSUITE' },
      { text = 'testSuite' },
      { text = 'testsuite' },
      { text = 'testSUite' },
      { text = 'test_suite', expected = 'use_case', options = 'ni' }, -- snake
      { text = 'test_suite', expected = 'use_case', options = 'nl' },
      { text = 'test_suite' },
      { text = 'TEST_SUITE', expected = 'USE_CASE', options = 'ni' },
      { text = 'TEST_SUITE', expected = 'USE_CASE', options = 'nu' },
      { text = 'TEST_SUITE' },
      { text = 'Test_Suite', expected = 'Use_Case' },
      { text = 'test.suite' }, -- dotcase
      { text = 'TEST.SUITE' },
      { text = 'Test.Suite' },
    }
  },
  {
    name = 'PascalSuite',
    name_prefix = 'all',
    pattern = 'TestSuite',
    replacement = 'UseCase',
    options = 'p',
    tests = {
      { text = 'test-suite' }, -- kebab
      { text = 'Test-Suite' },
      { text = 'TEST-SUITE' },
      { text = 'TestSuite', expected = 'UseCase' }, -- cp
      { text = 'TESTSUITE' },
      { text = 'TESTSUITE', expected = 'USECASE', options = 'pi' },
      { text = 'TESTSUITE', expected = 'USECASE', options = 'pu' },
      { text = 'testSuite' },
      { text = 'testsuite' },
      { text = 'testsuite', expected = 'usecase', options = 'pi' },
      { text = 'testsuite', expected = 'usecase', options = 'pl' },
      { text = 'testSUite' },
      { text = 'test_suite' }, -- snake
      { text = 'TEST_SUITE' },
      { text = 'Test_Suite' },
      { text = 'test.suite' }, -- dotcase
      { text = 'TEST.SUITE' },
      { text = 'Test.Suite' },
    }
  },
  {
    name = 'dot.suite',
    name_prefix = 'all',
    pattern = 'TestSuite',
    replacement = 'UseCase',
    options = 'd',
    tests = {
      { text = 'test-suite' }, -- kebab
      { text = 'Test-Suite' },
      { text = 'TEST-SUITE' },
      { text = 'TestSuite' }, -- cp
      { text = 'TESTSUITE' },
      { text = 'testSuite' },
      { text = 'testsuite' },
      { text = 'testSUite' },
      { text = 'test_suite' }, -- snake
      { text = 'TEST_SUITE' },
      { text = 'Test_Suite' },
      { text = 'test.suite' }, -- dotcase
      { text = 'test.suite', expected = 'use.case', options = 'di' },
      { text = 'test.suite', expected = 'use.case', options = 'dl' },
      { text = 'TEST.SUITE' },
      { text = 'TEST.SUITE', expected = 'USE.CASE', options = 'di' },
      { text = 'TEST.SUITE', expected = 'USE.CASE', options = 'du' },
      { text = 'Test.Suite', expected = 'Use.Case' },
    }
  },
  {
    name = 'all-suite',
    name_prefix = 'all',
    pattern = 'TestSuite',
    replacement = 'UseCase',
    options = 'a',
    tests = {
      { text = 'test-suite', expected = 'use-case' }, -- kebab
      { text = 'Test-Suite', expected = 'Use-Case' },
      { text = 'TEST-SUITE', expected = 'USE-CASE' },
      { text = 'TestSuite', expected = 'UseCase' }, -- cp
      { text = 'TESTSUITE', expected = 'USECASE' },
      { text = 'testSuite', expected = 'useCase' },
      { text = 'TestSuite', expected = 'useCase', pattern = 'testSuite', replacement = 'useCase' },
      { text = 'testsuite', expected = 'usecase' },
      { text = 'testSUite' },
      { text = 'test_suite', expected = 'use_case' }, -- snake
      { text = 'TEST_SUITE', expected = 'USE_CASE' },
      { text = 'Test_Suite', expected = 'Use_Case' },
      { text = 'test.suite', expected = 'use.case' }, -- dotcase
      { text = 'TEST.SUITE', expected = 'USE.CASE' },
      { text = 'Test.Suite', expected = 'Use.Case' },
    }
  },
  {
    name = 'upper',
    name_prefix = 'caseless',
    pattern = 'TestSuite',
    replacement = 'UseCase',
    options = 'u',
    tests = {
      { text = 'test-suite' },
      { text = 'Test-Suite' },
      { text = 'TEST-SUITE' },
      { text = 'testsuite' },
      { text = 'TESTSUITE', expected = 'USECASE' },
      { text = 'TestSuite', expected = 'UseCase' },
      { text = 'testSUite' },
      { text = 'test_suite' },
      { text = 'TEST_SUITE' },
      { text = 'Test_Suite' },
      { text = 'test.suite' },
      { text = 'TEST.SUITE' },
      { text = 'Test.Suite' },
    }
  },
  {
    name = 'lower',
    name_prefix = 'caseless',
    pattern = 'TestSuite',
    replacement = 'UseCase',
    options = 'l',
    tests = {
      { text = 'test-suite' },
      { text = 'Test-Suite' },
      { text = 'TEST-SUITE' },
      { text = 'testsuite', expected = 'usecase' },
      { text = 'TESTSUITE' },
      { text = 'TestSuite', expected = 'UseCase' },
      { text = 'testSUite' },
      { text = 'test_suite' },
      { text = 'TEST_SUITE' },
      { text = 'Test_Suite' },
      { text = 'test.suite' },
      { text = 'TEST.SUITE' },
      { text = 'Test.Suite' },
    }
  },
  {
    name = 'caseless',
    name_prefix = 'caseless',
    pattern = 'TestSuite',
    replacement = 'UseCase',
    options = 'i',
    tests = {
      { text = 'test-suite' },
      { text = 'Test-Suite' },
      { text = 'TEST-SUITE' },
      { text = 'testsuite', expected = 'usecase' },
      { text = 'TESTSUITE', expected = 'USECASE' },
      { text = 'TestSuite', expected = 'UseCase' },
      { text = 'testSUite' },
      { text = 'test_suite' },
      { text = 'TEST_SUITE' },
      { text = 'Test_Suite' },
      { text = 'test.suite' },
      { text = 'TEST.SUITE' },
      { text = 'Test.Suite' },
    }
  },
  {
    name = 'none-suite',
    name_prefix = 'none',
    pattern = 'TestSuite',
    replacement = 'UseCase',
    options = '',
    tests = {
      { text = 'test-suite' },
      { text = 'Test-Suite' },
      { text = 'TEST-SUITE' },
      { text = 'testsuite' },
      { text = 'TESTSUITE' },
      { text = 'TestSuite', expected = 'UseCase' },
      { text = 'testSUite' },
      { text = 'test_suite' },
      { text = 'TEST_SUITE' },
      { text = 'Test_Suite' },
      { text = 'test.suite' },
      { text = 'TEST.SUITE' },
      { text = 'Test.Suite' },
    }
  },
  {
    name = 'case sensitive',
    name_prefix = 'case',
    pattern = 'TestSuite',
    replacement = 'UseCase',
    options = 'I',
    tests = {
      { text = 'test-suite' },
      { text = 'Test-Suite' },
      { text = 'TEST-SUITE' },
      { text = 'testsuite' },
      { text = 'TESTSUITE' },
      { text = 'TestSuite', expected = 'UseCase' },
      { text = 'testSUite' },
      { text = 'test_suite' },
      { text = 'TEST_SUITE' },
      { text = 'Test_Suite' },
      { text = 'test.suite' },
      { text = 'TEST.SUITE' },
      { text = 'Test.Suite' },
    }
  },
}

--- run a test case
--- @param case Swap.TestCase
--- @return string
local function call_swap(case)
  return swap.swap_words(case.text, case.pattern, case.replacement, case.options)
end

--#region busted
local _, a = pcall(function() return type(describe) == "function" end)
if a then
  describe('swap should', function()
    for _, test_suite in pairs(test_suites) do
      local test_cases = build_testcases(test_suite)
      describe(test_suite.name .. ' suite', function()
        for _, case in pairs(test_cases) do
          it('when ' .. case.busted_name, function()
            local result = call_swap(case)
            assert.are.equal(case.expected, result)
          end)
        end
      end)
    end
  end)
end
--#endregion busted

--- Run a single test case
--- @param idx number
--- @param case Swap.TestCase
--- @param options SwapTest.State?
--- @return boolean, string, string
local function run_test_case(idx, case, options)
  options = options or {}
  local result = swap.swap_words(case.text, case.pattern, case.replacement, case.options, options.debug)
  local success = result == case.expected
  local color = success and '' or 'Red'
  local str = util.ldump(color, util.padright(idx, 4) .. '   name:' .. case.name .. '; original:' .. case.text
      .. '; pattern:"'..case.pattern..'"; repl:"' .. case.replacement .. '"'
      .. '; result:"'..result..'"; expected:"'..case.expected..'"')
  return success, str, result
end
M.run_test_case = run_test_case

--- Run list of test suites
--- @param suites Swap.TestSuite[]
--- @param options SwapTest.State
local function run_test_suites(suites, options)
  local sc, cc = 0, 0
  for _, _ in pairs(options.suites) do sc = sc + 1 end
  for _, _ in pairs(options.cases) do cc = cc + 1 end
  local total = { ran = 0, ok = 0, fail = 0, suites = 0 }
  local max_name_length = 0
  for i = 1, #suites, 1 do
    max_name_length = math.max(max_name_length, #suites[i].name)
    if sc > 0 and not options.suites[i] then goto next end
    total.suites = total.suites + 1
    local test_suite = suites[i]
    local test_cases = build_testcases(test_suite)
    local successes = 0
    local ran = 0
    local results = {}
    for idx = 1, #test_cases, 1 do
      if cc == 0 or options.cases[idx] then
        ran = ran + 1; total.ran = total.ran + 1
        -- if options.debug then
        --   local opts = test_cases[idx].options
        --   test_cases[idx].options = opts .. 'E'
        -- end
        local ok, str = run_test_case(idx, test_cases[idx], options)
        if ok then total.ok = total.ok + 1 else total.fail = total.fail + 1 end
        if not options.only_failed or not ok then
          table.insert(results, str)
        end
        successes = successes + (ok and 1 or 0)
      end
    end
    if not options.quiet or successes ~= ran then
      local c = (successes == ran and '' or 'Red')
      local fraction = util.ldump(c, successes) .. '/' .. ran
      local idx = util.padleft(i, math.floor(#suites/10) + 1)
      local name = util.padright(test_suite.name, max_name_length)
      print('Suite ' .. idx .. ' ' .. name, fraction .. ' of ' .. #test_cases)
      --- @diagnostic disable-next-line
      for _, v in pairs(results) do print(v) end
    end
    ::next::
  end
  print('Totals:', util.ldump('', total))
end

--#region Test Cases
local function test_swapword()
  -- local expanded_cases = {
  --   -- name, text, pattern, replacement, options, expected
  --   to_testcase('kebab lc', 'test-suite', 'TestSuite', 'UseCase', 'k', 'use-case'),
  --   to_testcase{'TEST-SUITE'},
  --   {'Test-Suite'},
  --   {'testSuite'},
  --   {'testsuite'},
  --   {'TESTSUITE'},
  --   {'TestSuite'},
  --   {'testSUite'},
  --   {'test_suite'},
  --   {'TEST_SUITE'},
  --   {'Test_Suite'},
  --   {'test.suite'},
  --   {'TEST.SUITE'},
  --   {'Test.Suite'},
  -- }
  -- local cases2 = {
  --   -- original, pattern, replacement, options, expected
  --   { 'testsuite' }
  -- }
  local cases = {
    { ['testsuite'] = 'usecase' },
    { ['TestSuite'] = 'UseCase' },
    { ['TESTSUITE'] = 'USECASE' },
    { ['TEST_SUITE'] = 'USE_CASE' },
    { ['test_suite'] = 'use_case' },
    { ['testSuite'] = 'useCase' },
    { ['test-suite'] = 'use-case' },
    { ['test.suite'] = 'use.case' },
    { ['Test-Suite'] = 'Use-Case' },
    { ['Test.Suite'] = 'Use.Case' },
  }
  for _, case in pairs(cases) do
    for pre, expected in pairs(case) do
      local result = swap.swap_words(pre, 'TestSuite', 'UseCase', 'ai')
      local color = result == expected and '' or colors.FG.Red
      print(color .. 'pre:' .. pre .. '; result:"'..result..'"; expected:"'..expected..'"\x1b[0m')
      --print("debug:  " .. swap_word_keep_case(pre, 'TestSuite', 'UseCase  ', 'i', true))
    end
  end

  --local data = 'XXX:1: testsuite :2: TestSuite :3: TESTSUITE :4: TEST_SUITE :5: test_suite :6: testSuite :7: test.suite :8: test-suite';
  --local xpct = 'XXX:1: usecase   :2: UseCase   :3: USECASE   :4: USE_CASE   :5: use_case   :6: useCase   :7: use.case   :8: use-case'
  --print("pre:    " .. data)
  --print('expect: ' .. xpct)
  --print("post:   " .. swap_word_keep_case(data, 'TestSuite', 'UseCase  ', 'i'))
  --print("debug:  " .. swap_word_keep_case(data, 'TestSuite', 'UseCase  ', 'i', true))
end
M.test_swapword = test_swapword

--- Add a num=true to a table
--- @param block table<integer, boolean>
--- @param idx integer
--- @param arg string[]
--- @return integer
local function add_num(block, idx, arg)
  while idx < #arg do
    idx = idx + 1
    local ts = tonumber(arg[idx])
    if ts == nil then return idx end
    block[ts] = true
  end
  return idx
end

--- @class SwapTest.State
--- @field only_failed boolean?
--- @field quiet boolean?
--- @field debug boolean?
--- @field suites table<integer, boolean>
--- @field cases table<integer, boolean>

if not pcall(debug.getlocal, 4, 1) then
  --- @type SwapTest.State
  local options = { cases = {} , suites = {} }
  for i = 1, #arg, 1 do
    if arg[i] == '-ts' or arg[i] == '--test-suite' then
      i = add_num(options.suites, i, arg)
    elseif arg[i] == '-tc' or arg[i] == '--test-case' then
      i = add_num(options.cases, i, arg)
    elseif arg[i] == '--only-failed' or arg[i] == '-f' then
      options.only_failed = true
    elseif arg[i] == '-q' then
      options.quiet = true
    elseif arg[i] == '--debug' then
      options.debug = true
    end
  end
  if options.quiet then options.only_failed = true end
  run_test_suites(test_suites, options)
  --test_swapword()
end
--#endregion Test Cases

return M

-- vim: set fdm=marker fmr=--#region,--#endregion sts=2 sw=2:
