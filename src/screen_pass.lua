-- space between the name and the notes in the stub, as on the home tickets
local STUB_NAME_GAP = 10
-- in dark mode, white space kept around the data text on the block that holds the code and its data
local DARK_BLOCK_PADDING = 8

PassScreen = class(Screen);

function PassScreen:init(ctx, data)
  data = data or {}
  if data.id then
    data = utils["storage"].get_pass(ctx, data.id)
  end

  Screen.init(self, ctx, data)

  self.light_on = false

  -- the code is created here because layers can't be drawn from on_draw, and released in leave; code_margin is its
  -- white margin on the side of the data
  self.code, self.code_error, self.code_margin = nil, nil, 0
  if data.format == "qr" then
    self.code, self.code_error, self.code_margin = utils["codes"].create_qr(ctx, data.data)
  elseif data.format == "aztec" then
    self.code, self.code_error, self.code_margin = utils["codes"].create_aztec(ctx, data.data)
  elseif data.format == "pdf417" then
    self.code, self.code_error, self.code_margin = utils["codes"].create_pdf417(ctx, data.data)
  elseif data.format == "code128" then
    self.code, self.code_error, self.code_margin = utils["codes"].create_code128(ctx, data.data)
  elseif data.format == "itf" then
    self.code, self.code_error, self.code_margin = utils["codes"].create_itf(ctx, data.data)
  end
  self.code_margin = self.code_margin or 0
  if self.code_error then
    ctx.log:error("Unable to create the " .. data.format .. " code: " .. self.code_error)
  end

  -- beside a long code, the text is turned a quarter like the code, so it's drawn into layers here too
  self.stub_layer, self.data_layer, self.error_layer = nil, nil, nil
  if self:has_side_stub() then
    self.stub_layer = self:create_text_layer(ctx, PASS.TICKET_HEIGHT, PASS.STUB_SIZE, function(g)
      self:draw_stub(ctx, g, 0, 0, PASS.TICKET_HEIGHT)
    end)
    self.data_layer = self:create_text_layer(ctx, PASS.TICKET_HEIGHT - 2 * LAYOUT.PADDING, PASS.DATA_HEIGHT, function(g)
      self:draw_data(ctx, g, 0, 0, PASS.TICKET_HEIGHT - 2 * LAYOUT.PADDING)
    end)
    if self.code_error then
      self.error_layer = self:create_text_layer(ctx, CODE.LONG_LENGTH, CODE.LONG_WIDTH, function(g)
        self:draw_error(ctx, g, 0, 0, CODE.LONG_LENGTH, CODE.LONG_WIDTH)
      end)
    end
  end

  -- a full refresh clears the ghosting the previous screen leaves on the e-ink, so the code is clean for the scanner
  ctx:invalidate("full")
end

function PassScreen:get_format()
  return find_first(PASS.FORMATS, function (row) return row.key == self.data.format end)
end

-- long codes (barcodes, PDF417) run down the ticket with the stub beside them; square codes (QR, Aztec) have it below
function PassScreen:has_side_stub()
  local format = self:get_format()
  return format ~= nil and format.shape == "long"
end

-- top of the ticket: LAYOUT.PADDING above the buttons
function PassScreen:get_ticket_top(ctx)
  return ctx.screen.height - 2 * LAYOUT.PADDING - BUTTON.SIZE - PASS.TICKET_HEIGHT
end

-- create a transparent layer, w by h, and draw text into it with draw(g), to show it turned with draw_turned; returns
-- nil if it can't be created; the caller must release it
-- can't be called from on_draw since it draws into a layer
function PassScreen:create_text_layer(ctx, w, h, draw)
  local layer, err = ctx.layers:create(w, h)
  if layer then
    local _
    _, err = layer:draw(draw)
    if not err then
      return layer
    end
    layer:release()
  end
  ctx.log:error("Unable to create a text layer: " .. err)
  return nil
end

-- draw a layer turned a quarter clockwise, as the long codes are, with its top-left corner at x, y: a w by h layer
-- covers h by w, and the top of its text faces right; turned around its top-left corner, it lands left of the pivot
function PassScreen:draw_turned(g, layer, x, y, invert)
  if layer then
    g:image(layer, x + layer.height, y, { rotate = 90, pivot_x = 0, pivot_y = 0, invert = invert })
  end
end

-- stub, from x, y, with the perforation at the top: the name, then the notes if any, each on one line and centred
-- vertically, as on the home tickets; length is the stub's length along the perforation
function PassScreen:draw_stub(ctx, g, x, y, length)
  local notes = self.data.notes ~= "" and self.data.notes or nil
  local name_height = utils["text"].get_line_height(ctx.fonts.large, self.data.name)
  local notes_height = notes and utils["text"].get_line_height(ctx.fonts.small, notes) or nil
  local height = notes_height and (name_height + STUB_NAME_GAP + notes_height) or name_height
  local text_x, text_y, text_w = x + LAYOUT.PADDING, y + (PASS.STUB_SIZE - height) // 2, length - 2 * LAYOUT.PADDING

  g:text_box(
    text_x, text_y, text_w, name_height,
    self.data.name,
    { font = ctx.fonts.large, color = COLOR.BLACK, wrap = "none", overflow = "ellipsis" }
  )
  if notes_height then
    g:text_box(
      text_x, text_y + name_height + STUB_NAME_GAP, text_w, notes_height,
      notes,
      { font = ctx.fonts.small, color = COLOR.BLACK, wrap = "none", overflow = "ellipsis" }
    )
  end
