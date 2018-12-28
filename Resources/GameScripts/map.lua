local map_width = 50
local map_height = 50
local max_length = 10
local min_length = 5
local map_data = {}
local map_end = {}
local max_redir = 10
local min_redir = 1
--[[ room
    x,
    y,
    w,
    h,
    door,
]]

--[[node
    pos = {x,y}, 
    dir = "d"
]]
local map_rooms = {}
local path_nodes = {}

local check_idxs = {
    u = {
        -map_width - 1, -map_width, -map_width + 1,
        -2 * map_width - 1, -2 * map_width, -2 * map_width + 1,
    },
    d = {
        map_width - 1, map_width, map_width + 1,
        2 * map_width - 1, 2 * map_width, 2 * map_width + 1,
    },
    l = {
        -map_width - 1, -map_width - 2, 
        -1, -2,
        map_width - 1, map_width - 2, 
    },
    r = {
        -map_width + 1, -map_width + 2, 
        1, 2,
        map_width + 1, map_width + 2, 
    },
}

local posToIdx = function(x, y)
    return x + y * map_width
end

local idxToPos = function(idx)
    local y = math.modf( idx / map_width )
    local x = math.fmod( idx, map_width )
    return x,y
end

local checkRoom = function(room)
    for i=1, #map_rooms do
        local corss = true
        if (map_rooms[i].x - 1) > (room.x + room.w) or (map_rooms[i].x + map_rooms[i].w) < (room.x - 1) then
            corss = false
        elseif (map_rooms[i].y - 1) > (room.y + room.h) or (map_rooms[i].y + map_rooms[i].h) < (room.y - 1) then
            corss = false
        end

        if corss then
            return false
        end
    end

    if math.fmod( room.x, 2 ) == 0 then
        return false
    end

    if math.fmod( room.y, 2 ) == 0 then
        return false
    end

    if math.fmod(room.w, 2 ) == 0 then
        return false
    end

    if math.fmod(room.h, 2 ) == 0 then
        return false
    end

    return true
end

local paintRoom = function(room, color)
    for n=0, room.w-1 do
        for m=0, room.h-1 do  
            map_data[(m + room.y) * map_width + room.x + n] = color
        end                 
    end
end

local randomRoom = function(int_trytimes)
    local cur_trytime = 0
    while cur_trytime <= int_trytimes do
        local id = #map_rooms + 1
        local width = math.random(min_length, max_length)
        local height = math.random(min_length, max_length)
        local start_x = math.random(1, map_width - width - 1)
        local start_y = math.random(1, map_height - height - 1)

        local room = {id = id, x = start_x, y = start_y, w = width, h = height}

        if checkRoom(room) then
            map_rooms[#map_rooms + 1] = room
            cur_trytime = 0
        else
            cur_trytime = cur_trytime + 1
        end
  
    end

    for i=1, #map_rooms do
        local room = map_rooms[i]
        paintRoom(room, 1)
    end
end

local checkCanMove = function(node)
    local x = node.pos[1]
    local y = node.pos[2]
    local idx = posToIdx(node.pos[1], node.pos[2])
    if y <= map_height - 2 and y >= 1 and x <= map_width - 2 and x >= 1 then
        local checkidxs = check_idxs[node.dir]
        for i=1, #checkidxs do
            if map_data[idx + checkidxs[i]] and map_data[idx + checkidxs[i]] == 1 then
                return false
            end
        end
        return true
    end
    return false
end

local moveNode = function(node)
    local randomstep = math.random(min_redir, max_redir)
    local step = 1
    if node.dir == "d" then
        while checkCanMove(node) and node.pos[2] < map_height - 2 and step <= randomstep do
            node.pos[2] = node.pos[2] + 1
            local idx = posToIdx(node.pos[1], node.pos[2])
            map_data[idx] = 1
            step = step + 1
        end
    end

    if node.dir == "u" then
        while checkCanMove(node) and node.pos[2] > 1 and step <= randomstep do
            node.pos[2] = node.pos[2] - 1
            local idx = posToIdx(node.pos[1], node.pos[2])
            map_data[idx] = 1
            step = step + 1
        end
    end

    if node.dir == "r" then
        while checkCanMove(node) and node.pos[1] < map_width - 2 and step <= randomstep do
            node.pos[1] = node.pos[1] + 1
            local idx = posToIdx(node.pos[1], node.pos[2])
            map_data[idx] = 1
            step = step + 1
        end
    end

    if node.dir == "l" then
        while checkCanMove(node) and node.pos[1] > 1 and step <= randomstep do
            node.pos[1] = node.pos[1] - 1
            local idx = posToIdx(node.pos[1], node.pos[2])
            map_data[idx] = 1
            step = step + 1
        end
    end
end

local saveMapPng = function(filename)
    
    local screenshot = Image()
    screenshot:SetSize(map_width, map_height, 4)
    for i=0, map_width * map_height - 1 do
        local color = Color(map_data[i], map_data[i], map_data[i])
        local line = math.modf( i / map_width )
        local mod = math.fmod( i, map_width ) 
        screenshot:SetPixel(mod, line, color)
    end
    
    screenshot:SavePNG(fileSystem:GetProgramDir() .. "Resources/" .. filename .. ".png")
end

local genPath = function()
    local x = 1
    local y = 1
    local stack = {}  
    local times = 0
    local lastx = 1
    local lasty = 1

    map_data[posToIdx(x, y)] = 1

    stack[#stack + 1] = {pos = {x,y}, dir = "d"}
    map_end[#map_end + 1] = {pos = {x,y}, dir = "u"}

    while #stack > 0 do
        randomhead = math.random(1, #stack)
        local node = stack[randomhead]
        table.remove(stack, randomhead)
        lastx = node.pos[1]
        lasty = node.pos[2]
  
        moveNode(node)
 
        if math.abs(lastx - node.pos[1]) >= 1 or math.abs(lasty - node.pos[2]) >= 1 then           
            stack[#stack + 1] = {pos = {node.pos[1], node.pos[2]}, dir = "r"}
            stack[#stack + 1] = {pos = {node.pos[1], node.pos[2]}, dir = "l"}
        
            stack[#stack + 1] = {pos = {node.pos[1], node.pos[2]}, dir = "d"}
            stack[#stack + 1] = {pos = {node.pos[1], node.pos[2]}, dir = "u"}
        else
            map_end[#map_end + 1] = node
        end
       
        times = times + 1
    end
end

local getRoomAroundIds = function(room)
    local idx  = {{},{},{},{}}
    local x = room.x
    local y = room.y
    local w = room.w
    local h = room.h

    for i=0, room.w-1 do
        if y >= 2 and map_data[posToIdx(x + i, y - 2)] == 1 then
            local tempidx = posToIdx(x + i, y - 1)
            local curside = idx[1]
            curside[#curside + 1] = tempidx
        end

        if y < map_height - 2 and map_data[posToIdx(x + i, y + h + 1)] == 1 then
            local tempidx = posToIdx(x + i, y + h)
            local curside = idx[2]
            curside[#curside + 1] = tempidx
        end
    end

    for i=0, room.h-1 do
        if x >= 2 and map_data[posToIdx(x - 2, y + i)] == 1 then
            local tempidx = posToIdx(x - 1, y + i)
            local curside = idx[3]
            curside[#curside + 1] = tempidx
        end

        if x < map_width - 2 and map_data[posToIdx(x + w + 1, y + i)] == 1 then
            local tempidx = posToIdx(x + w, y + i)
            local curside = idx[4]
            curside[#curside + 1] = tempidx
        end
    end
    
    return idx
end

local genDoors = function()
    for i=1, #map_rooms do
        local idxs = getRoomAroundIds(map_rooms[i])
        local doorp = 1
        local sides = {}
        for n=1, #idxs do
            local oneside = idxs[n]
            if #oneside > 0 then
                sides[#sides + 1] = oneside
                for m=1, #oneside do
                    map_data[oneside[m]] = 0
                end
            end
        end
        
        while #sides > 0 do
            local sideidx = math.random(1, #sides)
            if math.random() <= doorp then
                local door = math.random(1, #(sides[sideidx]))
                local curidx = sides[sideidx][door]
                map_data[curidx] = 1
                if not map_rooms[i].door then
                    map_rooms[i].door = {}
                end
                map_rooms[i].door[#map_rooms[i].door + 1] = door
                doorp = 0.5
            end
            table.remove( sides, sideidx)
        end
    end
end

local lookback = function(node)
   
    local dirs = {{-1, 0},{1, 0},{0,1},{0,-1}}
    local step = 0
    while true do
        local number = 0    
        local back = {0,0}
        for n=1, 4 do
            local posidx = posToIdx(node.pos[1] + dirs[n][1], node.pos[2] + dirs[n][2])
            if map_data[posidx] == 1 then
                number = number + 1
                back = {dirs[n][1], dirs[n][2]}
                
            end
        end
        
        if number == 1 then
            map_data[posToIdx(node.pos[1], node.pos[2])] = 0.3
            node.pos[1] = node.pos[1] + back[1]
            node.pos[2] = node.pos[2] + back[2]
            step = step + 1
        else 
            break 
        end
    end

    return step
end

local clearUnusePath = function()
    local check = {
        l = {{-1, 0},{0, -1}, {0, 1},},
        r = {{1, 0},{0, -1}, {0, 1},},
        u = {{0, -1},{-1, 0}, {1, 0},},
        d = {{0, 1},{-1, 0}, {1, 0},},
    }
    local lookback_nodes = {}
    
    for i=1, #map_end do
        local node = map_end[i]
        local checkpos = check[node.dir]
        local checkPass = true
       
        for n=1, #checkpos do
            local posidx = posToIdx(node.pos[1] + checkpos[n][1], node.pos[2] + checkpos[n][2])
            if map_data[posidx] == 1 then
                checkPass = false
                break
            end
        end

        

        if checkPass then
            local idx = posToIdx(map_end[i].pos[1], map_end[i].pos[2])
            --map_data[idx] = 0.8
            lookback_nodes[#lookback_nodes + 1] = node
        end
    end
    local  looptiem = 1
    while #lookback_nodes > 0 do
        local node = lookback_nodes[1]
        table.remove( lookback_nodes, 1)
        local step = lookback(node)
        if step > 1 then
            local idx = posToIdx(node.pos[1], node.pos[2])
            --map_data[idx] = 0.8
            lookback_nodes[#lookback_nodes + 1] = node
        end
    end

end

local createMap = function ( )
    for n=0, map_height * map_width - 1 do      
        map_data[n] = 0    
    end

    randomRoom(800) 
    genPath()
    genDoors()
    saveMapPng("start")
    clearUnusePath()
    saveMapPng("end")
end



return {createMap = createMap, saveMapPng = saveMapPng}