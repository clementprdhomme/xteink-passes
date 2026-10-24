utils = {} -- list of utils
libs = {}  -- list of third-party libs

require("constants")

require("utils")
require("utils_text")
require("utils_storage")
require("utils_lockscreen")
require("utils_codes")


require("lib_aztec")
require("lib_pdf417")
require("lib_code128")
require("lib_itf")

require("class_screen")

require("screen_pass")

local screen = nil

local LockScreenPass = class(PassScreen)

function LockScreenPass:get_ticket_top(ctx)
  return (ctx.screen.height - PASS.TICKET_HEIGHT) // 2
end

-- the code is created here because layers can't be drawn from on_draw
function on_load(ctx)
  utils["storage"].load(ctx)
  local id = utils["lockscreen"].get_pass_id(ctx)
  local pass = id and find_first(utils["storage"].get_passes(ctx), function (row) return row.id == id end)
  if pass then
    screen = LockScreenPass:new()
    screen:init(ctx, { id = id })
  end
end

function on_draw(ctx, g)
  g:clear(COLOR.WHITE)
  if screen then
    screen:draw_content(ctx, g)
  else
    g:text_box(
      LAYOUT.PADDING, 0, ctx.screen.width - 2 * LAYOUT.PADDING, ctx.screen.height,
      ctx.i18n:t("lockscreen.empty", { app = ctx.i18n:t("app.name") }),
      { color = COLOR.BLACK, align = "center", valign = "middle" }
    )
  end
end
