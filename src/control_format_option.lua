local OPTION_PADDING = 12 -- above and below the text of the tallest option
local LABEL_GAP = 8 -- between the label and the description

ControlFormatOption = class(Control);

-- width of the label and description: between the radio and the code image, with a LAYOUT.PADDING gap on each side
function ControlFormatOption.get_text_width(w)
  return w - 4 * LAYOUT.PADDING - ICON.SIZE - ICON.LARGE_SIZE
end

-- height of the description of an option of width w, wrapped over as many lines as it needs
function ControlFormatOption.get_description_height(ctx, option, w)
  local _, height = ctx.fonts.small:layout(
    ctx.i18n:t(option.description), ControlFormatOption.get_text_width(w), ctx.screen.height, { wrap = "word" }
  )
  return height
end

-- height of an option of width w that shows its whole description
function ControlFormatOption.get_height(ctx, option, w)
  return ctx.fonts.medium.line_height + LABEL_GAP + ControlFormatOption.get_description_height(ctx, option, w)
    + 2 * OPTION_PADDING
end

-- opts: option (row of PASS.FORMATS), selected, plus the Control options
function ControlFormatOption:constructor(opts)
  Control.constructor(self, opts)
  self.option = opts.option
  self.selected = opts.selected
end

function ControlFormatOption:draw(ctx, g, is_focused)
  Control.draw(self, ctx, g, is_focused)

  local content_x = self.x + LAYOUT.PADDING
  local content_color = is_focused and COLOR.WHITE or COLOR.BLACK

  g:circle(content_x + ICON.SIZE // 2, self.y + self.h // 2, ICON.SIZE // 2, { color = content_color, line_width = 2 })
  if self.selected then
    g:circle(content_x + ICON.SIZE // 2, self.y + self.h // 2, ICON.SIZE // 4, { color = content_color, fill = true })
  end

  -- the options share the height of the tallest one, so the text is centred like the radio and the code image
  local text_x = content_x + ICON.SIZE + LAYOUT.PADDING
  local text_w = self.get_text_width(self.w)
  local label_h = ctx.fonts.medium.line_height
  local description_h = self.get_description_height(ctx, self.option, self.w)
  local text_y = self.y + (self.h - label_h - LABEL_GAP - description_h) // 2
  g:text_box(
    text_x, text_y, text_w, label_h,
    ctx.i18n:t(self.option.label),
    { color = content_color, wrap = "none", overflow = "ellipsis" }
  )
  g:text_box(
    text_x, text_y + label_h + LABEL_GAP, text_w, description_h,
    ctx.i18n:t(self.option.description),
    { font = ctx.fonts.small, color = content_color, wrap = "word" }
  )

  local code_icon = ctx.package:image(self.option.key)
  g:image(
    code_icon, self.x + self.w - LAYOUT.PADDING - ICON.LARGE_SIZE, self.y + (self.h - ICON.LARGE_SIZE) // 2,
    { color = COLOR.BLACK, invert = is_focused }
  )
end
