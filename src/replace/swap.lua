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
    str = M.swap_word_keep_case(str, tuple.pattern, tuple.repl, options, debug)
  end
  return str
end
M.swap_words = swap_words

--- @return table<'i'|'m'|'x'|'s', number>
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
  return out
end
local posix_flags = determine_flags()

--- Find the options that are part of gsub.
--- @param opts string[]
--- @return integer, string
local function generate_search_options(opts)
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

--- split into a string...
--- @generic T
--- @param str string
--- @param bool T
--- @return table<string, T>
local function mmm(str, bool)
  local out = {}
  --- @diagnostic disable-next-line
  for _, i in pairs(util.split(str, '')) do out[i] = bool end
  return out
end

--- @type table<string, string>
local case_separators = { n = '_', d = '\\.', }
--- @type table<string, boolean>
local case_no_seps = { P = true, N = true, D = true, C = true, K = true }
--- @type table<string, boolean>
local gsub_seps = mmm('imsx', true)

--- Create the separator between chunks
--- @param opts string[]
--- @return string, table<string, boolean>
local function generate_seperator(opts)
  --- @type table<string, boolean>
  local options = {}
  for _, v in pairs(opts) do
    if v == 'a' then
      for _, i in pairs(util.split('pndck', '')) do
        if options[i] == nil then options[i] = true end
      end
    end
    if gsub_seps[v] ~= nil then goto continue end
    if v == 'E' then
      options['E'] = true
    elseif v ~= string.lower(v) and options[v] == nil then
      options[string.lower(v)] = false
    elseif options[v] == nil then
      options[v] = true
    end
    ::continue::
  end
  local out = ''
  for v, enabled in pairs(options) do
    local t = case_separators[v]
    if enabled and t ~= nil then out = out .. t end
  end
  if options['k'] then out = out .. '-' end
  if #out > 0 then out = '[' .. out .. ']' end

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

--#region swkc: Take a string and a pattern and replace all patterns...
--- @param orig string
--- @param item string
--- @param repl string
--- @param options string values: imsxUX | P - pascal, n - snake, D - dot, C - camel, K - kebab, E--deep debug
--- @param debug boolean?
--- @return string
local function swap_word_keep_case(orig, item, repl, options, debug)
  local opts = util.split(options, '')
  local ssep, lopts = generate_seperator(opts)
  -- Generate search options.
  local x = util.DEBUG; util.DEBUG = lopts['E'] or false
  local gsub_options = generate_search_options(opts);
  util.DEBUG = x


  util.DEBUG = debug or false
  -- TODO: add controls for which alterations to do... k,p,_,.,...
  util.dprint('handling: ' .. orig .. ', pattern: ' .. item .. ', repls: ' .. repl .. ', options: ' .. options .. ';gsubOptions: ' .. gsub_options)
  -- gsub(item, pattern, function,
  --- @type string
  local pattern = rex.gsub(item, '(\\w)([(]?[A-Z])', function(w1, w2) return w1 .. ssep .. w2 end)
  local atom_starts = find_all_atom_starts(item)
  --if string.sub(pattern, 1, 1) == '(' and string.sub(pattern, #pattern, #pattern)
  if string.find(pattern, '(', nil, true) ~= nil then pattern = '(' .. pattern .. ')' end
  util.dprint('xxx:', pattern, "'"..ssep.."'", util.dump(lopts))
  return rex.gsub(orig, pattern, function(found, ...)
    local tab = { ... }
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
    end
    if string.find(found, '-') and lopts['k'] then
      --- @type string
      out = rex.gsub(out, '(\\w)([A-Z])', function(w1, w2) return w1 .. '-' .. w2; end)
      if (not string.find(repl, '-')) and string.find(out, '-') == 1 then
        out = string.sub(out, 2)
      end
    end
    if string.find(found, '.', nil, true) and lopts['d'] then
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
    if not string.match(found, '[A-Z]') then
      out = string.lower(out)
    end
    if not string.match(found, '[a-z]') then
      out = string.upper(out)
    end

    if string.match(string.sub(found, 1, 1), '[a-z]') then
      out = string.lower(string.sub(out, 1, 1)) .. string.sub(out, 2)
    end

    util.dprint('\x1b[38;2;170;170;0m(' .. item .. '){' .. found .. '}[' .. out .. ']\x1b[0m')
    return out
  end, nil, gsub_options)
end
M.swap_word_keep_case = swap_word_keep_case;
--#endregion swkc

return M

-- vim: set fdm=marker fmr=--#region,--#endregion sts=2 sw=2:
