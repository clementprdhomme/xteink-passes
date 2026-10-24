-- copy a table shallowly
function shallow_copy(t)
  local copy = {}
  for k, v in pairs(t) do
    copy[k] = v
  end
  return copy
end

-- find table row matching the condition
function find_first(t, cond)
  for i, row in ipairs(t) do
    if cond(row) then
      return row, i
    end
  end
  return nil
end

-- build a new class table; `Super` (optional) becomes its parent, so methods are inherited through the metatable chain
local function new_class(Super)
  local Class = {}
  Class.__index = Class
  Class.__super = Super

  if Super then
    setmetatable(Class, { __index = Super })
  end

  -- create an instance; constructor(...) is called when the class defines one
  Class.new = function(self, ...)
    local instance = setmetatable({}, self)
    if instance.constructor then
      instance:constructor(...)
    end
    return instance
  end

  -- walk the inheritance chain to test whether an object is a kind of cls
  Class.is_a = function(self, cls)
    local meta = getmetatable(self)
    while meta do
      if meta == cls then
        return true
      end
      meta = meta.__super
    end
    return false
  end

  return Class
end

class = {}
class.new = new_class

-- allow both class() and class(Super)
setmetatable(class, {
  __call = function(_, Super)
    return new_class(Super)
  end
})
