package.path = package.path .. ';./src/?.lua;./src/?/init.lua'
local swap = require('replace.swap')
local M = {}
-- TODO: add unit tests for the various options.
-- TODO: fix for busted

--#region Test Cases
local function test_swapword()
  local cases = {
    { ['testsuite'] = 'usecase' },
    { ['TestSuite'] = 'UseCase' },
    { ['TESTSUITE'] = 'USECASE' },
    { ['TEST_SUITE'] = 'USE_CASE' },
    { ['test_suite'] = 'use_case' },
    { ['testSuite'] = 'useCase' },
    { ['test-suite'] = 'use-case' },
    { ['test.suite'] = 'use.case' },
  }
  for _, case in pairs(cases) do
    for pre, expected in pairs(case) do
      local result = swap.swap_words(pre, 'TestSuite', 'UseCase', 'ai')
      local color = result == expected and '' or '\x1b[38;2;255;150;150m'
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

if not pcall(debug.getlocal, 4, 1) then
  test_swapword()
end
--#endregion Test Cases

return M

-- vim: set fdm=marker fmr=--#region,--#endregion sts=2 sw=2:
