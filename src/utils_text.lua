local function get_line_height(font, text)
  local _, height = font:layout(text:match("^[^\n]*"), 8192, 8192, { wrap = "none" })
  return math.max(font.line_height, height)
end

utils["text"] = {
  -- height of one line of text in a font: it can be more than font.line_height, because a system font without Chinese,
  -- Japanese and Korean characters (small on the X4) draws a text that has some in the medium font
  get_line_height = get_line_height,

  -- height of the tallest line a font can draw, for room kept for a text not known yet (a user's text can be in any
  -- language)
  get_max_line_height = function(font)
    return get_line_height(font, "\u{56FD}")
  end,

  -- cut text to at most max_bytes bytes without splitting a character, ending it with "…" when cut
  truncate_bytes = function(text, max_bytes)
    if #text <= max_bytes then
      return text
    end
    local ellipsis = "…"
    local cut = utf8.offset(text, 0, max_bytes - #ellipsis + 1) - 1
    return text:sub(1, cut) .. ellipsis
  end,
}
