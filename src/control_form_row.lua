ControlFormRow = class(Control);

-- opts: label (drawn above the box), value (nil when not set), icon (image name drawn before the value), plus the
-- Control options
function ControlFormRow:constructor(opts)
  Control.constructor(self, opts)
  self.label = opts.label
  self.value = opts.value
  self.icon = opts.icon
end

function ControlFormRow:draw(ctx, g, is_focused)
  Control.draw(self, ctx, g, is_focused)

  local font = ctx.fonts.medium
  local font_height = font.line_height
  local content_color = is_focused and COLOR.WHITE or COLOR.BLACK

  g:text(self.x, self.y - font_height - 8, self.label, { font = font, color = COLOR.BLACK })

  local value_offset = 0
  if self.icon then
    local icon = ctx.package:image(self.icon)
    g:image(
      icon, self.x + LAYOUT.PADDING, self.y + (self.h - ICON.SMALL_SIZE) // 2,
      { color = COLOR.BLACK, invert = is_focused }
    )
    value_offset = 30
  end
  g:text_box(
    self.x + LAYOUT.PADDING + value_offset, self.y + self.h // 2 - font_height // 2,
    self.w - 3 * LAYOUT.PADDING - ICON.SMALL_SIZE, font_height,
    self.value or ctx.i18n:t("form.not_set"),
    { font = ctx.fonts.small, color = content_color, overflow = "ellipsis" }
  )

  local icon_chevron = ctx.package:image("chevron")
  g:image(
    icon_chevron, self.x + self.w - LAYOUT.PADDING - ICON.SMALL_SIZE, self.y + (self.h - ICON.SMALL_SIZE) // 2,
    { color = COLOR.BLACK, invert = is_focused }
  )
end
