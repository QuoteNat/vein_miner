vein_miner = {
    deque = {}
}
dofile(minetest.get_modpath("vein_miner") .. "/deque.lua")

local S = minetest.get_translator("vein_miner")

-- Maximum number of nodes that can be vein mined at once
local MAX_MINED_NODES = 188

-- PERMISSIONS
-- If true, prevent registered nodes in rNodes from being veinmined.
-- If false, prevent unregistered nodes in rNodes from being veinmined.
local nodeBlacklist = false
-- Blacklisted or whitelisted nodes for veinmining
local rNodes = {}

-- Whether or not to use a blacklist instead of a whitelist for tools
local toolBlacklist = false
-- Registered tools
local rTools = {}

minetest.register_on_mods_loaded(
    function()
        -- Get settings

        -- Fetch settings
        MAX_MINED_NODES = tonumber(minetest.settings:get("vein_miner_max_nodes"))

        -- Set MAX_MINED_NODES to default value in case getting the setting doesn't work
        if MAX_MINED_NODES == nil then
            MAX_MINED_NODES = 188
        end

        local allow_ores = minetest.settings:get_bool("allow_ores", true)
        local allow_trees = minetest.settings:get_bool("allow_trees", true)
        local allow_all = minetest.settings:get_bool("allow_all", false)
        -- Initialize tool whitelist with registered tools
        for name, def in pairs(minetest.registered_tools) do
            rTools[def.name] = true
        end

        -- Initialize whitelist for registered nodes
        if allow_all then
            -- wipe rNodes just in case
            for k, v in pairs(rNodes) do
                rNodes[k] = nil
            end
            nodeBlacklist = true
        else
            if allow_ores then
                local ore_patterns = {":stone_with_", ":mineral_", "_ore$"}
                for name, def in pairs(minetest.registered_ores) do
                    local node_name = def.ore
                    for _, ore_pattern in pairs(ore_patterns) do
                        if string.match(node_name, ore_pattern) ~= nil then
                            rNodes[node_name] = true
                            break
                        end
                    end
                end
            end

            -- Register tree nodes
            if allow_trees then
                for name, def in pairs(minetest.registered_nodes) do
                    if def.groups.tree ~= nil then
                        local node_name = def.name
                        rNodes[node_name] = true
                    end
                end
            end
        end
    end
)

local function is_node_vein_diggable(nodeName, wieldedName)
    local nodeCheck = nodeBlacklist and true or false
    local toolCheck = toolBlacklist and true or false

    -- check nodes
    if next(rNodes) then
        local isNodeInRnodes = (rNodes[nodeName] ~= nil) and true or false
        nodeCheck = (isNodeInRnodes ~= nodeBlacklist)
    end

    -- check tools
    if next(rTools) then
        local isToolInRtools = (rTools[wieldedName] ~= nil) and true or false
        toolCheck = (isToolInRtools ~= toolBlacklist)
    end

    return nodeCheck and toolCheck
end

-- Recursively mines a vein of blocks
-- params:
-- * pos: mined block pos
-- * oldnode: mined node
-- * center: center of the originally mined block
-- * digger: player who mined the block
-- * mined_nodes: table containing number of mined nodes
local function dig_pos(pos, oldnode, center, digger)
    -- get current tool
    local wielded = digger:get_wielded_item()

    -- store oldnode name
    local node_name = oldnode.name

    -- create queue of positions to dig at to store nodes in
    local queue = vein_miner.deque.new()

    -- calculate durability per block
    local def = ItemStack(oldnode.name):get_definition()
    local tp = wielded:get_tool_capabilities()
    local dp = minetest.get_dig_params(def.groups, tp)
    local wear_limit = 65535 - dp.wear
    local mined_nodes = 0

    if wielded:get_wear() >= wear_limit then
        minetest.chat_send_player(digger:get_player_name(), S("Tool does not have enough durability to mine this vein"))
    end

    -- add pos to queue
    queue:push_right(pos)
    while not queue:is_empty() and wielded:get_wear() < wear_limit and mined_nodes < MAX_MINED_NODES do
        -- Pop left-most item
        local pos = queue:pop_left()
        -- Find adjacent nodes to dug node
        local minvec = vector.offset(pos, -1, -1, -1)
        local maxvec = vector.offset(pos, 1, 1, 1)
        local adjacent_nodes = minetest.find_nodes_in_area(minvec, maxvec, node_name, true)

        -- Get drops for mined node
        local drops = minetest.get_node_drops(node_name, wielded)

        -- Dig found nodes
        for k, node in pairs(adjacent_nodes) do
            for index, pos in pairs(node) do
                if wielded:get_wear() < wear_limit then
                    -- add drops to inventory or drop them if inventory is full
                    minetest.handle_node_drops(pos, drops, digger)
                    -- remove the mined node
                    minetest.remove_node(pos)
                    -- add pos to queue
                    queue:push_right(pos)
                    -- add wear to wielded tool
                    wielded:add_wear(dp.wear)
                    mined_nodes = mined_nodes + 1
                end
            end
        end
    end
    -- Update wielded item
    digger:set_wielded_item(wielded)
end

minetest.register_on_dignode(
    function(pos, oldnode, digger)
        if digger ~= nil and oldnode ~= nil and pos ~= nil then
            local wielded = digger:get_wielded_item()
            local mined_nodes = {value = 1}

            -- start vein mining
            if digger:get_player_control().sneak and is_node_vein_diggable(oldnode.name, wielded:get_name()) then
                dig_pos(pos, oldnode, pos, digger, mined_nodes)
            end
        end
    end
)