end

-- the code's data on one line under it, from x, y, w wide, as printed under a barcode; the line stays LAYOUT.PADDING
-- from the ends of the ticket; with invert, it's drawn white, for the dark-mode block (see draw_dark_block)
function PassScreen:draw_data(ctx, g, x, y, w, invert)
  g:text_box(
    x, y, w, PASS.DATA_HEIGHT,
    self.data.data,
    {
      font = ctx.fonts.medium, color = invert and COLOR.WHITE or COLOR.BLACK, align = "center", valign = "middle",
      wrap = "none", overflow = "ellipsis",
    }
  )
end

-- width of the data text in a line w wide, where it's centred and cut with an ellipsis when longer
function PassScreen:get_data_width(ctx, w)
  local width = ctx.fonts.medium:measure(self.data.data)
  return math.min(width or w, w)
end

-- in dark mode the device inverts the whole screen, and some scanners can't read a code shown white on black, so the
-- code and its data are drawn inverted on a black block, which the device shows black on white; the block is the
-- smallest rectangle around the code image (x, y, w, h) and the data text (text_x, text_y, text_w, text_h), with
-- DARK_BLOCK_PADDING around the text
function PassScreen:draw_dark_block(g, x, y, w, h, text_x, text_y, text_w, text_h)
  local left = math.min(x, text_x - DARK_BLOCK_PADDING)
  local top = math.min(y, text_y - DARK_BLOCK_PADDING)
  local right = math.max(x + w, text_x + text_w + DARK_BLOCK_PADDING)
  local bottom = math.max(y + h, text_y + text_h + DARK_BLOCK_PADDING)
  g:rect(left, top, right - left, bottom - top, { color = COLOR.BLACK, fill = true })
end

-- message in place of a code that can't be drawn
function PassScreen:draw_error(ctx, g, x, y, w, h)
  g:text_box(
    x, y, w, h,
    ctx.i18n:t("pass.unable"),
    { font = ctx.fonts.medium, color = COLOR.BLACK, align = "center", valign = "middle" }
  )
end

-- the ticket: the code with its data under it, centred in the part beside the stub. The data sits PASS.DATA_GAP from
-- the code's ink, inside its white margin, and the two are centred together. Beside a long code, the stub and the data
-- are turned like the code, so turning the device a quarter to the left shows the same ticket as a square code
-- in dark mode, the code and its data stay black on white (see draw_dark_block); a message in place of the code
-- follows dark mode like the rest of the ticket
function PassScreen:draw_content(ctx, g)
  local x, y = LAYOUT.PADDING, self:get_ticket_top(ctx)
  -- read on every draw: dark mode can change at any time, and the device then draws the screen again
  local dark = ctx.device:display().dark
  local keep_code = dark and self.code ~= nil

  if self:has_side_stub() then
    g:image(ctx.package:image("ticket-pass-vert"), x, y)
    self:draw_turned(g, self.stub_layer, x, y)

    -- across the ticket: the data, the gap, then the code; the code first, so its white margin doesn't cover the data
    local area_x, code_y = x + PASS.STUB_SIZE + PASS.CODE_MARGIN, y + PASS.CODE_MARGIN
    local code_w = self.code and self.code.width or CODE.LONG_WIDTH
    local margin = self.code and self.code_margin or 0
    local data_x = area_x + (CODE.LONG_WIDTH - code_w + 2 * margin) // 2
    local code_x = data_x + PASS.DATA_HEIGHT + PASS.DATA_GAP - margin
    local data_y, data_length = y + LAYOUT.PADDING, PASS.TICKET_HEIGHT - 2 * LAYOUT.PADDING
    if self.code then
      local image_y = code_y + (CODE.LONG_LENGTH - self.code.height) // 2
      if keep_code then
        -- the text runs down the ticket, centred along the data line
        local text_length = self:get_data_width(ctx, data_length)
        self:draw_dark_block(
          g, code_x, image_y, self.code.width, self.code.height,
          data_x, data_y + (data_length - text_length) // 2, PASS.DATA_HEIGHT, text_length
        )
      end
      g:image(self.code, code_x, image_y, { invert = keep_code })
    else
      self:draw_turned(g, self.error_layer, code_x, code_y)
    end
    self:draw_turned(g, self.data_layer, data_x, data_y, keep_code)
    return
  end

  g:image(ctx.package:image("ticket-pass"), x, y)
  self:draw_stub(ctx, g, x, y + PASS.TICKET_HEIGHT - PASS.STUB_SIZE, PASS.TICKET_WIDTH)

  -- down the ticket: the code, the gap, then the data
  local code_x, code_w = x + PASS.CODE_MARGIN, PASS.TICKET_WIDTH - 2 * PASS.CODE_MARGIN
  local code_h = self.code and self.code.height or CODE.SQUARE_SIZE
  local margin = self.code and self.code_margin or 0
  local area_h = PASS.TICKET_HEIGHT - PASS.STUB_SIZE - 2 * PASS.CODE_MARGIN
  local code_y = y + PASS.CODE_MARGIN
    + (area_h - (code_h - 2 * margin) - PASS.DATA_GAP - PASS.DATA_HEIGHT) // 2 - margin
  local data_x, data_y = x + LAYOUT.PADDING, code_y + code_h - margin + PASS.DATA_GAP
  local data_w = PASS.TICKET_WIDTH - 2 * LAYOUT.PADDING
  if self.code then
    local image_x = code_x + (code_w - self.code.width) // 2
    if keep_code then
      local text_w = self:get_data_width(ctx, data_w)
      self:draw_dark_block(
        g, image_x, code_y, self.code.width, self.code.height,
        data_x + (data_w - text_w) // 2, data_y, text_w, PASS.DATA_HEIGHT
      )
    end
    g:image(self.code, image_x, code_y, { invert = keep_code })
  else
    self:draw_error(ctx, g, code_x, code_y, code_w, code_h)
  end
  self:draw_data(ctx, g, data_x, data_y, data_w, keep_code)
