local M = { _TYPE = 'module', _NAME = 'colors', _VERSION = '0.0.1.0' }

--#region Colors
--- @class ColorTableClass
--- @field IndianRed string
--- @field LightCoral string
--- @field Salmon string
--- @field DarkSalmon string
--- @field LightSalmon string
--- @field Crimson string
--- @field Red string
--- @field FireBrick string
--- @field DarkRed string
--- @field Pink string
--- @field LightPink string
--- @field HotPink string
--- @field DeepPink string
--- @field MediumVioletRed string
--- @field PaleVioletRed string
--- @field Coral string
--- @field Tomato string
--- @field OrangeRed string
--- @field DarkOrange string
--- @field Orange string
--- @field Gold string
--- @field Yellow string
--- @field LightYellow string
--- @field LemonChiffon string
--- @field LightGoldenrodYellow string
--- @field PapayaWhip string
--- @field Moccasin string
--- @field PeachPuff string
--- @field PaleGoldenrod string
--- @field Khaki string
--- @field DarkKhaki string
--- @field Lavender string
--- @field Thistle string
--- @field Plum string
--- @field Violet string
--- @field Orchid string
--- @field Fuchsia string
--- @field Magenta string
--- @field MediumOrchid string
--- @field MediumPurple string
--- @field RebeccaPurple string
--- @field BlueViolet string
--- @field DarkViolet string
--- @field DarkOrchid string
--- @field DarkMagenta string
--- @field Purple string
--- @field Indigo string
--- @field SlateBlue string
--- @field DarkSlateBlue string
--- @field MediumSlateBlue string
--- @field GreenYellow string
--- @field Chartreuse string
--- @field LawnGreen string
--- @field Lime string
--- @field LimeGreen string
--- @field PaleGreen string
--- @field LightGreen string
--- @field MediumSpringGreen string
--- @field SpringGreen string
--- @field MediumSeaGreen string
--- @field SeaGreen string
--- @field ForestGreen string
--- @field Green string
--- @field DarkGreen string
--- @field YellowGreen string
--- @field OliveDrab string
--- @field Olive string
--- @field DarkOliveGreen string
--- @field MediumAquamarine string
--- @field DarkSeaGreen string
--- @field LightSeaGreen string
--- @field DarkCyan string
--- @field Teal string
--- @field Aqua string
--- @field Cyan string
--- @field LightCyan string
--- @field PaleTurquoise string
--- @field Aquamarine string
--- @field Turquoise string
--- @field MediumTurquoise string
--- @field DarkTurquoise string
--- @field CadetBlue string
--- @field SteelBlue string
--- @field LightSteelBlue string
--- @field PowderBlue string
--- @field LightBlue string
--- @field SkyBlue string
--- @field LightSkyBlue string
--- @field DeepSkyBlue string
--- @field DodgerBlue string
--- @field CornflowerBlue string
--- @field RoyalBlue string
--- @field Blue string
--- @field MediumBlue string
--- @field DarkBlue string
--- @field Navy string
--- @field MidnightBlue string
--- @field Cornsilk string
--- @field BlanchedAlmond string
--- @field Bisque string
--- @field NavajoWhite string
--- @field Wheat string
--- @field BurlyWood string
--- @field Tan string
--- @field RosyBrown string
--- @field SandyBrown string
--- @field Goldenrod string
--- @field DarkGoldenrod string
--- @field Peru string
--- @field Chocolate string
--- @field SaddleBrown string
--- @field Sienna string
--- @field Brown string
--- @field Maroon string
--- @field White string
--- @field Snow string
--- @field HoneyDew string
--- @field MintCream string
--- @field Azure string
--- @field AliceBlue string
--- @field GhostWhite string
--- @field WhiteSmoke string
--- @field SeaShell string
--- @field Beige string
--- @field OldLace string
--- @field FloralWhite string
--- @field Ivory string
--- @field AntiqueWhite string
--- @field Linen string
--- @field LavenderBlush string
--- @field MistyRose string
--- @field Gainsboro string
--- @field LightGray string
--- @field Silver string
--- @field DarkGray string
--- @field Gray string
--- @field DimGray string
--- @field LightSlateGray string
--- @field SlateGray string
--- @field DarkSlateGray string
--- @field Black string
-- Non HTML colors
--- @field PaleRed string
--- @field DarkAqua string
--- @field ColorOff string
--- @field clear string?
--- @field under string?
--- @field double string?
--- @field curl string?
--- @field dot string?
--- @field dash string?

