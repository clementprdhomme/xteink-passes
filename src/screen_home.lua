HomeScreen = class(Screen);

function HomeScreen:init(ctx, data)
  Screen.init(self, ctx, data)

  local passes = utils["storage"].get_passes(ctx)
  local screen = #passes > 0 and "home_passes" or "home_welcome"
  self:request_screen(screen, data)
end
