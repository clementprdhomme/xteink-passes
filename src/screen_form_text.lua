FormTextScreen = class(Screen);

-- space between the box border and the text the host draws in it
local BOX_MARGIN = 12

-- data: field (row of FormScreen:get_fields), data (the form's data, given back to it on return)
function FormTextScreen:init(ctx, data)
  Screen.init(self, ctx, data)

  self.message = self:get_message(ctx, data.field.value or "")

  -- the keyboard docks at the bottom of this screen; without touch the host shows its own full-screen input instead
  local x, y, w, h = self:get_box(ctx)
  local editor, err = ctx.input:edit({
    rect = { x = x + BOX_MARGIN, y = y + BOX_MARGIN, w = w - 2 * BOX_MARGIN, h = h - 2 * BOX_MARGIN },
    text = data.field.value or "",
    max_chars = 256,
    kind = self:get_kind(),
    multiline = self:is_multiline(),
    enter = "done",
    on_change = function (ctx, text)
      self.message = self:get_message(ctx, text)
      ctx:invalidate()
    end,
    on_end = function (ctx, text, how)
      self.editor = nil
      if how == "enter" then
        self:save(text)
      else
        self:go_back()
      end
    end,
  })
  self.editor = editor

  if not editor then
    ctx.log:error("Unable to edit the " .. data.field.key .. " field: " .. err)
    self:go_back()
  end
end

function FormTextScreen:is_multiline()
  return self.data.field.key == "data"
end

-- keyboard matching what the format accepts
function FormTextScreen:get_kind()
  if self.data.field.key ~= "data" then
    return "text"
  end
  local format = self.data.data.format
  if format == "itf" then
    return "number"
  elseif format == "code128" then
    return "letters"
  end
  return "text"
end

-- why the data can't be shown in the format, or else why the code may not scan
function FormTextScreen:get_message(ctx, text)
  if self.data.field.key ~= "data" or #text == 0 then
    return nil
  end
  local format = self.data.data.format
  return utils["codes"].get_data_error(ctx, format, text) or utils["codes"].get_data_warning(ctx, format, text)
end

-- what the format accepts, for the formats that restrict the characters
function FormTextScreen:get_instructions(ctx)
  if self.data.field.key ~= "data" then
    return nil
  end
  local format = find_first(PASS.FORMATS, function (row) return row.key == self.data.data.format end)
  return format and format.instructions and ctx.i18n:t(format.instructions) or nil
end

-- the box fills the space above the keyboard when multiline, leaving two lines under it for the instructions and the
-- message (as tall as the small font can draw, since a message in Chinese, Japanese or Korean is drawn in the medium
-- font)
function FormTextScreen:get_box(ctx)
  local x = LAYOUT.PADDING
  local y = LAYOUT.CONTENT_TOP
  local w = ctx.screen.width - 2 * LAYOUT.PADDING
  if not self:is_multiline() then
    return x, y, w, BUTTON.SIZE
  end
  local bottom = ctx.screen.height - ctx.input.keyboard_h - LAYOUT.PADDING
    - 2 * (utils["text"].get_max_line_height(ctx.fonts.small) + 8)
  return x, y, w, bottom - y
end

function FormTextScreen:draw_content(ctx, g)
  local x, y, w, h = self:get_box(ctx)
  g:rect(x, y, w, h, { color = COLOR.BLACK, radius = BUTTON.RADIUS, line_width = 2 })

  local line_y = y + h + 8
  local instructions = self:get_instructions(ctx)
  if instructions then
    local line_height = utils["text"].get_line_height(ctx.fonts.small, instructions)
    g:text_box(
      x, line_y, w, line_height,
      instructions,
      { font = ctx.fonts.small, color = COLOR.BLACK, wrap = "none", overflow = "ellipsis" }
    )
    line_y = line_y + line_height + 8
  end
  if self.message then
    g:text_box(
      x, line_y, w, utils["text"].get_line_height(ctx.fonts.small, self.message),
      self.message,
      { font = ctx.fonts.small, color = COLOR.BLACK, wrap = "none", overflow = "ellipsis" }
    )
  end
end

function FormTextScreen:get_title(ctx)
  return self.data.field.label
end

function FormTextScreen:save(text)
  local new_data = shallow_copy(self.data.data)
  new_data[self.data.field.key] = #text > 0 and text or nil
  self:request_screen("form", new_data)
end

function FormTextScreen:go_back()
  self:request_screen("form", self.data.data)
end

function FormTextScreen:leave(ctx)
  if self.editor then
    self.editor:close()
    self.editor = nil
  end
end
