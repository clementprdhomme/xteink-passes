local cache = nil

local save_passes = function(ctx, passes)
  cache = { version = STORAGE.VERSION, passes = passes }
  local json = ctx.json:encode({ version = cache.version, passes = cache.passes })
  local ok, err = ctx.storage:write(STORAGE.FILE, json)
  if not ok then
    ctx.log:error("Unable to save the passes: " .. tostring(err))
  end
end

utils["storage"] = {
  load = function (ctx)
    local raw = ctx.storage:read(STORAGE.FILE)
    if type(raw) ~= "string" or #raw == 0 then
      return nil
    end

    local ok, decoded = pcall(function ()
      return ctx.json:decode(raw)
    end)

    if ok or type(decoded) == "table" then
      cache = decoded
    end
  end,
  get_passes = function(ctx)
    local passes = cache ~= nil and cache.passes or {}
    return shallow_copy(passes)
  end,
  get_pass = function(ctx, id)
    local passes = cache ~= nil and cache.passes or {}
    local pass = find_first(passes, function (row) return row.id == id end)
    return shallow_copy(pass)
  end,
  -- notes is optional
  add_pass = function(ctx, name, format, data, notes)
    local id = ctx.random:uuid()
    local passes = cache ~= nil and cache.passes or {}
    local new_passes = shallow_copy(passes)
    table.insert(new_passes, { id = id, name = name, format = format, data = data, notes = notes })
    save_passes(ctx, new_passes)
    return id
  end,
  -- notes is optional
  save_pass = function(ctx, id, name, format, data, notes)
    local passes = cache ~= nil and cache.passes or {}
    local pass, pass_index = find_first(passes, function (row) return row.id == id end)

    if pass == nil then
	    return nil
    end

    local new_passes = shallow_copy(passes)
    new_passes[pass_index] = { id = id, name = name, format = format, data = data, notes = notes }
    save_passes(ctx, new_passes)
    return id
  end,
  delete_pass = function(ctx, id)
    local passes = cache ~= nil and cache.passes or {}
    local new_passes = shallow_copy(passes)
    for i = #new_passes, 1, -1 do
      if new_passes[i].id == id then
        table.remove(new_passes, i)
      end
    end
    save_passes(ctx, new_passes)
  end,
  -- move the pass to the 1-based position, clamped to the list
  move_pass = function(ctx, id, position)
    local passes = cache ~= nil and cache.passes or {}
    local pass, pass_index = find_first(passes, function (row) return row.id == id end)

    if pass == nil then
      return nil
    end

    local new_passes = shallow_copy(passes)
    table.remove(new_passes, pass_index)
    table.insert(new_passes, math.max(1, math.min(position, #new_passes + 1)), pass)
    save_passes(ctx, new_passes)
    return id
  end
}
