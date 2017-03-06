

local PackageLoader = {}

local function basic_resolver(modname)
  local pattern = '(/?.*)/(.*)'
  local head = modname
  local tail = nil
  local available = false
  while head ~= nil and not available do
    head, tail = string.match(head, pattern)
    available = stingray.Application.can_get("package", head)
  end
  return head
end

function PackageLoader:init()
  self.packages = {}
  self.resolvers = { ["basic"] = basic_resolver }
end

function PackageLoader:shutdown()
  -- TODO
end

function PackageLoader:install_resolver(key, resolver)
  -- TODO test if function
  self.resolvers[key] = resolver
end

function PackageLoader:resolve_package(resource, hint)
  -- TODO resolving rules
  if hint ~= nil then
    return self.resolvers[hint](resource)
  else
    local pkg_path;
    for _, resolver in pairs(self.resolvers) do
      pkg_path = resolver(resource)
      if pkg_path ~= nil then
        return pkg_path
      end
    end
    return pkg_path;
  end
end

function PackageLoader:is_loaded(pkg)
  -- TODO pkg handle
  local rpkg = self.packages[pkg]
  return rpkg ~= nil and stingray.ResourcePackage.has_loaded(rpkg)
end

function PackageLoader:exist(pkg)
  --TODO handle
  return self.packages[pkg] ~= nil
end

function PackageLoader:load(pkg)
  if not self.packages[pkg] then
    -- use pkg handle
    local rpkg = stingray.Application.resource_package(pkg)
    self.packages[pkg] = rpkg
    stingray.ResourcePackage.load(rpkg)
    -- TODO create coroutine for deferred flushing
    stingray.ResourcePackage.flush(rpkg)
  end
end

function PackageLoader:unload(pkg)
  -- TODO pkg handle
  local rpkg = self.packages[pkg]
  if rpkg ~= nil then
    stingray.ResourcePackage.unload(rpkg)
    stingray.Application.release_resource_package(rpkg)
    self.packages[pkg] = nil
  end
end

return PackageLoader
