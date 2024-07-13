local M = { _TYPE = 'module', _NAME = 'replace', _VERSION = '0.0.1.0' }
local brace = require('replace.brace')
local util = require('replace.util')
local rex = require('rex_posix')

--- @class PatternTuple
--- @field pattern string
--- @field repl string

--- @alias PatternTuples PatternTuple[]

--- Sort function
--- @param a PatternTuple
--- @param b PatternTuple
--- @return boolean
local function sort_by_length_comp(a, b)
  return #a.pattern > #b.pattern
end

--- Sort patterns by length so that we don't have premature matches
--- @param patterns string[]
--- @param repls string[]
--- @return PatternTuples
local function sort_by_length(patterns, repls)
  if #patterns ~= #repls then error('Non matching patterns replacements:' .. util.dump(patterns) .. ';r:' .. util.dump(repls)) end
  --- @type PatternTuples
  local data = {}
  for i = 1, #patterns, 1 do
    local pattern = patterns[i]
    local repl = repls[i]
    table.insert(data, { pattern = pattern, repl = repl })
  end
  table.sort(data, sort_by_length_comp)
  return data
end

--- Take a string and a pattern and replace all patterns...
--- @param orig string
--- @param item string
--- @param repl string
--- @param options string
--- @param debug boolean?
--- @return string
local function swap_words(orig, item, repl, options, debug)
  item = string.gsub(string.gsub(item, '\\>', '\\b'), '\\<', '\\b')
  local patterns = brace.expand(item)
  local repls = brace.expand(repl)
  local tuples = sort_by_length(patterns, repls)
  util.dprint('======== ' .. orig .. ', pattern: ' .. item, util.dump(patterns), ';:', repl, util.dump(repls))
  local str = orig
  for _, tuple in pairs(tuples) do
    util.dprint('calling swkc:', util.dump(tuple.pattern), util.dump(tuple.repl))
    --- @type boolean
    local local_debug = util.DEBUG; util.DEBUG = options:find('E') ~= nil
    str = M.swap_word_keep_case(str, tuple.pattern, tuple.repl, options, debug)
    util.DEBUG = local_debug
  end
  return str
end
M.swap_words = swap_words

--- @return table<'i'|'m'|'x'|'s', number>, table<string, number>
local function determine_flags()
  --- @type table<string, string>
  local posix_flags = { i = 'ICASE', m = 'NEWLINE', s = 'NOSUB', x = 'EXTENDED' }
  --- @type table<'ICASE'|'NEWLINE'|'NOSUB'|'EXTENDED', integer>
  local posix_enum = rex.flags()
  --- @type table<'i'|'m'|'s'|'x', number>
  local out = {}
  for k, v in pairs(posix_flags) do
    out[k] = posix_enum[v]
  end
  return out, posix_enum
end
local posix_flags, posix_enum = determine_flags()

--- Find the options that are part of gsub.
--- @param options string
--- @return integer, string
local function generate_search_options(options)
  local opts = util.split(options or '', '')
  -- uppercase removes flag.
  local flags = { i = true, x = true, s = false, m = false }
  local out = 0
  local keys = ''
  for _, opt in pairs(opts) do
    local t = string.lower(opt)
    if flags[t] ~= nil then flags[t] = opt == t end
  end
  for opt, value in pairs(flags) do
    if value then
      --- @type integer
      out = out + posix_flags[opt]
      keys = keys .. opt
    end
  end
  return out, keys;
end

--- @type table<string, string>
local case_separators = { n = '_', d = '\\.', }

--- Create the separator between chunks
--- @param opts string
--- @return string, table<string, boolean>
local function generate_seperator(opts)
  opts = string.gsub(opts, 'a', 'apndckul')

  local opt_table = util.split(opts, '')
  --- @type table<string, boolean>
  local options = {}
  for _, v in pairs(opt_table) do
    if v == 'E' then
      options['E'] = true
    elseif v ~= string.lower(v) and options[v] == nil then
      options[string.lower(v)] = false
    elseif options[v] == nil then
      options[v] = true
    end
  end
  local out = ''
  for v, enabled in pairs(options) do
    local t = case_separators[v]
    if enabled and t ~= nil then out = out .. t end
  end
  if options['k'] then out = out .. '-' end
  if #out > 1 then out = '[' .. out .. ']' end

  if options['p'] or options['c'] then out = out .. '?' end
  return out, options;
end

