utils = {} -- list of utils
libs = {}  -- list of third-party libs
ui = nil   -- instance of ctx.ui

local screens = {}         -- list of screens
local current_screen = nil -- current active screen

require("constants")

require("utils")
require("utils_text")
require("utils_storage")
require("utils_lockscreen")
require("utils_dialog")
require("utils_codes")

require("lib_aztec")
require("lib_pdf417")
require("lib_code128")
require("lib_itf")

require("class_screen")
require("class_control")

require("control_button")
require("control_icon_button")
require("control_form_row")
require("control_format_option")
require("control_ticket")

require("screen_home")
require("screen_home_welcome")
require("screen_home_passes")
require("screen_form")
require("screen_form_format")
require("screen_form_text")
require("screen_pass")
require("screen_about")

function on_load(ctx)
  ui = ctx.ui:create()
  utils["storage"].load(ctx)

  local request_screen = function(name, data)
    if current_screen then
      current_screen:leave(ctx)
    end
    current_screen = screens[name]
    current_screen:init(ctx, data)
    ctx.invalidate()
  end

  screens["home"] = HomeScreen:new(request_screen)
  screens["home_welcome"] = HomeWelcomeScreen:new(request_screen)
  screens["home_passes"] = HomePassesScreen:new(request_screen)
  screens["form"] = FormScreen:new(request_screen)
  screens["form_format"] = FormFormatScreen:new(request_screen)
  screens["form_text"] = FormTextScreen:new(request_screen)
  screens["pass"] = PassScreen:new(request_screen)
  screens["about"] = AboutScreen:new(request_screen)

  request_screen("home")
  ctx.invalidate()
end

function on_draw(ctx, g)
  g:clear(COLOR.WHITE)
  if current_screen then
    current_screen:draw(ctx, g)
  end
end

function on_input(ctx, ev)
  if current_screen then
    return current_screen:on_input(ctx, ev)
  end
end
