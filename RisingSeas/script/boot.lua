
local PackageLoader = require 'script/lua/package_loader'
local ScriptPackageLoader = require 'script/lua/script_loader'

function init()
  PackageLoader:init()
  ScriptPackageLoader.install()
  SimpleProject = require 'core/appkit/lua/simple_project'
  Project = require 'script/lua/project'
  SimpleProject.extension_project = Project

  SimpleProject.init()
end

function shutdown()
  SimpleProject.shutdown()
end

function update(dt)
  SimpleProject.update(dt)
end

function render()
  SimpleProject.render()
end
