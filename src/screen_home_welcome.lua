HomeWelcomeScreen = class(Screen);

function HomeWelcomeScreen:draw_content(ctx, g)
  -- ticket image
  local image_ticket = ctx.package:image("ticket-empty")
  g:image(image_ticket, (ctx.screen.width - image_ticket.width) // 2, 254, { color = COLOR.BLACK })
  g:text(ctx.screen.width // 2, 456, ctx.i18n:t("home.empty.title"), { color = COLOR.BLACK, align = "center" })
  g:text_box(
    LAYOUT.PADDING, 498, ctx.screen.width - 2 * LAYOUT.PADDING, ctx.screen.height - 498,
    ctx.i18n:t("home.empty.text"),
    { color = COLOR.BLACK, font = ctx.fonts.small, align = "center" }
  )
end

-- data.focus_id (optional): id of the control to focus on arrival
function HomeWelcomeScreen:init(ctx, data)
  Screen.init(self, ctx, data)
  self.initial_focus = data and data.focus_id or nil
end

function HomeWelcomeScreen:create_controls(ctx)
  local gap = 10
  local y = ctx.screen.height - LAYOUT.PADDING - BUTTON.SIZE
  local about_x = ctx.screen.width - LAYOUT.PADDING - BUTTON.SIZE
  return {
    ControlButton:new({
      id = "create",
      x = LAYOUT.PADDING, y = y, w = about_x - gap - LAYOUT.PADDING, h = BUTTON.SIZE,
      label = ctx.i18n:t("home.create_first"),
      on_activate = function () self:request_screen("form") end,
    }),
    ControlIconButton:new({
      id = "about",
      x = about_x, y = y, h = BUTTON.SIZE,
      icon = "info",
      on_activate = function () self:request_screen("about") end,
    }),
  }
end

function HomeWelcomeScreen:get_initial_focus(ctx)
  return self.initial_focus
end

function HomeWelcomeScreen:get_title(ctx)
  return ctx.i18n:t("app.name")
end

function HomeWelcomeScreen:can_go_back()
  return false
end