end

function PassScreen:create_controls(ctx)
  local gap = 10
  local y = ctx.screen.height - LAYOUT.PADDING - BUTTON.SIZE
  local x = LAYOUT.PADDING
  local delete_x = ctx.screen.width - LAYOUT.PADDING - BUTTON.SIZE
  local controls = {}

  -- only devices with a front light get the button, to light the code up for a scanner in a dim place
  if ctx.frontlight then
    table.insert(controls, ControlIconButton:new({
      id = "light",
      x = x, y = y, h = BUTTON.SIZE,
      icon = "light",
      active = self.light_on,
      on_activate = function (ctx) self:toggle_light(ctx) end,
    }))
    x = x + BUTTON.SIZE + gap
  end

  table.insert(controls, ControlButton:new({
    id = "edit",
    x = x, y = y, w = delete_x - gap - x, h = BUTTON.SIZE,
    label = ctx.i18n:t("menu.edit"),
    on_activate = function () self:request_screen("form", self.data) end,
  }))

  table.insert(controls, ControlIconButton:new({
    id = "delete",
    x = delete_x, y = y, h = BUTTON.SIZE,
    icon = "trash",
    on_activate = function (ctx)
      utils["dialog"].confirm_delete(ctx, self.data.id, function (ctx, neighbour_id)
        self:request_screen("home", { focus_id = neighbour_id })
      end)
    end,
  }))

  return controls
end

-- free the code and the turned text: the device never drops them (at most 8 QR images and 4 layers at once)
function PassScreen:release_images()
  for _, key in ipairs({ "code", "stub_layer", "data_layer", "error_layer" }) do
    if self[key] then
      self[key]:release()
      self[key] = nil
    end
  end
end

-- show the previous (-1) or next (1) pass of the list in place, so the front light stays as it is
function PassScreen:go_to_pass(ctx, offset)
  local passes = utils["storage"].get_passes(ctx)
  local _, index = find_first(passes, function (row) return row.id == self.data.id end)
  local pass = index and passes[index + offset]
  if not pass then
    return
  end
  local light_on = self.light_on
  self:release_images()
  self:init(ctx, { id = pass.id })
  self.light_on = light_on
end

-- a swipe, or the page keys of the X4 Pro, goes to the next or previous pass; on the X4 Classic, up and down do it, and
-- left and right still move the focus between the buttons, which sit side by side
function PassScreen:on_screen_input(ctx, ev)
  local offset = nil
  if ctx.input.pointer then
    if ev.phase ~= "up" then
      return false
    end
    if ev.type == "pointer" then
      offset = self:get_swipe_offset(ev)
    else
      offset = ((ev.key == "down" or ev.key == "right") and 1) or ((ev.key == "up" or ev.key == "left") and -1) or nil
    end
  elseif ev.phase == "down" then
    offset = (ev.key == "down" and 1) or (ev.key == "up" and -1) or nil
  end

  if not offset then
    return false
  end
  -- at the first or last pass nothing happens, but the key or swipe is still taken, so up and down never move the focus
  self:go_to_pass(ctx, offset)
  return true
end

-- full brightness when on; off gives the front light back to the user's settings
function PassScreen:toggle_light(ctx)
  self.light_on = not self.light_on
  if self.light_on then
    ctx.frontlight:set({ on = true, brightness = 100 })
  else
    ctx.frontlight:reset()
  end
  ctx:invalidate()
end

function PassScreen:leave(ctx)
  self:release_images()
  if self.light_on then
    ctx.frontlight:reset()
    self.light_on = false
  end
end

function PassScreen:can_go_back()
  return true
end

function PassScreen:go_back()
  self:request_screen("home", { focus_id = self.data.id })
end