--- @enum ColorTable
local baseColorTable = {
  IndianRed = '\x1b[{CODE};2;205;92;92m',
  LightCoral = '\x1b[{CODE};2;240;128;128m',
  Salmon = '\x1b[{CODE};2;250;128;114m',
  DarkSalmon = '\x1b[{CODE};2;233;150;122m',
  LightSalmon = '\x1b[{CODE};2;255;160;122m',
  Crimson = '\x1b[{CODE};2;220;20;60m',
  Red = '\x1b[{CODE};2;255;0;0m',
  FireBrick = '\x1b[{CODE};2;178;34;34m',
  DarkRed = '\x1b[{CODE};2;139;0;0m',
  Pink = '\x1b[{CODE};2;255;192;203m',
  LightPink = '\x1b[{CODE};2;255;182;193m',
  HotPink = '\x1b[{CODE};2;255;105;180m',
  DeepPink = '\x1b[{CODE};2;255;20;147m',
  MediumVioletRed = '\x1b[{CODE};2;199;21;133m',
  PaleVioletRed = '\x1b[{CODE};2;219;112;147m',
  Coral = '\x1b[{CODE};2;255;127;80m',
  Tomato = '\x1b[{CODE};2;255;99;71m',
  OrangeRed = '\x1b[{CODE};2;255;69;0m',
  DarkOrange = '\x1b[{CODE};2;255;140;0m',
  Orange = '\x1b[{CODE};2;255;165;0m',
  Gold = '\x1b[{CODE};2;255;215;0m',
  Yellow = '\x1b[{CODE};2;255;255;0m',
  LightYellow = '\x1b[{CODE};2;255;255;224m',
  LemonChiffon = '\x1b[{CODE};2;255;250;205m',
  LightGoldenrodYellow = '\x1b[{CODE};2;250;250;210m',
  PapayaWhip = '\x1b[{CODE};2;255;239;213m',
  Moccasin = '\x1b[{CODE};2;255;228;181m',
  PeachPuff = '\x1b[{CODE};2;255;218;185m',
  PaleGoldenrod = '\x1b[{CODE};2;238;232;170m',
  Khaki = '\x1b[{CODE};2;240;230;140m',
  DarkKhaki = '\x1b[{CODE};2;189;183;107m',
  Lavender = '\x1b[{CODE};2;230;230;250m',
  Thistle = '\x1b[{CODE};2;216;191;216m',
  Plum = '\x1b[{CODE};2;221;160;221m',
  Violet = '\x1b[{CODE};2;238;130;238m',
  Orchid = '\x1b[{CODE};2;218;112;214m',
  Fuchsia = '\x1b[{CODE};2;255;0;255m',
  Magenta = '\x1b[{CODE};2;255;0;255m',
  MediumOrchid = '\x1b[{CODE};2;186;85;211m',
  MediumPurple = '\x1b[{CODE};2;147;112;219m',
  RebeccaPurple = '\x1b[{CODE};2;102;51;153m',
  BlueViolet = '\x1b[{CODE};2;138;43;226m',
  DarkViolet = '\x1b[{CODE};2;148;0;211m',
  DarkOrchid = '\x1b[{CODE};2;153;50;204m',
  DarkMagenta = '\x1b[{CODE};2;139;0;139m',
  Purple = '\x1b[{CODE};2;128;0;128m',
  Indigo = '\x1b[{CODE};2;75;0;130m',
  SlateBlue = '\x1b[{CODE};2;106;90;205m',
  DarkSlateBlue = '\x1b[{CODE};2;72;61;139m',
  MediumSlateBlue = '\x1b[{CODE};2;123;104;238m',
  GreenYellow = '\x1b[{CODE};2;173;255;47m',
  Chartreuse = '\x1b[{CODE};2;127;255;0m',
  LawnGreen = '\x1b[{CODE};2;124;252;0m',
  Lime = '\x1b[{CODE};2;0;255;0m',
  LimeGreen = '\x1b[{CODE};2;50;205;50m',
  PaleGreen = '\x1b[{CODE};2;152;251;152m',
  LightGreen = '\x1b[{CODE};2;144;238;144m',
  MediumSpringGreen = '\x1b[{CODE};2;0;250;154m',
  SpringGreen = '\x1b[{CODE};2;0;255;127m',
  MediumSeaGreen = '\x1b[{CODE};2;60;179;113m',
  SeaGreen = '\x1b[{CODE};2;46;139;87m',
  ForestGreen = '\x1b[{CODE};2;34;139;34m',
  Green = '\x1b[{CODE};2;0;128;0m',
  DarkGreen = '\x1b[{CODE};2;0;100;0m',
  YellowGreen = '\x1b[{CODE};2;154;205;50m',
  OliveDrab = '\x1b[{CODE};2;107;142;35m',
  Olive = '\x1b[{CODE};2;128;128;0m',
  DarkOliveGreen = '\x1b[{CODE};2;85;107;47m',
  MediumAquamarine = '\x1b[{CODE};2;102;205;170m',
  DarkSeaGreen = '\x1b[{CODE};2;143;188;139m',
  LightSeaGreen = '\x1b[{CODE};2;32;178;170m',
  DarkCyan = '\x1b[{CODE};2;0;139;139m',
  Teal = '\x1b[{CODE};2;0;128;128m',
  Aqua = '\x1b[{CODE};2;0;255;255m',
  Cyan = '\x1b[{CODE};2;0;255;255m',
  LightCyan = '\x1b[{CODE};2;224;255;255m',
  PaleTurquoise = '\x1b[{CODE};2;175;238;238m',
  Aquamarine = '\x1b[{CODE};2;127;255;212m',
  Turquoise = '\x1b[{CODE};2;64;224;208m',
  MediumTurquoise = '\x1b[{CODE};2;72;209;204m',
  DarkTurquoise = '\x1b[{CODE};2;0;206;209m',
  CadetBlue = '\x1b[{CODE};2;95;158;160m',
  SteelBlue = '\x1b[{CODE};2;70;130;180m',
  LightSteelBlue = '\x1b[{CODE};2;176;196;222m',
  PowderBlue = '\x1b[{CODE};2;176;224;230m',
  LightBlue = '\x1b[{CODE};2;173;216;230m',
  SkyBlue = '\x1b[{CODE};2;135;206;235m',
  LightSkyBlue = '\x1b[{CODE};2;135;206;250m',
  DeepSkyBlue = '\x1b[{CODE};2;0;191;255m',
  DodgerBlue = '\x1b[{CODE};2;30;144;255m',
  CornflowerBlue = '\x1b[{CODE};2;100;149;237m',
  RoyalBlue = '\x1b[{CODE};2;65;105;225m',
  Blue = '\x1b[{CODE};2;0;0;255m',
  MediumBlue = '\x1b[{CODE};2;0;0;205m',
  DarkBlue = '\x1b[{CODE};2;0;0;139m',
  Navy = '\x1b[{CODE};2;0;0;128m',
  MidnightBlue = '\x1b[{CODE};2;25;25;112m',
  Cornsilk = '\x1b[{CODE};2;255;248;220m',
  BlanchedAlmond = '\x1b[{CODE};2;255;235;205m',
  Bisque = '\x1b[{CODE};2;255;228;196m',
  NavajoWhite = '\x1b[{CODE};2;255;222;173m',
  Wheat = '\x1b[{CODE};2;245;222;179m',
  BurlyWood = '\x1b[{CODE};2;222;184;135m',
  Tan = '\x1b[{CODE};2;210;180;140m',
  RosyBrown = '\x1b[{CODE};2;188;143;143m',
  SandyBrown = '\x1b[{CODE};2;244;164;96m',
  Goldenrod = '\x1b[{CODE};2;218;165;32m',
  DarkGoldenrod = '\x1b[{CODE};2;184;134;11m',
  Peru = '\x1b[{CODE};2;205;133;63m',
  Chocolate = '\x1b[{CODE};2;210;105;30m',
  SaddleBrown = '\x1b[{CODE};2;139;69;19m',
  Sienna = '\x1b[{CODE};2;160;82;45m',
  Brown = '\x1b[{CODE};2;165;42;42m',
  Maroon = '\x1b[{CODE};2;128;0;0m',
  White = '\x1b[{CODE};2;255;255;255m',
  Snow = '\x1b[{CODE};2;255;250;250m',
  HoneyDew = '\x1b[{CODE};2;240;255;240m',
  MintCream = '\x1b[{CODE};2;245;255;250m',
  Azure = '\x1b[{CODE};2;240;255;255m',
  AliceBlue = '\x1b[{CODE};2;240;248;255m',
  GhostWhite = '\x1b[{CODE};2;248;248;255m',
  WhiteSmoke = '\x1b[{CODE};2;245;245;245m',
  SeaShell = '\x1b[{CODE};2;255;245;238m',
  Beige = '\x1b[{CODE};2;245;245;220m',
  OldLace = '\x1b[{CODE};2;253;245;230m',
  FloralWhite = '\x1b[{CODE};2;255;250;240m',
  Ivory = '\x1b[{CODE};2;255;255;240m',
  AntiqueWhite = '\x1b[{CODE};2;250;235;215m',
  Linen = '\x1b[{CODE};2;250;240;230m',
  LavenderBlush = '\x1b[{CODE};2;255;240;245m',
  MistyRose = '\x1b[{CODE};2;255;228;225m',
  Gainsboro = '\x1b[{CODE};2;220;220;220m',
  LightGray = '\x1b[{CODE};2;211;211;211m',
  Silver = '\x1b[{CODE};2;192;192;192m',
  DarkGray = '\x1b[{CODE};2;169;169;169m',
  Gray = '\x1b[{CODE};2;128;128;128m',
  DimGray = '\x1b[{CODE};2;105;105;105m',
  LightSlateGray = '\x1b[{CODE};2;119;136;153m',
  SlateGray = '\x1b[{CODE};2;112;128;144m',
  DarkSlateGray = '\x1b[{CODE};2;47;79;79m',
  Black = '\x1b[{CODE};2;0;0;0m',
  -- Non HTML colors
  PaleRed = '\x1b[{CODE};2;255;127;127m', -- not an HTML color
  DarkAqua = '\x1b[{CODE};2;0;170;170m', -- not an HTML color
  ColorOff = '\x1b[0m',
  clear = '\x1b[4:0m',
  under = '\x1b[4:1m',
  double = '\x1b[4:2m',
  curl = '\x1b[4:3m',
  dot = '\x1b[4:4m',
  dash = '\x1b[4:5m'
}