--#region find_all_atom_starts
--- Find all k...
--- @param str string
--- @return string[]
local function find_all_atom_starts(str)
  local key = '('
  local out = {}
  --- @type integer | nil
  local idx = 1;
  while true do
    idx = string.find(str, key, idx, true)
    if idx == nil then break end
    table.insert(out, string.sub(str, idx + 1, idx + 1))
    idx = idx + 1
  end
  return out
end
--#endregion find_all_atom_starts

local function check1st_char(str, pattern)
  return string.match(string.sub(str, 1, 1), pattern)
end

--- Do a bitwise and on a and b
--- @param a integer
--- @param b integer
--- @return integer
local function bitand(a, b)
  local result, bitval = 0, 1;
  while a > 0 and b > 0 do
    if a % 2 == 1 and b % 2 == 1 then -- test rightmost bit
      result = result + bitval        -- set current bit
    end
    bitval = bitval * 2 -- shift left
    a = math.floor(a/2) -- shift right
    b = math.floor(b/2)
  end
  return result
end
M.bitand = bitand

--- Do a bitwise or on a and b
--- @param a integer
--- @param b integer
--- @return integer
local function bitor(a, b)
  local result, bitval = 0, 1;
  while a > 0 or b > 0 do
    if a <= 0 or b <= 0 then
      result = result + bitval
    elseif a % 2 == 1 or b % 2 == 1 then -- test rightmost bit
      result = result + bitval        -- set current bit
    end
    bitval = bitval * 2 -- shift left
    a = math.floor(a/2) -- shift right
    b = math.floor(b/2)
  end
  return result
end
M.bitor = bitor

--- Build a table of char,boolean
--- @param chars string[]
--- @return table<string, boolean>
local function build_char_bool_table(chars)
  --- @type table<string, boolean>
  local out = {}
  for i = 1, #chars, 1 do
    out[chars[i]] = true
  end
  return out
end
--- Check counts of certain letters
--- @param item string
--- @param chars string
--- @return integer
local function find_counts(item, chars)
  local array = util.split(item, '')
  local checks = build_char_bool_table(brace.expand(chars))
  local count = 0;
  for i = 1, #array, 1 do
    if checks[array[i]] then count = count + 1 end
  end
  return count
end

--- Find all matching positions
--- @param str string
--- @param pattern string
--- @return integer[]
local function gfind(str, pattern)
  local out = {}
  local idx = 1
  while true do
    local s = string.find(str, pattern, idx)
    if s == nil then
      return out
    end
    idx = s + 1
    table.insert(out, s)
  end
end

