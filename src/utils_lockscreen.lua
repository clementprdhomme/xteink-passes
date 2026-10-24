-- the pass shown on the lock screen: its id is kept in ctx.state, which the lock-screen session (lockscreen.lua) reads
-- ctx.lockscreen only exists in the main program
utils["lockscreen"] = {
  -- id of the pass chosen for the lock screen, or nil
  get_pass_id = function(ctx)
    return ctx.state.lockscreen_pass_id
  end,

  -- whether the pass is on the lock screen: chosen, and the app is still the lock screen, since the user can pick
  -- another one in the system settings without the app being told
  is_shown = function(ctx, id)
    return ctx.state.lockscreen_pass_id == id and ctx.lockscreen:is_default()
  end,

  -- choose the pass; the first time, the system asks the user to confirm that the app becomes the lock screen
  show = function(ctx, id)
    ctx.state.lockscreen_pass_id = id
    ctx:save_state()
    if ctx.lockscreen:is_default() then
      utils["dialog"].toast(ctx, ctx.i18n:t("lockscreen.shown"))
    else
      ctx.lockscreen:set_default()
    end
  end,

  -- forget the pass and give the lock screen back to the one the user had before
  remove = function(ctx)
    ctx.state.lockscreen_pass_id = nil
    ctx:save_state()
    ctx.lockscreen:clear_default()
  end,
}
