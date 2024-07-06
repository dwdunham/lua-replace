package = "lua-replace"
version = "0.5.0"
source = {
   url = "git+https://github.com/dwdunham/lua-replace"
}
description = {
   detailed = [[
## Provides utilities to expand braces and swap words regardless of case
* Expand range (with or without marked increments), expands lists]],
   homepage = "https://github.com/dwdunham/lua-replace",
   license = "Creative Commons CC0 1.0 Universal"
}
dependencies = {
   "lua >= 5.1, < 5.5",
   "lrexlib-posix >= 2.9.2-1",
}
build = {
   type = "builtin",
   modules = {
      ["replace.brace"] = "src/replace/brace.lua",
      ["replace.colors"] = "src/replace/colors.lua",
      ["replace.init"] = "src/replace/init.lua",
      ["replace.swap"] = "src/replace/swap.lua",
      ["replace.util"] = "src/replace/util.lua"
   }
}