--- Check upper case counts match between strings
--- @param found string
--- @param orig string
--- @param options table<string, boolean>
--- @return boolean
local function check_counts(found, orig, options)
  local f_min = string.gsub(found, '[._-]', '')
  local o_min = string.gsub(orig, '[._-]', '')
  local f_idxs = gfind(f_min, '[A-Z]')
  local o_idxs = gfind(o_min, '[A-Z]')
  util.dprint(util.ldump('options:', options, 'idxs:', { f = f_idxs, o = o_idxs }))
  if (#f_idxs == 0 and (options.l or options.i)) or (#f_idxs == #f_min and (options.u or options.i)) then
    util.dprint('returning early because options.i or something')
    return true
  end
  -- Special case for first letter of the first word
  if f_idxs[1] ~= 1 and o_idxs[1] == 1 and options.c then
    table.insert(f_idxs, 1, 1)
  elseif f_idxs[1] == 1 and o_idxs[1] ~= 1 and options.p then
    table.insert(o_idxs, 1, 1)
  end
  util.dprint(util.ldump('idxs:', { f = f_idxs, o = o_idxs, fn = #f_idxs, on = #o_idxs }))
  if #f_idxs ~= #o_idxs then
    return false
  end
  for i = 1, #f_idxs, 1 do
    util.dprint('checking:', i, 'f:', f_idxs[i], 'o:', o_idxs[i])
    if f_idxs[i] ~= o_idxs[i] then return false end
  end
  util.dprint('returning true from check counts')
  return true
end

--#region swkc: Take a string and a pattern and replace all patterns...
--- @param orig string
--- @param item string
--- @param repl string
--- @param options string values: imsx | P - pascal, n - snake, D - dot, C - camel, K - kebab, E--deep debug, u -- upper case, l -- lowercase, i -- case insentive
--- @param debug boolean?
--- @return string
local function swap_word_keep_case(orig, item, repl, options, debug)
  local ssep, lopts = generate_seperator(options)
  -- Generate search options.
  local gsub_options, gsub_key = generate_search_options(opts);
  if options == 'I' then
    return rex.gsub(orig, item, repl, gsub_options)
  end

  if debug then util.DEBUG = true end
  --util.dprint('handling: ' .. orig .. ', pattern: ' .. item .. ', repls: ' .. repl .. ', options: ' .. options .. ';gsubOptions: ' .. gsub_options)
  -- gsub(item, pattern, function,
  --- @type string
  local pattern = rex.gsub(item, '(\\w)([(]?[A-Z])', function(w1, w2) return w1 .. ssep .. w2 end)
  local atom_starts = find_all_atom_starts(item)
  --if string.sub(pattern, 1, 1) == '(' and string.sub(pattern, #pattern, #pattern)
  if string.find(pattern, '(', nil, true) ~= nil then pattern = '(' .. pattern .. ')' end
  --util.dprint('xxx:', pattern, "'"..ssep.."'", util.dump(lopts))
  --print(util.xdump('opts:', gsub_options, opts, 'lopts:', lopts, 'options:', options, 'orig:', orig, 'pattern:', pattern, 'gsub_key:', gsub_key))
  local gsub_call_options = bitor(gsub_options, posix_enum['ICASE'])
  util.dprint(util.ldump('#a05', pattern, 'go:', gsub_options, posix_enum['ICASE'], gsub_call_options, bitand(gsub_call_options, posix_enum['ICASE']), 'normal gsub result:', rex.gsub(orig, pattern, repl)))
  --- @type string
  local result = rex.gsub(orig, pattern, function(found, ...)
    local tab = { ... }
    util.dprint(util.xdump('found(st):', found, 'rest:', ...)) -- TODO: remove
    local out = repl
    if #tab > 0 then
      for idx, match in pairs(tab) do
        local k = atom_starts[idx]
        if string.lower(k) ~= k then
          local m = string.sub(match, 1, 1)
          match = string.upper(m) .. string.sub(match, 2, #match)
        end
        out = string.gsub(repl, '\\'..idx, match)
      end
    elseif #tab == 0 and not check_counts(found, item, lopts) then
      util.dprint('checks failed')
      return found
    end
    --- Handle kebab-case
    if string.find(found, '-') and lopts['k'] then
      util.dprint('HANDLING kebab-case', found, repl)
      --- @type string
      out = rex.gsub(out, '(\\w)([A-Z])', function(w1, w2) return w1 .. '-' .. w2; end)
      if (not string.find(repl, '-')) and string.find(out, '-') == 1 then
        out = string.sub(out, 2)
      end
    end
    if string.find(found, '.', nil, true) and lopts['d'] then
      --print('HANDLING dot.case', found)
      --- @type string
      out = rex.gsub(out, '(\\w)([A-Z])', function(w1, w2) return w1 .. '.' .. w2; end)
      if (not string.find(repl, '.', nil, true)) and string.find(out, '.', nil, true) == 1 then
        out = string.sub(out, 2)
      end
    end
    if string.find(found, '_') and lopts['n'] then
      --- @type string
      out = rex.gsub(out, '(\\w)([A-Z])', function(w1, w2) return w1 .. '_' .. w2; end)
      if (not string.find(repl, '_')) and string.find(out, '_') == 1 then
        out = string.sub(out, 2)
      end
    end
    if lopts['i'] ~= nil and not lopts['i'] then
      if string.lower(found) ~= found and string.upper(found) ~= found then
        --print('found(ii):', found, 'out:', found, 'RETURNING')
        return found
      end
      --print('found(ii):', found, 'out:', out)
    end
    if not string.match(found, '[A-Z]') then
      local x = out
      out = string.lower(out)
      --print('found(lc):', found, 'out:', out, 'x:', x)
    end
    if not string.match(found, '[a-z]') then
      local x = out
      out = string.upper(out)
      --print('found(uc):', found, 'out:', out, 'x:', x)
    end

    if check1st_char(found, '[a-z]') and check1st_char(out, '[A-Z]') then
      local x = out
      out = string.lower(string.sub(out, 1, 1)) .. string.sub(out, 2)
      --print('found(1c):', found, 'out:', x, out)
    end

    --print(util.ldump('Blue', item, found, out, lopts))
    return out
  end, nil, gsub_call_options)
  return result
end
M.swap_word_keep_case = swap_word_keep_case;
--#endregion swkc

return M

-- vim: set fdm=marker fmr=--#region,--#endregion sts=2 sw=2:
