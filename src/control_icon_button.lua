ControlIconButton = class(Control);

-- opts: icon (image name), active (boolean, drawn filled for a toggle that is on), plus the Control options except w,
-- which always equals h
function ControlIconButton:constructor(opts)
  Control.constructor(self, opts)
  self.w = self.h
  self.icon = opts.icon
  self.active = opts.active
end

function ControlIconButton:draw(ctx, g, is_focused)
  Control.draw(self, ctx, g, is_focused)

  if self.active then
    g:rect(self.x, self.y, self.w, self.h, { color = COLOR.BLACK, radius = BUTTON.RADIUS, fill = true })
  end

  local icon = ctx.package:image(self.icon)
  g:image(
    icon, self.x + (self.w - ICON.SIZE) // 2, self.y + (self.h - ICON.SIZE) // 2,
    { color = COLOR.BLACK, invert = is_focused or self.active }
  )
end
