local M = { _TYPE = 'module', _NAME = 'simple_utils', _VERSION = '0.0.1.0' }
local colors = require('replace.colors')

ColorOff = colors.ColorOff

--#region Utils
--#region Debug Utils
M.DEBUG = false
--- Print a series of strings to the console
--- @param ... string[]|string
local function _dprint(...)
  if (M.DEBUG) then
    local sep = '';
    ---@diagnostic disable-next-line
    for _, k in pairs({...}) do
      io.write(sep);
      io.write(k);
      sep = '\t';
    end
  end
end

--- Print to console, with a newline clearing the colors afterwards
---@param ... string[]|string
local function dprint(...)
  ---@diagnostic disable-next-line
  if (M.DEBUG) then _dprint(...); print(ColorOff) end
end
M.dprint = dprint

-- TODO: this needs a better name...
--- Print to console, without a newline clearing the colors afterwards
--- @param ... string[] 
local function dprintf(...)
  if (M.DEBUG) then _dprint(...); io.write(ColorOff.. '\t') end
end
M.dprintf = dprintf

--- Write to console.
---@param ... string[]|string
local function dwrite(...)
  if M.DEBUG then io.write(...) end
end
M.dwrite = dwrite
--#endregion Debug Utils

--- Split a string by the separator
---@param instr string
---@param sep string?
---@param start integer?
---@param finish integer?
---@return table<integer, string>
local function split(instr, sep, start, finish)
  start = start or 1;
  finish = finish or #instr
  local out = {}
  if sep == '' then
    for i=1,#instr do
      table.insert(out, instr:sub(i,i))
    end
    return out;
  end
  if sep == nil then sep = '%s' end
  if not sep == '%s' then
    local m = string.find(instr, sep)
    if m == 1 then table.insert(out, '') end
  end
  for str in string.gmatch(instr, '([^' .. sep .. ']+)') do
    table.insert(out, str)
  end
  if not sep == '%s' and not sep == '' and string.find(instr, #instr - #sep + 1) then
    table.insert(out, '')
  end
  return out;
end
M.split = split

---Split a string on the first character
---@param str string
---@return string[]
local function split_on_first_char(str)
  local sep = string.sub(str, 1, 1)
  local cdr = str:sub(2)
  local current_segment = ''
  local out = {}
  for i = 1, #cdr do
    local char = cdr:sub(i, i)
    if char == sep then
      table.insert(out, current_segment)
      current_segment = ''
    else
      current_segment = current_segment .. char
    end
  end
  table.insert(out, current_segment)
  return out
end
M.split_on_first_char = split_on_first_char

--- Join a list of objects (does not dump them just join)
---@param list string[]
---@param separator string?
---@return string
local function join(list, separator)
  if type(list) ~= 'table' then
    return ''
  end
  separator = separator or ','
  local sep, out = '', ''
  for _, str in pairs(list) do
    out = out .. sep .. tostring(str)
    sep = separator
  end
  return out
end
M.join = join

---Check to see if a table is a list
---@param candidate any[]
---@return boolean
local function check_for_list(candidate)
  ---@type any
  local cursor
  for key, _ in pairs(candidate) do
    if type(key) ~= 'number' then return false end
    if cursor ~= nil then
      if cursor + 1 ~= key then return false end
    end
    cursor = key
  end
  return true
end

---Dump in a lua or json format
---@param tbl any
---@param indent number?
---@param pretty boolean?
---@param json boolean?
---@param upper_pretty boolean?
---@param indent_incr number?
---@return string
local function lua_dump(tbl, indent, pretty, json, upper_pretty, indent_incr)
  if type(tbl) ~= 'table' then return tostring(tbl) end
  indent = type(indent_incr) == 'nil' and indent or 0
  indent_incr = indent_incr or indent
  json = json or false
  upper_pretty = type(upper_pretty) == nil and pretty or upper_pretty
  ---@type string
  local suffix = pretty and '\n' or ''
  ---@type string
  local sep = ''
  local prefix = string.rep(' ', indent)
  local npre, npost = json and '' or '[', json and '' or ']'
  local jvsep = json and ': ' or ' = '
  indent = indent + indent_incr
  local is_list = check_for_list(tbl)
  ---@type string
  local out = json and is_list and '[' or '{'
  local sortable = {}
  for key, _ in pairs(tbl) do table.insert(sortable, key) end
  table.sort(sortable)
  ---@type number, string|number
  for _, key in pairs(sortable) do
    ---@type any
    local value = tbl[key]
    out = out .. sep .. suffix .. prefix
    sep = ','
    if not is_list then
      if type(key) == 'number' then
        out = out .. npre .. tostring(key) .. npost
      elseif type(key) == 'string' then
        out = out .. '"' .. key .. '"'
      else
        out = out .. '"' .. tostring(key) .. '"'
      end
      out = out .. jvsep
    end
    if type(value) == 'number' then
      out = out .. value
    elseif type(value) == 'string' then
      out = out .. '"' .. value .. '"'
    elseif type(value) == 'table' then
      local incr = indent + indent_incr
      local iincr = upper_pretty and indent_incr or 0
      out = out .. lua_dump(value, incr, upper_pretty, json, nil, iincr)
    else
      out = out .. '"' .. tostring(value) .. '"'
    end
  end
  ---@type string
  out = out .. suffix .. prefix .. (json and is_list and ']' or '}')
  return out
end
M.lua_dump = lua_dump

--- do a lua dump with a color
--- @param color string
--- @param ... any
--- @return string
local function ldump(color, ...)
  return colors.fg(color) .. M.xdump(...) .. ColorOff
end
M.ldump = ldump

--- do a lua dump to json
--- @param ... any
--- @return string
local function xdump(...)
  local out, sep = '', ''
  for _, q in pairs({...}) do
    out = out .. sep .. lua_dump(q, 0, false, true)
    sep = ' '
  end
  return out
end
M.xdump = xdump

--- Dump the types of leaf objects, all tables will just be the collection of the children
---@param o any
---@param addkey boolean?
---@param s string? start string for a new table.
---@param e string? end string for a table
---@param separator string? seperator between objects
---@return string
local function dumpType(o, addkey, s, e, separator)
  addkey = addkey or false
  s = s or '( ';
  e = e or ' )';
  separator = separator or ', '
  local sep = ''
  local m = type(o)
  if m == 'table' then
    local str = s
    ---@diagnostic disable-next-line cannot-infer
    for k, v in pairs(o) do
      str = str .. sep .. (addkey and type(k) .. ':' or '') .. dumpType(v, addkey, s, e, separator)
      sep = separator
    end
    return str .. e
  else
    return m
  end
end
M.dumpType = dumpType

---@class Usage.Arg
---@field names string[]
---@field desc string[]
---@field argument string?

---@class Usage.State
---@field name string
---@field args Usage.Arg[]
---@field indent string?
-- Should have before and after info...
---@field is_after boolean?
---@field before string[]
---@field after string[]

--- Collect information for usage
---@param line string
---@param state Usage.State
local function handle_usage_line(line, state)
  local match_query = "== ['" .. '"]([a-zA-Z_-]*)["' .. "']"
  local it = string.gmatch(line, match_query)
  ---@type Usage.Arg
  local arg = { names = {}, desc = {} }
  local match = it()
  local found = false
  while match ~= nil do
    table.insert(arg.names, match)
    match = it()
    found = true
  end
  state.is_after = state.is_after or #arg.names > 0
  local out = found and arg.desc or state.is_after and state.after or state.before
  if found then table.insert(state.args, arg) end
  it = string.gmatch(line, '#_## (.*)')
  local desc = it()
  if desc then table.insert(out, desc) end
  it = string.gmatch(line, '#_# (.*) ## (.*)')
  --- @type string
  local rest
  desc, rest = it()
  if desc then
    arg.argument = desc
    table.insert(out, rest or '')
  end
end

--- Print out the usage
---@param state Usage.State
local function print_usage_state(state)
  local indent = state.indent or '    '
  print(state.name .. ':')
  for _, line in pairs(state.before) do print(indent .. line) end
  for _, arg in pairs(state.args) do
    local a = join(arg.names, '|')
    local d = join(arg.desc or {''}, ' ')
    print(indent .. a .. ' ' .. (arg.argument or '') .. (#arg.desc > 0 and ' -- ' or '') .. d)
  end
  for _, line in pairs(state.after) do print(indent .. line) end
end

--- Print help message use
---  #_## for option without argument
---  #_# ... ## desc -- for option with argument
---@param filename string
---@param function_name string
---@param name string?
local function usage(filename, function_name, name)
  name = name or function_name
  local state = { args = {}, before = {}, after = {}, name = name }
  --local file = io.open(filename, 'r')
  io.input(filename)
  local line = io.read()
  while string.find(line, function_name .. '.*-- ##usage') == nil do
    line = io.read()
  end
  while line ~= nil and string.find(line, '##\\s*end usage') == nil do
    if string.find(line, '#_#') then
      handle_usage_line(line, state)
    end
    line = io.read()
  end
  print_usage_state(state)
end
M.usage = usage

--- Clone a table recursively
--- @param tab any
--- @return any
local function clone_table(tab)
  if type(tab) ~= "table" then
    return tab
  end
  local out = {};
  ---@diagnostic disable-next-line cannot-infer
  for k, v in pairs(tab) do out[k] = clone_table(v) end
  return out
end
M.clone_table = clone_table

---Dump a table recursively into a string
---@param o any
---@param s string? start string for a table
---@param e string? end string for a table
---@param separator string? seperator between tables
---@param line_sep string?
---@param max_depth integer?
---@param depth integer?
---@param indent string?
---@param skip string[]?
---@return string
local function dump(o, s, e, separator, line_sep, max_depth, depth, indent, skip)
  s = s or '( ';
  e = e or ' )';
  skip = skip or {}
  skipKeys = {}; for _, v in pairs(skip) do skipKeys[v] = true end
  separator = separator or ', '
  line_sep = line_sep or '';
  max_depth = max_depth or 20
  depth = depth or 1
  if depth > max_depth then return '"MAXED_DEPTH"' end
  if indent ~= nil and line_sep ~= '' then
    indent = indent .. '  '
  end
  indent = indent or ''
  local kindent = line_sep == '' and indent or indent .. '  '
  local sep = ''
  local qsep = separator .. line_sep
  if type(o) == 'table' then
    local str = s .. line_sep
    ---@diagnostic disable-next-line cannot-infer
    for k,v in pairs(o) do
      if (skipKeys[k]) then goto continue end
      ---@diagnostic disable-next-line cannot-infer
      if type(k) == 'string' then 
      elseif type(k) ~= 'number' then k = tostring(k)
      end
      str = str .. sep .. kindent .. k .. ': ' .. dump(v, s, e, separator, line_sep, max_depth, depth + 1, kindent, skip)
      sep = qsep
      ::continue::
    end
    local vv = #indent > 2 and string.sub(indent, 3, #indent) or indent
    return str .. line_sep .. vv .. e
  elseif type(o) == 'string' then
    local out = '"' .. string.gsub(o, '\n', '\\n') .. '"'
    return out
  elseif type(o) == 'function' then
    return '"FUNCTION"'
  else
    local out = string.gsub(tostring(o), '\n', '')
    return out
  end
end
M.dump = dump

---Dump the values in a table recursively.
---@param tab any
---@param sep string? seperator between entries
---@param quote boolean? wrap strings in quotes?
---@param wrap boolean? wrap tables in {}
---@return string
local function dumpv(tab, sep, quote, wrap)
  sep = sep or ', '
  wrap = wrap or false
  local s = ''
  local out = ''
  if type(tab) == 'string' then
    return '"' .. tab .. '"'
  end
  if type(tab) ~= 'table' then
    return tostring(tab)
  end
  if wrap then out = out .. '{ ' end
  ---@diagnostic disable-next-line cannot-infer
  for k, v in pairs(tab) do
    if type(k) == 'number' then k = '' else k = tostring(k) .. ', ' end
    out = out .. s;
    if type(v) == 'table' then
      ---@type string
      out = out .. k .. dumpv(v, sep)
    elseif type(v) == 'string' and quote then
      ---@type string
      out = out .. k .. "'" .. v .. "'"
    else
      ---@type string
      out = out .. k .. tostring(v)
    end
    s = sep
  end
  if wrap then out = out .. ' }' end
  return out
end
M.dumpv = dumpv

--- Merge table b into a
---@param a any[]
---@param b any[]
---@return any[]
local function merge(a, b)
  ---@type any[]
  local out = {}
  for _, v in pairs(a) do table.insert(out, v) end
  for _, v in pairs(b) do table.insert(out, v) end
  return out
end
M.merge = merge

--- Pad a string to a length all on the left end of the string, does not shorten the string
---@param str string | number
---@param len integer length resulting string should be
---@param append any
---@return string
local function padleft(str, len, append)
  append = append or ' '
  if type(str) ~= 'string' then str = tostring(str) end
  -- strip out color strings out.
  local strwocolor = string.gsub(str, '\x1b[^m]*m', '')
  ---@type string
  while #strwocolor < len do
    ---@type string
    strwocolor = append .. strwocolor
    ---@type string
    str = append .. str
  end
  return str
end
M.padleft = padleft

--- Pad a string to a length all on the right end of the string, does not shorten the string
---@param str string | number
---@param len integer length resulting string should be
---@param append any
---@return string
local function padright(str, len, append)
  append = append or ' '
  if type(str) ~= 'string' then str = tostring(str) end
  -- strip out color strings out.
  local strwocolor = string.gsub(str, '\x1b[^m]*m', '')
  ---@type string
  while #strwocolor < len do
    ---@type string
    strwocolor = strwocolor .. append
    ---@type string
    str = str .. append
  end
  return str
end
M.padright = padright
--#endregion Utils

return M

-- vim: set fdm=marker fmr=--#region,--#endregion sts=2 sw=2:
