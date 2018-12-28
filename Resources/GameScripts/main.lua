require "GameScripts/engine_base"
local map_tool = require "GameScripts/map"

function Start()
    SampleInitMouseMode(MM_FREE)
    map_tool.createMap()
end