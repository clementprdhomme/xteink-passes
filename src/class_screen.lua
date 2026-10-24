Screen = class()

function Screen:constructor(request_screen_cb)
  self.request_screen_cb = request_screen_cb
  self.controls = {}
end

function Screen:init(ctx, data)
  self.data = data
  self.controls = {}
  -- the UI library keeps the previous screen's focus, so it is replaced on every arrival
  self.reset_focus = true
  self.pending_focus = nil
end

-- called when another screen is about to replace this one
function Screen:leave(ctx)
end

function Screen:draw(ctx, g)
  local title = self:get_title(ctx)
  if title then
    g:text(LAYOUT.PADDING, LAYOUT.TITLE_TOP, title, { font = ctx.fonts.large, color = COLOR.BLACK })
  end

  self:draw_content(ctx, g)

  self.controls = self:create_controls(ctx)

  ui:begin_frame(g)
  for _, control in ipairs(self.controls) do
    control:declare(ctx)
  end

  local focus_id = self.pending_focus
  if not focus_id and self.reset_focus then
    focus_id = self:get_initial_focus(ctx) or (self.controls[1] and self.controls[1].id)
  end
  if focus_id then
    ui:focus(focus_id)
  end
  self.pending_focus = nil
  self.reset_focus = false
  ui:end_frame()

  -- the focus is never drawn on a touch device (see Screen:on_input), even though the UI library keeps one
  local focused_id = not ctx.input.pointer and ui:focused() or nil
  for _, control in ipairs(self.controls) do
    control:draw(ctx, g, focused_id ~= nil and focused_id == control.id)
  end
end

function Screen:get_title(ctx)
  return nil
end

-- "Page x of y" at the left and one dot per page in the middle, on a line that ends at bottom; nothing for a single
-- page
function Screen:draw_page_indicator(ctx, g, page, total, bottom)
  if total <= 1 then
    return
  end
  local page_text = ctx.i18n:t("page.indicator", { page = page, total = total })
  local page_height = utils["text"].get_line_height(ctx.fonts.small, page_text)
  g:text(LAYOUT.PADDING, bottom - page_height, page_text, { color = COLOR.BLACK, font = ctx.fonts.small })

  local r = 6
  local gap = 5
  local width = total * (r * 2 + gap) - gap
  for i = 1, total do
    g:circle(
      (i - 1) * (r * 2 + gap) + r + (ctx.screen.width - width) // 2, bottom - page_height // 2, r,
      { color = COLOR.BLACK, line_width = 2, fill = i == page }
    )
  end
end

-- draw what isn't a control, called before the controls
function Screen:draw_content(ctx, g)
end

-- list of Control instances, rebuilt on every draw
function Screen:create_controls(ctx)
  return {}
end

-- id of the control focused when arriving on the screen, nil for the first one
function Screen:get_initial_focus(ctx)
  return nil
end

-- move the focus to the control with this id on the next draw
function Screen:set_focus(id)
  self.pending_focus = id
end

function Screen:request_screen(...)
  self.request_screen_cb(...)
end

function Screen:can_go_back()
  return true
end

function Screen:go_back()
end

-- swipes go to the next or previous page or pass in any direction: 1 for a swipe up or left, which brings in what comes
-- next, -1 for a swipe down or right, nil for any other event
function Screen:get_swipe_offset(ev)
  if ev.type ~= "pointer" then
    return nil
  end
  if ev.gesture == "swipe_up" or ev.gesture == "swipe_left" then
    return 1
  elseif ev.gesture == "swipe_down" or ev.gesture == "swipe_right" then
    return -1
  end
  return nil
end

-- input that no control covers; return true when handled
function Screen:on_screen_input(ctx, ev)
  return false
end

function Screen:on_input(ctx, ev)
  -- presses on the back button are not handled by the UI library and could show focus on the touch devices
  if ev.type == "key" and ev.key == "back" then
    if not self:can_go_back() then
      return false
    end
    if ev.phase == "up" then
      self:go_back()
    end
    return true
  end

  if self:on_screen_input(ctx, ev) == true then
    return true
  end

  local id, action, is_long
  if ctx.input.pointer then
    if ev.type == "key" then
      return false
    end

    -- the first tap already activated the control and should have changed the screen
    if ev.gesture == "double_tap" then
      return true
    end

    id, action = ui:handle_event(ev)
    is_long = action == "long_press"
  else
    -- key-only device: keys have no long press, so holding ok counts as one
    if ev.key == "ok" and ev.phase == "down" then
      self.ok_down_ms = ev.time_ms
    end
    id, action = ui:handle_event(ev)
    is_long = action == "long_press" or (self.ok_down_ms ~= nil and ev.time_ms - self.ok_down_ms >= INPUT.LONG_PRESS_MS)
  end

  if action == "activate" or action == "long_press" then
    local control = find_first(self.controls, function (row) return row.id == id end)
    if control then
      if is_long and control.on_long_activate then
        control:long_activate(ctx)
        return true
      end
      if action == "activate" then
        control:activate(ctx)
        return true
      end
    end
  end

  if action then
    ctx:invalidate()
    return true
  end

  return false
end
