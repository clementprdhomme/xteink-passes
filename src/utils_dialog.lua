-- the system dialogs, with their texts cut to the byte limits (a longer text isn't shown at all), and the dialogs that
-- more than one screen opens
utils["dialog"] = {
  toast = function(ctx, text)
    ctx.dialog:toast(utils["text"].truncate_bytes(text, DIALOG.TOAST_MAX_BYTES))
  end,

  -- opts: title, message, ok_text
  confirm = function(ctx, opts, on_close)
    ctx.dialog:confirm({
      title = utils["text"].truncate_bytes(opts.title, DIALOG.CONFIRM_TITLE_MAX_BYTES),
      message = opts.message and utils["text"].truncate_bytes(opts.message, DIALOG.CONFIRM_MESSAGE_MAX_BYTES) or nil,
      ok_text = opts.ok_text and utils["text"].truncate_bytes(opts.ok_text, DIALOG.BUTTON_MAX_BYTES) or nil,
    }, on_close)
  end,

  -- opts: title, items (labels); the documentation gives no limit for the title, so it's cut like a confirm's
  choose = function(ctx, opts, on_close)
    local items = {}
    for i, label in ipairs(opts.items) do
      items[i] = utils["text"].truncate_bytes(label, DIALOG.BUTTON_MAX_BYTES)
    end
    ctx.dialog:choose({
      title = utils["text"].truncate_bytes(opts.title, DIALOG.CONFIRM_TITLE_MAX_BYTES),
      items = items,
    }, on_close)
  end,

  -- ask for confirmation, then delete the pass and call on_deleted(ctx, neighbour_id) with the id of the pass that
  -- takes its place in the list (the next one, else the previous one), or nil if the list is now empty
  confirm_delete = function(ctx, id, on_deleted)
    utils["dialog"].confirm(ctx, {
      title = ctx.i18n:t("delete.title"),
      message = ctx.i18n:t("delete.message"),
      ok_text = ctx.i18n:t("delete.ok"),
    }, function (ctx, ok)
      if ok then
        local passes = utils["storage"].get_passes(ctx)
        local _, index = find_first(passes, function (row) return row.id == id end)
        local neighbour = index and (passes[index + 1] or passes[index - 1]) or nil

        -- a deleted pass can't stay on the lock screen, so the lock screen goes back to the user's previous one
        if utils["lockscreen"].get_pass_id(ctx) == id then
          utils["lockscreen"].remove(ctx)
        end
        utils["storage"].delete_pass(ctx, id)
        on_deleted(ctx, neighbour and neighbour.id or nil)
      end
    end)
  end,
}
