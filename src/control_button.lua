ControlButton = class(Control);

-- opts: label, plus the Control options
function ControlButton:constructor(opts)
  Control.constructor(self, opts)
  self.label = opts.label
end

function ControlButton:get_text()
  return self.label
end
