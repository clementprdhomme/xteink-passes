-- Luacheck configuration: https://luacheck.readthedocs.io
-- The app runs Lua 5.5, which luacheck doesn't support yet; the code only uses syntax that Lua 5.4 shares

std = "lua54"
max_line_length = 120

-- every global the app defines on purpose: any other one is reported, so a new global has to be added here
globals = {
  -- set by index.lua and lockscreen.lua
  "utils", "libs", "ui",
  "on_load", "on_draw", "on_input",

  -- utils.lua
  "class", "shallow_copy", "find_first",

  -- constants.lua
  "APP", "LAYOUT", "COLOR", "ICON", "BUTTON", "INPUT", "HOME", "PASS", "DIALOG", "STORAGE", "CODE",

  -- classes
  "Screen", "Control",
  "AboutScreen", "FormScreen", "FormFormatScreen", "FormTextScreen",
  "HomeScreen", "HomePassesScreen", "HomeWelcomeScreen", "PassScreen",
  "ControlButton", "ControlFormRow", "ControlFormatOption", "ControlIconButton", "ControlTicket",
}

-- methods keep the arguments of the method they override, even when they don't use them
unused_args = false

-- callbacks take the ctx they're called with, in place of the one of the method that creates them
ignore = { "432/ctx" }