--- Map colors 
--- @param code string
--- @return ColorTableClass
local function map_colors(code)
  local out = {}
  for name, value in pairs(baseColorTable) do
    --- @diagnostic disable-next-line
    out[name] = value:gsub('{CODE}', code)
  end
  return out
end

M.FG = map_colors('38')
M.BG = map_colors('48')
M.UL = map_colors('58')

--- Parse a color number
--- @param input string
--- @param incr number?
--- @param mult number?
--- @return string -- 0-255;0-255;0-255
local function parse_numeric_color(input, incr, mult)
  incr = incr or 1
  mult = mult or 1
  local out = ''
  for i = 1, #input, incr do
    local c = tonumber(string.sub(input, i, i + incr - 1), 16)
    if c == nil then return '0;0;0' end
    out = out .. ';' .. (c * mult)
  end
  return out
end

--- Set a color
--- @param input string
--- @param type '38'|'48'|'58'
--- @return string
local function parse_color(input, type)
  if string.match(input, '^#') then
    input = string.sub(input, 2)
    --- @type string
    local out = '\x1b[' .. type .. ';2'
    if #input == 6 then
      out = out .. parse_numeric_color(input, 2)
    elseif #input == 3 then
      out = out .. parse_numeric_color(input, 1, 16)
    else
      return ''
    end
    return out .. 'm'
  end
  --- @type string | nil
  local color = M.FG[input]
  return color or ''
end

--- Set the background color
--- @param input string
--- @return string
local function bg(input)
  return parse_color(input, '48')
end
M.bg = bg

--- Set the foreground color
--- @param input string
--- @return string
local function fg(input)
  return parse_color(input, '38')
end
M.fg = fg

--- @type string
M.ColorOff = M.FG.ColorOff
--#endregion Colors

return M

-- vim: set fdm=marker fmr=--#region,--#endregion sts=2 sw=2:
