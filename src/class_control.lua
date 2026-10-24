Control = class()

-- opts: id, x, y, w, h, on_activate (function(ctx)), on_long_activate (function(ctx), optional), plus the subclass's
-- own fields
function Control:constructor(opts)
  self.id = opts.id
  self.x, self.y, self.w, self.h = opts.x, opts.y, opts.w, opts.h
  self.on_activate = opts.on_activate
  self.on_long_activate = opts.on_long_activate
end

-- text drawn by the UI library
function Control:get_text()
  return ""
end

-- called between begin_frame and end_frame
function Control:declare(ctx)
  ui:button(self.id, { x = self.x, y = self.y, w = self.w, h = self.h, text = self:get_text(), radius = BUTTON.RADIUS })
end

-- called after end_frame, to draw the content on top of the button
-- the UI library's stroke can't be made thicker, so a 2px one is drawn over it (a rect stroke grows inward only)
function Control:draw(ctx, g, is_focused)
  g:rect(self.x, self.y, self.w, self.h, { color = COLOR.BLACK, radius = BUTTON.RADIUS, line_width = 2 })
end

function Control:activate(ctx)
  if self.on_activate then
    self.on_activate(ctx)
  end
end

function Control:long_activate(ctx)
  if self.on_long_activate then
    self.on_long_activate(ctx)
  end
end
