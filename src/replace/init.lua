-- brew install pcre
-- brew install lrexlib-pcre
local replace = {}
replace.brace = require('replace.brace')
replace.colors = require('replace.colors')
replace.swap = require('replace.swap')
replace.util = require('replace.util')

return replace

-- vim: set fdm=marker fmr=--#region,--#endregion sts=2 sw=2:
