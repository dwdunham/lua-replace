# lua-replace
Repo to hold backend substitution code

## Provides utilities to expand braces and swap words regardless of case
* Expand range (with or without marked increments), expands lists

### Detail
* Expands ranges: {a..c} -> a b c, {4..2} -> 4 2
* Supports increments: {1..5..2} -> 1 3 5, {e..a..2} -> e c a
* Expands list: {t,m,f}oo -> too moo foo
* Supports escaping...


## Dependencies:
* `brew install pcre` or `brew install pcre2`
* `brew install lrexlib-pcre`


## Plans
* Documentation
* implement nvim package -- mostly done
* add test cases for swapword.
  * options
  * better test Suite
  * integrate for busted
* Abbreviations:
  * see tpope/abolish
* Proper README
*

### Finished
* Separate out package for swap functionality -- done
* move swap functionality to the new swap package 
* make package for nvim package
* find a way to test coverage. -- luacov: ✅
  * `luarocks install luacov`
  * https://github.com/lunarmodules/luacov
  * https://stackoverflow.com/questions/44144321/generating-luacov-report-file
  *
  * lua -lluacov test...:
    * `rm luacov.*; for i in test/*.lua; do lua -lluacov $i; done; luacov`
    * alternate: `rm -r luacov*; for i in test/*.lua; do busted -c $i; done; luacov`
* learn how to build/include via luarocks
  * ` luarocks write_rockspec --lua-versions='5.1,5.2,5.3,5.4'`

## Ideas:
* glob to regex ???
* integrate glob expansion to swap. -- have a working situation.
* create a swapword vim plugin
* Properly name the plugin...

### Tutorials
* http://lua-users.org/wiki/ModulesTutorial
* https://lmod.readthedocs.io/en/latest/index.html
* https://rosettacode.org/wiki/Brace_expansion#Lua
* https://www.linuxjournal.com/content/bash-brace-expansion


### Other interesting packages
* https://github.com/micromatch/braces -- similar to what is being done
* https://github.com/Yonaba/Moses
* https://github.com/airstruck/knife
* https://luarocks.org/
* https://github.com/davidm/lua-balanced
* https://stackoverflow.com/questions/48409979/mocking-local-imports-when-unit-testing-lua-code-with-busted
* https://github.com/lunarmodules/busted:
  * https://lunarmodules.github.io/busted
* https://github.com/LuaLS/lua-language-server/wiki/EmmyLua-Annotations/bd7c39d63156abd70cbfba54d236c861436500c5

### Resources:
* https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences
* https://htmlcolorcodes.com/tutorials/

### "case" Classes
1. SwapWordKeepCase -- Pascal case
2, swapWordKeepCase -- camel case
3. swapwordkeepcase -- lower case
4. SWAPWORDKEEPCASE -- upper case
5. swap_word_keep_case -- Snake Case
6. SWAP_WORD_KEEP_CASE -- Upper Snake Case
7. swap-word-keep-case -- Kebab Case
8. SWAP-WORD-KEEP-CASE -- Upper Kebab Case

## Examples:

Example Test:
`
lua -e "swap = require('swap');v = 'testCase TestCase Test.Case test-case TEST_CASE TESTCASE testSuite'; print('e:', v); print('s:', swap.simple_utils.dump(swap.swapword.swap_words(v, 'test{Case,Suite}', 'fun{Suite,Case}', 'i', false)))"
`


```
local swap = require('swap');
local dump = swap.simple_utils.dump
local swap_words = swap.swapword.swap_words

local v = 'testCase TestCase Test.Case test-case TEST_CASE TESTCASE testSuite'
local result = swap_words(v, 'test{Case,Suite}', 'fun{Suite,Case}', 'i', false)

print('e:', v)
print('s:', dump(result))
```
