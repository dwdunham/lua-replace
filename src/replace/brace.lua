local M = { _TYPE = 'module', _NAME = 'brace', _VERSION = '0.0.1.0' }

local colors = require('replace.colors')
local util = require('replace.util')
local L = {}
L.dump = util.ldump

--#region Utils
FG = colors.FG;
BG = colors.BG;
UL = colors.UL;
local dprint = util.dprint
local split = util.split
local clone_table = util.clone_table
local dump = util.dump
--#endregion Utils

--#region expand braces
--- @class (exact) CharEntryParser.CharEntry
--- @field pos integer
--- @field start integer?
--- @field remove boolean?
--- @field char string
--- @field match integer?
--- @field parent integer?
--- @field type string?


--- @class CharEntryParser.State
--- @field open table<integer, CharEntryParser.CharEntry>
--- @field comma table<integer, CharEntryParser.CharEntry>
--- @field entries table<integer, CharEntryParser.CharEntry>
--- @field dot table<integer, CharEntryParser.CharEntry>
--- @field escape_mode boolean
--- @field dot_mode boolean

--- Match commas to open and closing braces
--- @param state CharEntryParser.State
--- @param open any
--- @param close any
--- @return CharEntryParser.CharEntry[], boolean
local function match_commas(state, open, close)
  local out = {}
  local success = false
  dprint(FG.Aqua .. '------------------------------------------ ')
  -- -- print(L.dump('DarkOrchid', 'match_commas:', state.comma) .. ', ' .. L.dump('Wheat', 'open:', open, '; close:', close))
  local prev = open
  --- @type integer[], integer[]
  local dots, commas = {}, {}
  for idx = 1, #state.comma, 1 do
    local item = state.comma[idx]
    -- -- print(L.dump('#d2d', 'item:', item, ';open:', open.pos, ';close:', close.pos) .. ';' .. L.dump('#2d2', 'comma:', state.comma))
    if item.pos < close.pos and item.pos > open.pos then
      if item.char == ',' then table.insert(commas, idx) end
      if item.char == '.' then table.insert(dots, idx) end
      if item.char == '.' and #commas > 0 then goto next end
      -- -- print('Found match:' .. L.dump('#fa0', 'item:', item, 'open:', open))
      success = true
      item.parent = open.pos
      if item.char == '.' or item.char == ',' then open.type = item.char end
      local a = 1;
      while prev and prev.char == '.' and item.char == ',' do
        -- -- print(L.dump('#cc0', 'Slipping bonds of time:', prev, item))
        prev = state.comma[idx - a]
        a = a + 1
      end
      if prev and prev.pos > open.pos then
        item.match = prev.pos
      else
        item.match = open.pos
      end
    else
      -- -- print('skipping?:' , dump(item))
      table.insert(out, item)
    end
    prev = item
    ::next::
  end
  -- -- print('WWW:', L.dump('Green', state.entries))
  if #commas > 0 and #dots > 0 then
    for _, dot in pairs(dots) do
      local entries_str = util.lua_dump(state.entries, 0, false, true)
      local value = table.remove(state.entries, dot)
      open.type = ','
      -- -- print('Removed:' .. dot .. '; value: ' .. dump(value) .. ';entries: ' .. entries_str)
    end
  end
  -- -- print('finished match_commas; '.. L.dump('#02ffb4', state.entries) .. ';' .. L.dump('Wheat', ' open: ', state.open))
  return out, success
end

--- Generate all of the boundary markers for brace expansion
--- @param pos integer
--- @param char string
--- @param state CharEntryParser.State
local function generate_position_entry(pos, char, state)
  local interesting = { ['{'] = true, ['}'] = true, [','] = true, ['.'] = true };
  local item = { pos = pos, char = char };
  if state.escape_mode then -- Handle escaped '{', '}', '\', '.' and ','
    state.escape_mode = false
    if interesting[char] ~= nil then
      dprint('found interesting:"'..char..'";"'..tostring(interesting[char])..'"; pos: ' .. pos)
      table.insert(state.entries, { pos = pos - 1, char = '\\', remove = true })
      return
    elseif char == '\\' then
      return
    end
  end
  if interesting[char] == nil and char ~= '\\' then return end
  --print('handling:' .. char .. ColorOff)
  ::redo::
  if '{' == char then
    table.insert(state.entries, item)
    table.insert(state.open, item)
    table.insert(state.comma, item)
  elseif ',' == char then
    table.insert(state.entries, item)
    table.insert(state.comma, item)
  elseif '\\' == char then
    state.escape_mode = true
  elseif state.dot_mode then
    state.dot_mode = false
    if char == '.' then
      item = { pos = pos, start = pos - 1, char = '.' }
      table.insert(state.entries, item)
      table.insert(state.comma, item)
    else
      dprint(BG.RoyalBlue .. 'redoing because original was:' .. char .. ColorOff)
      goto redo
    end
  elseif '.' == char and state.comma[#state.comma].char ~= ',' then
    state.dot_mode = true
  elseif '}' == char then
    local size = #state.open
    -- -- print('--- >' .. L.dump('#030', state) ..';char:' .. char .. ';i:' .. pos .. ';size: '.. size);
    local segment_open_brace = table.unpack(state.open, size, size)
    if segment_open_brace == nil then
      dprint(FG.HotPink .. 'Removing ' .. char .. ' no match;' .. dump(state.entries))
    else
      local c, success = match_commas(state, segment_open_brace, item)
      state.comma = c
      if success then
        table.insert(state.entries, item)
        local sp, ip = L.dump('Pink', segment_open_brace), L.dump('#face00', item)
        segment_open_brace.match = item.pos;
        item.match = segment_open_brace.pos;
        -- -- print(L.dump('Orange', 'Connecting matches:') ..  'sob[' .. sp .. ']:' .. L.dump('HotPink', segment_open_brace) .. 'item[' .. ip .. ']:' .. L.dump('#aa8800', item))
      end
      table.remove(state.open, #state.open)
      --dprint(FG.DarkAqua .. 'Matched: ' .. dump(item) .. ' with ' .. dump(segment_open_brace) .. ColorOff)
    end
  end
end

-- Find all matched '{', '}' and all ',' in a matching block. Handle '\\' character.
--- Find endings of sub-segments, `{...,` `,...}` 
--- @param str any
--- @return table<integer, CharEntryParser.CharEntry> all_entries
--- @return table<integer, string>
local function find_segment_endings(str)
  -- Pass One make queues for adding data
  -- open - stack of entries for open braces
  -- comma - stack of entries for commas
  -- entries - all interesting entries (those with '{', '}', ',', '\\'
  --- @type CharEntryParser.State
  local state = {
    comma = {},
    dot = {},
    entries = {},
    open = {},
    escape_mode = false,
    dot_mode = false
  }
  --- @type number, string
  for pos, char in pairs(split(str, '')) do
    generate_position_entry(pos, char, state)
  end
  -- -- print(L.dump('#2ff', 'State.Entries:', state.entries))
  --- @type table<integer, CharEntryParser.CharEntry>
  local all_entries = {}
  dprint(FG.MediumPurple .. dump(state.entries))
  --- @type CharEntryParser.CharEntry
  for _, item in pairs(state.entries) do
    if item.match ~= nil or item.remove then
      -- -- print('Adding:', L.dump('#6fc', item))
      table.insert(all_entries, item)
    else
      -- -- print('Not Adding:', L.dump('#6fc', item))
    end
  end
  local queue = {}
  --dprint('#entries:'..#state.entries..'; entries:' .. dump(state.entries))
  --dprint('#all_entries:' .. #all_entries .. '; for str:"' .. str .. '";' .. FG.Turquoise .. dump(all_entries) .. ColorOff)
  if #all_entries == 0 then
    dprint(FG.Navy .. 'no entries found adding entire string '..ColorOff..'"' .. str .. '"')
    table.insert(queue, str)
  elseif all_entries[1].pos > 1 then
    dprint(FG.Gold .. 'Adding first entry:' .. L.dump('', all_entries[1],
      string.sub(str, 1, all_entries[1].pos - 1)))
    table.insert(queue, string.sub(str, 1, all_entries[1].pos - 1))
  end
  -- -- print(L.dump('#fac', 'entries:', all_entries).. '; ' .. L.dump('#afc', 'queue:', queue))
  return all_entries, queue
end

--- Expand a range...
--- @param range CharEntryParser.Range
--- @param out CharEntryParser.SegmentTable?
--- @return CharEntryParser.SegmentTable
local function expand_range_value(range, out)
  out = out or {}
  --dprint('range:', dump(range))
  local start = range.start or range.scode
  local finish = range.finish or range.ecode
  local func = range.start ~= nil and tostring or string.char
  local goodChar = (range.start ~= nil and range.finish ~= nil)
  local goodCode =  (range.scode ~= nil and range.ecode ~= nil and range.start == nil)
  dprint('range:', dump(range))
  if start > finish then range.incr = - range.incr; end
  if start ~= nil and finish ~= nil and (goodChar or goodCode) then
    for i = start, finish, range.incr do
      table.insert(out, func(i))
    end
  end
  return out
end

--- Check if chars in list match.
--- @param entries CharEntryParser.CharEntry[]
--- @param idx integer
--- @param expected string[]
--- @return boolean, integer
local function check_match(entries, idx, expected)
  for index = 1, #expected, 1 do
    local str = expected[index]
    local good, values = true, split(str, '')
    for i = 1, #values, 1 do
      local entry, char = entries[i+idx-1], values[i]
      good = entry ~= nil and entry.char == char
      if not good then goto continue end
    end
    ::continue::
    if good then return true, #values end
  end
  return false, -1
end

--- Expand a range. There are the following types:
--- 1. {1..4} = 1, 2, 3, 4
--- 2. {a..c} = a, b, c;
--- 3. {1..5..2} = 1, 3, 5
--- 4. {a..e..2} = a, c, e
--- @param idx integer
--- @param str string
--- @param entries CharEntryParser.CharEntry[]
--- @param start CharEntryParser.CharEntry
--- @param orig_queue CharEntryParser.SegmentTable
--- @param stack CharEntryParser.SegmentTable[]
--- @return boolean, integer, CharEntryParser.CharEntry, CharEntryParser.SegmentTable
local function expand_range(idx, str, entries, start, orig_queue, stack)
  -- We only care about {.} or {..}
  local match, size = check_match(entries, idx-1, {'{.}', '{..}'})
  if not match then
    return false, idx, entries[idx], orig_queue
  end
  dprint('SIZE:' .. size, L.dump('', entries))
  --- @type CharEntryParser.Range
  local range = { incr = 1 }
  --- @type CharEntryParser.CharEntry, CharEntryParser.CharEntry, CharEntryParser.CharEntry
  local mid, next, last = table.unpack(entries, idx)
  --- @type string
  local segment = string.sub(str, start.pos + 1, mid.start - 1)
  if #segment == 1 or string.match(segment, '^\\\\+') then
    range.scode = string.byte(segment)
    if string.match(str, '[0-9]') then range.start = tonumber(segment) end
  elseif string.match(segment, '^[0-9]+$') then
    range.start = tonumber(segment)
  elseif string.match(segment, '^\\\\+') or #segment == 1 then
    range.scode = string.byte(string.sub(segment, 1, 1))
    dprint(L.dump('Red', 'no match:', segment, #segment))
  end
  segment = string.sub(str, mid.pos + 1, (next.start or next.pos) - 1)
  if range.start == nil and (#segment == 1 or segment == '\\\\') then
    range.ecode = string.byte(string.sub(segment, 1, 1)) -- Here because \ isn't working quite right
  elseif string.match(segment, '^[0-9]+$') then
    range.finish = tonumber(segment)
  elseif #segment == 1 or segment == '\\\\' then
    range.ecode = string.byte(string.sub(segment, 1, 1))
    range.start = nil
  else
    goto goto_out
  end
  if size == 4 then
    segment = string.sub(str, next.pos + 1, last.pos - 1)
    if not string.match(segment, '^[0-9]+$') then goto goto_out end
    --- @diagnostic disable-next-line
    range.incr = tonumber(segment)
  end
  if size ~= -1 then
    local queue = expand_range_value(range)
    table.insert(orig_queue, queue)
    table.insert(stack, orig_queue)
    return true, idx + size - 1, size == 4 and last or next, queue
  end

  ::goto_out::
  dprint('Failed to find match:' .. idx, dump(entries))
  segment = string.sub(str, start.pos, (last and last.pos or next.pos))
  table.insert(orig_queue, segment)
  return true, idx + size - 1, last or next, orig_queue
  --return false, idx, entries[idx], orig_queue
end

--- @class CharEntryParser.QueueState
--- @field i integer
--- @field str string
--- @field entries CharEntryParser.CharEntry[]
--- @field prev CharEntryParser.CharEntry
--- @field queue CharEntryParser.CharEntry
--- @field stack CharEntryParser.SegmentTable

--- Expand comma separated lists into merged segments
--- @param stack CharEntryParser.SegmentTable
--- @param queue CharEntryParser.CharEntry
--- @param prev CharEntryParser.CharEntry
--- @param segment string
--- @param key string
--- @param f CharEntryParser.QueueState
--- @return CharEntryParser.SegmentTable
local function expand_comma_sep_list(stack, queue, prev, segment, key, f)
  dprint(FG.DeepSkyBlue..'handling:'..dump(prev)..'; for key:'.. key)
  --- @type string?
  local state = nil
  local success, newIdx, p, range_queue = expand_range(f.i, f.str, f.entries, prev, queue, stack)
  if success then
    f.i = newIdx;
    f.prev = p
    table.insert(queue, range_queue)
    table.insert(stack, queue)
    queue = range_queue
  end
  if ',' == prev.char and state ~= '.' then
    table.insert(queue, segment)
    state = ','
  elseif '.' == prev.char and state ~= ',' then
    dprint(FG.Bisque .. '"' .. segment .. '"; prev:' .. dump(prev))
    state = '.'
  elseif '\\' == prev.char then
    --- @diagnostic disable
    for idx, value in pairs(queue) do
      dprint(L.dump('Green', 'idx:', idx, 'value:', value, 'queue:', queue))
      queue[idx] = value .. segment
    end
    --- @diagnostic enable
  elseif '{' == prev.char then
    local nqueue = { segment }
    table.insert(queue, nqueue)
    table.insert(stack, queue)
    queue = nqueue
  elseif '}' == prev.char then
    queue = table.remove(stack, #stack)
    table.insert(queue, segment)
  end
  return queue
end

--- Merge all in from into to
--- @generic T
--- @param to T[]
--- @param from T[]
local function merge_into(to, from)
  for i = 1, #from, 1 do table.insert(to, from[i]) end
end
L.merge_into = merge_into; -- TODO: remove???

--- @class CharEntryParser.Range
--- @field start integer?
--- @field finish integer?
--- @field scode integer?
--- @field ecode integer?
--- @field incr integer

--- Take the expansion boundary markers and create a nested structure that
--- can be flattened into the expanded strings
--- @param str string
--- @param all_entries CharEntryParser.CharEntry[]
--- @param sstack CharEntryParser.SegmentTable
local function compose_segment_table(str, all_entries, sstack)
  dprint(FG.DarkOrange .. 'start compose_segment_table:' .. dump(all_entries))
  --- @type CharEntryParser.CharEntry[]
  local entries = clone_table(all_entries)
  local queue = sstack
  local stack = { queue }
  local prev = #entries > 0 and entries[1] or nil
  local xd = { i = 0, entries = entries, str = str, prev = nil }
  for i = 2, #entries, 1 do
    --dprint(FG.Fuchsia .. 'loop:'..dump(queue))
    local item = entries[i]
    prev = entries[i - 1]
    xd.i = i;
    local success = false
    success, i, item, queue = expand_range(i, str, entries, prev, queue, stack)
    if not success then
      local key_str = prev.pos+1 .. ':' .. item.pos+1
      local segment = string.sub(str, prev.pos + 1, item.pos - 1)
      queue = expand_comma_sep_list(stack, queue, prev, segment, key_str, xd)
      i = xd.i; item = xd.prev or item; xd.prev = nil
    end
    prev = item
  end
  if prev and prev.pos <= #str then
    local key_str = prev.pos + 1 .. ":" .. #str
    local segment = string.sub(str, prev.pos + 1, #str)
    expand_comma_sep_list(stack, queue, prev, segment, key_str, xd)
  end
  dprint(FG.DarkOrange..'end compose_segment_table:'..dump(sstack))
end

local function all_of_type(queue, typename)
  if type(queue) == typename then return true
  elseif type(queue) ~= 'table' then return false
  else
    --- @diagnostic disable-next-line
    for _, i in pairs(queue) do
      if type(i) ~= typename then return false end
    end
  end
  return true
end

local function spairs(queue)
  if type(queue) == 'table' then
    return pairs(queue)
  else
    return pairs({ tostring(queue) })
  end
end
--- Merge two tables into each other...
--- @param first string[]
--- @param mid string[]
--- @param after string[]
local function merge_string_lists_into_segment_list(first, mid, after)
  for _, f in spairs(first) do
    for _, i in spairs(mid) do
      table.insert(after, f .. i)
    end
  end
end

--- @alias XSegment string|string[]|string[][]
--- @alias YSegment XSegment|XSegment[]
--- @alias ZSegment XSegment|YSegment|ZSegment[]
--- @alias CharEntryParser.SegmentTable ZSegment[]

--- Flatten teh structure of string segments into a single list of expanded strings
--- @param queue CharEntryParser.SegmentTable
--- @param all any
--- @return CharEntryParser.SegmentTable -- this should return a string[]
local function flatten(queue, all)
  dprint(FG.Olive .. 'flatten: queue:'.. dump(queue) .. '; all: ' .. dump(all))
  if type(queue) ~= 'table' or #queue == 1 then return queue end
  if all_of_type(queue, 'string') then return queue end
  if #queue == 2 then
    --- @type CharEntryParser.SegmentTable, CharEntryParser.SegmentTable
    local first, second = queue[1], queue[2] --- @diagnostic disable-line
    local before = flatten(first, all)
    local after = flatten(second, all)
    local merged = {}
    merge_string_lists_into_segment_list(before, after, merged)
    return merged
  end
  local cursor = table.remove(queue, 1)
  local index = 1
  local out = {}
  local isSeparateSegment = true
  while #queue > 0 do
    local next = table.remove(queue, 1)
    index = index + 1
    if type(next) == 'table' then
      isSeparateSegment = false
      local mid = all_of_type(next, 'string') and next or flatten(next, all)
      local after = {}
      merge_string_lists_into_segment_list(cursor, mid, after)
      if #out == 0 and #queue == 0 then
        return after
      end
      cursor = after
    elseif type(next) == 'string' then
      if isSeparateSegment then
        for _, i in spairs(cursor) do table.insert(out, i) end
        cursor = next;
      else
        local tmp = {}
        merge_string_lists_into_segment_list(cursor, next, tmp)
        cursor = tmp
        isSeparateSegment = true
      end
    else
      dprint(FG.Crimson .. 'Don\'t know how to handle ' .. dump(cursor) .. ';queue:' .. dump(queue) .. ColorOff)
      return {}
    end
  end
  for _, i in spairs(cursor) do table.insert(out, i) end
  return out
end

--- Expand braces
--- @param str string
--- @return string[]
local function expand(str)
  local all_entries, stack = find_segment_endings(str)
  compose_segment_table(str, all_entries, stack)
  -- The first item always needs to be a string for a nucleation site.
  if #stack > 0 and type(stack[1]) ~= 'string' then table.insert(stack, 1, '') end
  return flatten(stack, str)
end
M.expand = expand
--#endregion expand braces

return M

-- vim: set fdm=marker fmr=--#region,--#endregion sts=2 sw=2:
