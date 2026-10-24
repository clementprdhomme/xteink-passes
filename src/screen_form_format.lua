local MIN_OPTION_GAP = 8

FormFormatScreen = class(Screen);

-- every option is as tall as the one with the longest description, so the list keeps a regular rhythm in any language
function FormFormatScreen:get_option_height(ctx)
  local height = 0
  for _, option in ipairs(PASS.FORMATS) do
    height = math.max(height, ControlFormatOption.get_height(ctx, option, ctx.screen.width - 2 * LAYOUT.PADDING))
  end
  return height
end

-- top of the list, under the question
function FormFormatScreen:get_options_top(ctx)
  return LAYOUT.CONTENT_TOP + ctx.fonts.medium.line_height + LAYOUT.PADDING
end

-- space between the options: LAYOUT.PADDING, or less when long descriptions (in some languages) would push the list off
-- the screen
function FormFormatScreen:get_option_gap(ctx, option_height)
  local count = #PASS.FORMATS
  local available = ctx.screen.height - LAYOUT.PADDING - self:get_options_top(ctx)
  local gap = (available - count * option_height) // (count - 1)
  return math.max(MIN_OPTION_GAP, math.min(LAYOUT.PADDING, gap))
end

function FormFormatScreen:get_option_box(ctx, index, option_height, option_gap)
  local x = LAYOUT.PADDING
  local y = self:get_options_top(ctx) + (index - 1) * (option_height + option_gap)
  return x, y, ctx.screen.width - 2 * LAYOUT.PADDING, option_height
end

function FormFormatScreen:draw_content(ctx, g)
  g:text(LAYOUT.PADDING, LAYOUT.CONTENT_TOP, ctx.i18n:t("format.question"), { color = COLOR.BLACK })
end

function FormFormatScreen:create_controls(ctx)
  local controls = {}
  local option_height = self:get_option_height(ctx)
  local option_gap = self:get_option_gap(ctx, option_height)
  for i, option in ipairs(PASS.FORMATS) do
    local x, y, w, h = self:get_option_box(ctx, i, option_height, option_gap)
    table.insert(controls, ControlFormatOption:new({
      id = option.key,
      x = x, y = y, w = w, h = h,
      option = option,
      selected = self.data.field.value == option.key,
      on_activate = function (ctx) self:select_option(ctx, option.key) end,
    }))
  end
  return controls
end

function FormFormatScreen:get_initial_focus(ctx)
  local selected = self.data.field and self.data.field.value
  local is_option = selected and find_first(PASS.FORMATS, function (row) return row.key == selected end)
  return is_option and selected or nil
end

function FormFormatScreen:get_title(ctx)
  return self.data.field.label
end

function FormFormatScreen:go_back()
  self.request_screen_cb("form", self.data.data)
end

function FormFormatScreen:select_option(ctx, option_key)
  local new_data = shallow_copy(self.data.data)
  new_data[self.data.field.key] = option_key
  self.data.data = new_data
  self:go_back()
end
