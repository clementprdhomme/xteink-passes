-- options of the Code 128 and ITF encoders, shared by the drawing and the data check
local BARCODE_OPTIONS = { max_width = CODE.LONG_LENGTH, margin = CODE.BARCODE_MARGIN }

-- options of the PDF417 encoder, shared by the drawing and the data check; laid out horizontally, the symbol's width
-- becomes the length once turned
local PDF417_OPTIONS = {
  max_width = CODE.LONG_LENGTH,
  max_height = CODE.LONG_WIDTH,
  margin = CODE.MARGIN,
  row_height = CODE.PDF417_ROW_HEIGHT,
}

-- create a white layer and draw black rectangles into it; the caller must release it
-- draw(rect) lays the code out horizontally, w by h, with rect(x, y, w, h); with turn, the layer is turned a quarter
-- clockwise (h by w), so the start of the code is at the top. It's a rotation, not a mirror, which a 2D code needs to
-- scan
-- can't be called from on_draw since it draws into a layer
local function create_layer(ctx, w, h, draw, turn)
  local layer, err
  if turn then
    layer, err = ctx.layers:create(h, w)
  else
    layer, err = ctx.layers:create(w, h)
  end
  if not layer then
    return nil, err
  end

  local _, draw_err = layer:draw(function(g)
    g:clear(COLOR.WHITE)
    draw(function(x, y, rect_w, rect_h)
      if turn then
        g:rect(h - y - rect_h, x, rect_h, rect_w, { color = COLOR.BLACK, fill = true })
      else
        g:rect(x, y, rect_w, rect_h, { color = COLOR.BLACK, fill = true })
      end
    end)
  end)
  if draw_err then
    layer:release()
    return nil, draw_err
  end

  return layer
end

-- width in pixels of the thinnest bar of a long code, or nil if the data can't be shown in the format
-- QR and Aztec codes aren't measured: in the square part of the ticket, their squares stay large enough
local function get_module_size(format, data)
  if format == "code128" then
    local modules, module_size = libs["code128"].encode(data, BARCODE_OPTIONS)
    return modules and module_size or nil
  elseif format == "itf" then
    local widths, narrow = libs["itf"].encode(data, BARCODE_OPTIONS)
    return widths and narrow or nil
  elseif format == "pdf417" then
    local matrix, _, _, module_size = libs["pdf417"].encode(data, PDF417_OPTIONS)
    return matrix and module_size or nil
  end
  return nil
end

-- call draw_run(start, length) for each run of consecutive dark cells in a row of booleans, so a run is one rect
local function each_dark_run(row, count, draw_run)
  local x = 1
  while x <= count do
    if row[x] then
      local start = x
      while x <= count and row[x] do
        x = x + 1
      end
      draw_run(start, x - start)
    else
      x = x + 1
    end
  end
end

