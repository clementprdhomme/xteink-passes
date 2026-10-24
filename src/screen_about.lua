AboutScreen = class(Screen);

local HEADING_GAP = 24  -- space above a heading, except at the top of a page
local PARAGRAPH_GAP = 12
local LINE_GAP = 4

-- data.focus_id is given back to the home screen on return
function AboutScreen:init(ctx, data)
  Screen.init(self, ctx, data)
  self.page = 1
  self.pages = self:paginate(ctx)
end

-- how to use the app, the app itself, and the third-party code, as a list of blocks: { heading = "…" } or
-- { text = "…" }
-- keep it up to date with the features, the controls and the files under src/lib_*.lua; the texts are in lang/*.tsv
function AboutScreen:get_content(ctx)
  local is_touch = ctx.input.pointer
  local blocks = {}

  local function heading(text) table.insert(blocks, { heading = text }) end
  local function text(value) table.insert(blocks, { text = value }) end
  local function t(key, params) return ctx.i18n:t(key, params) end

  heading(t("about.how.heading"))
  text(t("about.how.add", { button = t("home.new_pass") }))
  if ctx.frontlight then
    text(t("about.how.show_light"))
  else
    text(t("about.how.show"))
  end
  text(t("about.how.sideways"))
  if is_touch then
    text(t("about.how.menu_touch"))
  else
    text(t("about.how.menu_keys"))
  end
  if is_touch then
    text(t("about.how.switch_touch"))
  else
    text(t("about.how.switch_keys"))
  end
  text(t("about.how.lockscreen"))

  heading(t("app.name"))
  text(t("about.app.version", { version = APP.VERSION, author = APP.AUTHOR }))
  text(t("about.app.source", { repository = APP.REPOSITORY }))

  heading(t("about.third_party.heading"))
  text(t("about.third_party.zxing"))
  text(t("about.third_party.barcode4j"))
  -- the notice of the Apache License's NOTICE file, kept word for word and in English
  text("Barcode4J\nCopyright 2002-2010 Jeremias Märki\nCopyright 2005-2006 Dietmar Bürkle\n\n"
    .. "Portions of this software were contributed under section 5 of the Apache License. Contributors are listed "
    .. "under: http://barcode4j.sourceforge.net/contributors.html")

  return blocks
end

-- the page indicator is drawn under the box
function AboutScreen:get_text_box(ctx)
  local bottom = ctx.screen.height - 2 * LAYOUT.PADDING - utils["text"].get_max_line_height(ctx.fonts.small)
  return LAYOUT.PADDING, LAYOUT.CONTENT_TOP, ctx.screen.width - 2 * LAYOUT.PADDING, bottom - LAYOUT.CONTENT_TOP
end

-- split the content into pages of { font, text, y, h } items, y being relative to the top of the text box
function AboutScreen:paginate(ctx)
  local _, _, w, h = self:get_text_box(ctx)
  local heading_font, text_font = ctx.fonts.medium, ctx.fonts.small
  local pages, page, y = {}, {}, 0

  local function new_page()
    table.insert(pages, page)
    page, y = {}, 0
  end

  for _, block in ipairs(self:get_content(ctx)) do
    if block.heading then
      -- a heading moves to the next page when the first line of its text wouldn't fit under it
      local gap = y > 0 and HEADING_GAP or 0
      if y > 0 and y + gap + heading_font.line_height + PARAGRAPH_GAP + text_font.line_height > h then
        new_page()
        gap = 0
      end
      y = y + gap
      table.insert(page, { font = heading_font, text = block.heading, y = y, h = heading_font.line_height })
      y = y + heading_font.line_height + PARAGRAPH_GAP
    else
      local remaining = block.text
      while #remaining > 0 do
        -- the gap after the previous block can leave less than a line, or even a negative height, which layout refuses
        if y > 0 and h - y < text_font.line_height then
          new_page()
        end
        local lines, height, consumed = text_font:layout(remaining, w, h - y, { wrap = "word", line_gap = LINE_GAP })
        if lines == 0 and y == 0 then
          break -- not even one line fits on an empty page
        elseif lines == 0 then
          new_page()
        else
          table.insert(page, { font = text_font, text = remaining:sub(1, consumed), y = y, h = height })
          y = y + height + PARAGRAPH_GAP
          remaining = remaining:sub(consumed + 1)
          if #remaining > 0 then
            new_page()
          end
        end
      end
    end
  end

  if #page > 0 then
    table.insert(pages, page)
  end
  return pages
end

function AboutScreen:go_to_page(ctx, page)
  if page < 1 or page > #self.pages or page == self.page then
    return false
  end
  self.page = page
  ctx:invalidate()
  return true
end

function AboutScreen:draw_content(ctx, g)
  local x, y, w = self:get_text_box(ctx)
  for _, item in ipairs(self.pages[self.page] or {}) do
    g:text_box(
      x, y + item.y, w, item.h,
      item.text,
      { font = item.font, color = COLOR.BLACK, wrap = "word", line_gap = LINE_GAP }
    )
  end

  self:draw_page_indicator(ctx, g, self.page, #self.pages, ctx.screen.height - LAYOUT.PADDING)
end

function AboutScreen:get_title(ctx)
  return ctx.i18n:t("about.title")
end

function AboutScreen:go_back()
  self:request_screen("home", { focus_id = "about" })
end

-- there are no controls: swipes and arrow keys turn the pages on both devices
function AboutScreen:on_screen_input(ctx, ev)
  if ev.type == "pointer" then
    local offset = ev.phase == "up" and self:get_swipe_offset(ev) or nil
    if offset then
      return self:go_to_page(ctx, self.page + offset)
    end
    return false
  end

  local forward = ev.key == "down" or ev.key == "right"
  local backward = ev.key == "up" or ev.key == "left"
  if (forward or backward) and ev.phase == "down" then
    return self:go_to_page(ctx, self.page + (forward and 1 or -1))
  end
  return false
end
