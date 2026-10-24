HomePassesScreen = class(Screen);

-- data.focus_id (optional): id of the control to focus on arrival; for a pass, its page is shown
function HomePassesScreen:init(ctx, data)
  Screen.init(self, ctx, data)

  self.initial_focus = data and data.focus_id or nil
  self.page = 1

  local passes = utils["storage"].get_passes(ctx)
  local _, index = find_first(passes, function (row) return row.id == self.initial_focus end)
  if index then
    self.page = (index - 1) // HOME.TICKETS_PER_PAGE + 1
  end
end

function HomePassesScreen:get_page_range(ctx)
  local passes = utils["storage"].get_passes(ctx)
  local start_index = (self.page - 1) * HOME.TICKETS_PER_PAGE + 1
  local end_index = math.min(#passes, self.page * HOME.TICKETS_PER_PAGE)
  return start_index, end_index
end

function HomePassesScreen:get_page_count(ctx)
  local start_index, end_index = self:get_page_range(ctx)
  return end_index - start_index + 1
end

function HomePassesScreen:get_total_pages(ctx)
  local passes = utils["storage"].get_passes(ctx)
  return math.ceil(#passes / HOME.TICKETS_PER_PAGE)
end

function HomePassesScreen:go_to_page(ctx, page, focus_last)
  if page < 1 or page > self:get_total_pages(ctx) or page == self.page then
    return false
  end

  self.page = page

  local start_index, end_index = self:get_page_range(ctx)
  local passes = utils["storage"].get_passes(ctx)
  self:set_focus(passes[focus_last and end_index or start_index].id)

  ctx:invalidate()

  return true
end

function HomePassesScreen:get_ticket_box(ctx, local_index)
  local x = LAYOUT.PADDING
  local h = 100
  local y = LAYOUT.CONTENT_TOP + (local_index - 1) * (h + LAYOUT.PADDING)
  local w = ctx.screen.width - 2 * LAYOUT.PADDING
  return x, y, w, h
end

function HomePassesScreen:draw_content(ctx, g)
  self:draw_page_indicator(
    ctx, g, self.page, self:get_total_pages(ctx), ctx.screen.height - 2 * LAYOUT.PADDING - BUTTON.SIZE
  )
end

function HomePassesScreen:create_controls(ctx)
  local passes = utils["storage"].get_passes(ctx)
  local start_index, end_index = self:get_page_range(ctx)
  local controls = {}

  for i = start_index, end_index, 1 do
    local pass = passes[i]
    local x, y, w, h = self:get_ticket_box(ctx, i - start_index + 1)
    table.insert(controls, ControlTicket:new({
      id = pass.id,
      x = x, y = y, w = w, h = h,
      pass = pass,
      on_activate = function () self:request_screen("pass", { id = pass.id }) end,
      on_long_activate = function (ctx) self:open_pass_menu(ctx, pass) end,
    }))
  end

  local gap = 10
  local y = ctx.screen.height - LAYOUT.PADDING - BUTTON.SIZE
  local about_x = ctx.screen.width - LAYOUT.PADDING - BUTTON.SIZE

  table.insert(controls, ControlButton:new({
    id = "create",
    x = LAYOUT.PADDING, y = y, w = about_x - gap - LAYOUT.PADDING, h = BUTTON.SIZE,
    label = ctx.i18n:t("home.new_pass"),
    on_activate = function () self:request_screen("form") end,
  }))

  table.insert(controls, ControlIconButton:new({
    id = "about",
    x = about_x, y = y, h = BUTTON.SIZE,
    icon = "info",
    on_activate = function () self:request_screen("about") end,
  }))

  return controls
end

function HomePassesScreen:get_initial_focus(ctx)
  return self.initial_focus
end

-- shortcut to the pass screen's actions, plus reordering
function HomePassesScreen:open_pass_menu(ctx, pass)
  local passes = utils["storage"].get_passes(ctx)
  local _, index = find_first(passes, function (row) return row.id == pass.id end)

  -- the moves that would do nothing are left out
  local entries = {}
  table.insert(entries, { label = ctx.i18n:t("menu.edit"), action = function (ctx)
    local data = shallow_copy(pass)
    data.back_screen = "home"
    self:request_screen("form", data)
  end })
  if index > 1 then
    table.insert(entries, { label = ctx.i18n:t("menu.move_up"), action = function (ctx)
      self:move_pass(ctx, pass.id, index - 1)
    end })
  end
  if index < #passes then
    table.insert(entries, { label = ctx.i18n:t("menu.move_down"), action = function (ctx)
      self:move_pass(ctx, pass.id, index + 1)
    end })
  end
  if index > 1 then
    table.insert(entries, { label = ctx.i18n:t("menu.move_top"), action = function (ctx)
      self:move_pass(ctx, pass.id, 1)
    end })
  end
  if utils["lockscreen"].is_shown(ctx, pass.id) then
    table.insert(entries, { label = ctx.i18n:t("menu.lockscreen_remove"), action = function (ctx)
      utils["lockscreen"].remove(ctx)
    end })
  else
    table.insert(entries, { label = ctx.i18n:t("menu.lockscreen_show"), action = function (ctx)
      utils["lockscreen"].show(ctx, pass.id)
    end })
  end
  table.insert(entries, { label = ctx.i18n:t("menu.delete"), action = function (ctx)
    utils["dialog"].confirm_delete(ctx, pass.id, function (ctx, neighbour_id)
      self:request_screen("home", { focus_id = neighbour_id })
    end)
  end })

  local labels = {}
  for i, entry in ipairs(entries) do
    labels[i] = entry.label
  end

  utils["dialog"].choose(ctx, { title = pass.name, items = labels }, function (ctx, selected)
    if selected then
      entries[selected].action(ctx)
    end
  end)
end

-- the list reopens on the pass's new page, focused on it
function HomePassesScreen:move_pass(ctx, id, position)
  utils["storage"].move_pass(ctx, id, position)
  self:request_screen("home", { focus_id = id })
end

function HomePassesScreen:get_title(ctx)
  return ctx.i18n:t("app.name")
end

function HomePassesScreen:can_go_back()
  return false
end

function HomePassesScreen:on_screen_input(ctx, ev)
  local forward = ev.key == "down" or ev.key == "right"
  local backward = ev.key == "up" or ev.key == "left"

  -- touch device: a swipe or a key turns the page
  if ctx.input.pointer then
    if ev.phase ~= "up" then
      return false
    end

    if ev.type == "pointer" then
      local offset = self:get_swipe_offset(ev)
      if offset then
        self:go_to_page(ctx, self.page + offset, false)
        return true
      end
      return false
    end

    if forward then
      return self:go_to_page(ctx, self.page + 1, false)
    end
    if backward then
      return self:go_to_page(ctx, self.page - 1, false)
    end
    return false
  end

  -- key-only device: the arrows move between the passes of one page first; at the edge of the list, the same key turns
  -- the page and the focus follows
  if (forward or backward) and ev.phase == "down" then
    local passes = utils["storage"].get_passes(ctx)
    local start_index, end_index = self:get_page_range(ctx)
    local focused_id = ui:focused()
    if forward and focused_id == passes[end_index].id then
      return self:go_to_page(ctx, self.page + 1, false)
    elseif backward and focused_id == passes[start_index].id then
      return self:go_to_page(ctx, self.page - 1, true)
    end
  end

  return false
end
