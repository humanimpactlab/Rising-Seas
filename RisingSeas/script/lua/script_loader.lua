

local PackageLoader = require "script/lua/package_loader"
local ScriptPackageLoader = {}

function ScriptPackageLoader.install()
  -- Stingray install a lua loader right after the preload lookup
  -- Hijack it to install our package resolving check before calling it
  local lua_loader = package.loaders[2]
  package.loaders[2] = function(modname)
    if not stingray.Application.can_get("lua", modname) then
      local pkg = PackageLoader:resolve_package(modname)
      if not PackageLoader:exist(pkg) then
        PackageLoader:load(pkg)
      end
    end
    return lua_loader(modname)
  end
end

return ScriptPackageLoader
