-- This file was automatically generated for the LuaDist project.

package = "kong-plugin-param-transformer"
version = "0.1.1-1"
-- LuaDist source
source = {
  tag = "0.1.1-1",
  url = "git://github.com/LuaDist-testing/kong-plugin-param-transformer.git"
}
-- Original source
-- source = {
--    url = "git://github.com/Kong-Study-Group/kong-plugin-param-transformer",
--    tag = "0.1.1"
-- }
description = {
   summary = "I can transfor param into upstream.",
   detailed = "I can transfor param into upstream.",
   homepage = "https://github.com/Kong-Study-Group/kong-plugin-param-transformer",
   license = "MIT"
}
dependencies = {}
build = {
   type = "builtin",
   modules = {
      ["kong.plugins.param-transformer.handler"] = "kong/plugins/param-transformer/handler.lua",
      ["kong.plugins.param-transformer.schema"] = "kong/plugins/param-transformer/schema.lua",
   }
}