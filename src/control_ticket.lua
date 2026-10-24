local TICKET_TEXT_WIDTH = 342

ControlTicket = class(Control);

-- opts: pass (stored pass), plus the Control options
function ControlTicket:constructor(opts)
  Control.constructor(self, opts)
  self.pass = opts.pass
end

function ControlTicket:draw(ctx, g, is_focused)
  local format = find_first(PASS.FORMATS, function (row) return row.key == self.pass.format end)
  local details = ctx.i18n:t(format.label) .. " · " .. self.pass.data
  local name_height = utils["text"].get_line_height(ctx.fonts.large, self.pass.name)
  local details_height = utils["text"].get_line_height(ctx.fonts.small, details)
  local name_y_offset = (self.h - name_height - 10 - details_height) // 2
  local format_y_offset = name_y_offset + name_height + 10
  local content_color = is_focused and COLOR.WHITE or COLOR.BLACK

  local image_ticket = ctx.package:image("ticket")
  g:image(image_ticket, self.x, self.y, { color = COLOR.BLACK })
  g:text_box(
    self.x + LAYOUT.PADDING, self.y + name_y_offset, TICKET_TEXT_WIDTH - 2 * LAYOUT.PADDING, name_height,
    self.pass.name,
    { color = content_color, font = ctx.fonts.large, wrap = "none", overflow = "ellipsis" }
  )
  g:text_box(
    self.x + LAYOUT.PADDING, self.y + format_y_offset, TICKET_TEXT_WIDTH - 2 * LAYOUT.PADDING, details_height,
    details,
    { color = content_color, font = ctx.fonts.small, wrap = "none", overflow = "ellipsis" }
  )

  local image_code = ctx.package:image(self.pass.format)
  g:image(
    image_code,
    self.x + TICKET_TEXT_WIDTH + (self.w - TICKET_TEXT_WIDTH - ICON.LARGE_SIZE) // 2,
    self.y + (self.h - ICON.LARGE_SIZE) // 2,
    { color = COLOR.BLACK, invert = is_focused }
  )
end