-- white margin across a Code 128 or ITF barcode, along its bars, in pixels: CODE.MARGIN modules, as around the other
-- codes, but no more than fits the long part of the ticket beside the bars; the quiet zones at the ends are separate
local function get_bar_margin(module_size)
  return math.min(CODE.MARGIN * module_size, (CODE.LONG_WIDTH - CODE.BAR_HEIGHT) // 2)
end

-- white margin of a QR code image, in pixels: the device adds 4 modules on every side but doesn't say the module size,
-- so it's found from the side it picked, (17 + 4 × version + 8) × module size, with the largest module size that fits
-- CODE.SQUARE_SIZE; versions are tried from the largest, so if two match, the smaller margin never covers the code
local function get_qr_margin(side)
  for version = 40, 1, -1 do
    local count = 17 + 4 * version + 8
    local module_size = CODE.SQUARE_SIZE // count
    if module_size > 0 and count * module_size == side then
      return 4 * module_size
    end
  end
  return 0
end

-- each create_* function returns the image, or nil and an error, and then the image's white margin (the quiet zone) in
-- pixels on the side of the data, so the data can sit the same distance from the visible part of every code
utils["codes"] = {
  -- create the image of a QR code, for the square part of the ticket; the caller must release it
  create_qr = function(ctx, data)
    local image, err = ctx.qr:encode(data, { size = CODE.SQUARE_SIZE })
    if not image then
      return nil, err
    end
    return image, nil, get_qr_margin(image.width)
  end,

  -- create the image of an Aztec code, for the square part of the ticket; the caller must release it
  -- can't be called from on_draw since it draws into a layer
  create_aztec = function(ctx, data)
    local matrix, matrix_size = libs["aztec"].encode(data)
    if not matrix then
      return nil, matrix_size
    end

    -- largest whole-pixel module that fits, like ctx.qr:encode
    local side = matrix_size + 2 * CODE.MARGIN
    local module_size = CODE.SQUARE_SIZE // side
    if module_size < 1 then
      return nil, "limit_exceeded"
    end

    local layer, err = create_layer(ctx, side * module_size, side * module_size, function(rect)
      for y = 1, matrix_size do
        each_dark_run(matrix[y], matrix_size, function(start, length)
          rect(
            (CODE.MARGIN + start - 1) * module_size, (CODE.MARGIN + y - 1) * module_size,
            length * module_size, module_size
          )
        end)
      end
    end)
    return layer, err, CODE.MARGIN * module_size
  end,

  -- create the image of a Code 128 barcode, turned to run down the long part of the ticket; the caller must release it
  -- can't be called from on_draw since it draws into a layer
  create_code128 = function(ctx, data)
    local modules, module_size = libs["code128"].encode(data, BARCODE_OPTIONS)
    if not modules then
      return nil, module_size
    end

    local width = #modules
    local bar_margin = get_bar_margin(module_size)
    local layer_w = (width + 2 * CODE.BARCODE_MARGIN) * module_size
    local layer, err = create_layer(ctx, layer_w, CODE.BAR_HEIGHT + 2 * bar_margin, function(rect)
      each_dark_run(modules, width, function(start, length)
        rect((CODE.BARCODE_MARGIN + start - 1) * module_size, bar_margin, length * module_size, CODE.BAR_HEIGHT)
      end)
    end, true)
    return layer, err, bar_margin
  end,

  -- create the image of an ITF barcode, turned to run down the long part of the ticket; the caller must release it
  -- can't be called from on_draw since it draws into a layer
  create_itf = function(ctx, data)
    local widths, narrow = libs["itf"].encode(data, BARCODE_OPTIONS)
    if not widths then
      return nil, narrow
    end

    local margin = CODE.BARCODE_MARGIN * narrow
    local width = 2 * margin
    for _, element_width in ipairs(widths) do
      width = width + element_width
    end

    local bar_margin = get_bar_margin(narrow)
    local layer, err = create_layer(ctx, width, CODE.BAR_HEIGHT + 2 * bar_margin, function(rect)
      -- elements alternate between bars and spaces, starting with a bar
      local x = margin
      for i, element_width in ipairs(widths) do
        if i % 2 == 1 then
          rect(x, bar_margin, element_width, CODE.BAR_HEIGHT)
        end
        x = x + element_width
      end
    end, true)
    return layer, err, bar_margin
  end,

  -- create the image of a PDF417 code, turned to run down the long part of the ticket; the caller must release it
  -- can't be called from on_draw since it draws into a layer
  create_pdf417 = function(ctx, data)
    local matrix, width, rows, module_size = libs["pdf417"].encode(data, PDF417_OPTIONS)
    if not matrix then
      return nil, width
    end

    local row_height = CODE.PDF417_ROW_HEIGHT * module_size
    local layer_w = (width + 2 * CODE.MARGIN) * module_size
    local layer_h = rows * row_height + 2 * CODE.MARGIN * module_size
    local layer, err = create_layer(ctx, layer_w, layer_h, function(rect)
      for y = 1, rows do
        each_dark_run(matrix[y], width, function(start, length)
          rect(
            (CODE.MARGIN + start - 1) * module_size, CODE.MARGIN * module_size + (y - 1) * row_height,
            length * module_size, row_height
          )
        end)
      end
    end, true)
    return layer, err, CODE.MARGIN * module_size
  end,

  -- message explaining why the data can't be shown in the format, if it can't
  get_data_error = function(ctx, format, data)
    if format == "code128" then
      local modules, err = libs["code128"].encode(data, BARCODE_OPTIONS)
      if not modules then
        if err == "limit_exceeded" then
          return ctx.i18n:t("code.too_long", { format = ctx.i18n:t("format.code128.label") })
        end
        return ctx.i18n:t("code.code128_characters")
      end
    elseif format == "itf" then
      local widths, err = libs["itf"].encode(data, BARCODE_OPTIONS)
      if not widths then
        if err == "limit_exceeded" then
          return ctx.i18n:t("code.too_long", { format = ctx.i18n:t("format.itf.label") })
        end
        return ctx.i18n:t("code.itf_characters")
      end
    end
    return nil
  end,

  -- message when the data can be shown in the format, but with bars too thin for some scanners
  get_data_warning = function(ctx, format, data)
    local module_size = get_module_size(format, data)
    if module_size and module_size < CODE.WARNING_MODULE_SIZE then
      return ctx.i18n:t("code.thin_bars")
    end
    return nil
  end,
}
