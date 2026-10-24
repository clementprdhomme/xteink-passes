FormScreen = class(Screen);

function FormScreen:init(ctx, data)
  data = data or {}

  -- apply the default values
  local defaults = { format = PASS.FORMATS[1].key }
  local fields = self:get_fields(ctx, data)
  for i = 2, #fields, 1 do
    local key = fields[i].key
    data[key] = data[key] or defaults[key]
  end

  Screen.init(self, ctx, data)

  self.initial_focus = data.focus_field
  data.focus_field = nil
end

function FormScreen:get_fields(ctx, data)
  return {
    {
      key = "name",
      label = ctx.i18n:t("form.field.name"),
      value = self.data and self.data.name or nil,
      action_screen = "form_text",
    },
    {
      key = "format",
      label = ctx.i18n:t("form.field.format"),
      value = self.data and self.data.format or nil,
      action_screen = "form_format",
    },
    {
      key = "data",
      label = ctx.i18n:t("form.field.data"),
      value = self.data and self.data.data or nil,
      action_screen = "form_text",
    },
    {
      key = "notes",
      label = ctx.i18n:t("form.field.notes"),
      value = self.data and self.data.notes or nil,
      action_screen = "form_text",
      optional = true,
    },
  }
end

function FormScreen:get_pretty_value(ctx, field_key, field_value)
    if field_key == "format" then
      local format = find_first(PASS.FORMATS, function (row) return row.key == field_value end)
      return format and ctx.i18n:t(format.label) or field_value
    end
    return field_value
end

function FormScreen:get_field_box(ctx, index)
  local field_offset = ctx.fonts.medium.line_height + 8
  local field_height = field_offset + BUTTON.SIZE + LAYOUT.PADDING
  local x = LAYOUT.PADDING
  local y = LAYOUT.CONTENT_TOP + field_offset + (index - 1) * field_height
  return x, y, ctx.screen.width - 2 * LAYOUT.PADDING, BUTTON.SIZE
end

function FormScreen:create_controls(ctx)
  local fields = self:get_fields(ctx, self.data)
  local controls = {}

  for i, field in ipairs(fields) do
    local x, y, w, h = self:get_field_box(ctx, i)
    table.insert(controls, ControlFormRow:new({
      id = field.key,
      x = x, y = y, w = w, h = h,
      label = field.label,
      value = self:get_pretty_value(ctx, field.key, field.value),
      icon = field.key == "format" and field.value and field.value .. "-sm" or nil,
      on_activate = function (ctx) self:activate_field(ctx, field) end,
    }))
  end

  table.insert(controls, ControlButton:new({
    id = "create",
    x = LAYOUT.PADDING, y = ctx.screen.height - LAYOUT.PADDING - BUTTON.SIZE,
    w = ctx.screen.width - 2 * LAYOUT.PADDING, h = BUTTON.SIZE,
    label = ctx.i18n:t(self.data.id and "form.save" or "form.create"),
    on_activate = function (ctx) self:create_pass(ctx, self:get_fields(ctx, self.data)) end,
  }))

  return controls
end

function FormScreen:get_initial_focus(ctx)
  return self.initial_focus
end

function FormScreen:get_title(ctx)
  return ctx.i18n:t(self.data.id and "form.title_edit" or "form.title_new")
end

function FormScreen:go_back()
  if self.data.back_screen then
    self:request_screen(self.data.back_screen, { focus_id = self.data.id })
  elseif self.data.id then
    self:request_screen("pass", { id = self.data.id })
  else
    -- back to the button that opened the form
    self:request_screen("home", { focus_id = "create" })
  end
end

function FormScreen:activate_field(ctx, field)
  -- remember which field is being opened so the focus comes back to it on return
  self.data.focus_field = field.key

  local data = {
    field = field,
    data = shallow_copy(self.data)
  }
  self:request_screen(field.action_screen, data)
end

function FormScreen:create_pass(ctx, fields)
  local is_incomplete = find_first(fields, function (row) return not row.value and not row.optional end)
  local data_error = not is_incomplete and utils["codes"].get_data_error(ctx, self.data.format, self.data.data) or nil
  if is_incomplete then
    utils["dialog"].toast(ctx, ctx.i18n:t(self.data.id and "form.incomplete_save" or "form.incomplete_create"))
  elseif data_error then
    utils["dialog"].toast(ctx, data_error)
  else
    if self.data.id then
      utils["storage"].save_pass(ctx, self.data.id, self.data.name, self.data.format, self.data.data, self.data.notes)
      self:request_screen("pass", { id = self.data.id })
    else
      local id = utils["storage"].add_pass(ctx, self.data.name, self.data.format, self.data.data, self.data.notes)
      self:request_screen("pass", { id = id })
    end
  end
end
