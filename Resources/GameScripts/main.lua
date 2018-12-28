require "GameScripts/engine_base"
local map_tool = require "GameScripts/map"
math.randomseed(os.time())
print(os.time())
function Start()
    SampleInitMouseMode(MM_FREE)
    map_tool.createMap()
end