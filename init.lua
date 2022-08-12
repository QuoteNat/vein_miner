vein_miner = {}

local function is_node_vein_diggable(nodeName, current_tool)
    -- -- Get the current tools capabilities
    local caps = current_tool:get_tool_capabilities()
    -- -- Get the groups for the current node
    local nodeGroups = minetest.registered_nodes[nodeName].groups
    -- -- Test if the current tool can dig the node
    local test = minetest.get_dig_params(nodeGroups, caps)
    -- -- Return if the node is diggable
    return test.diggable
end

local function dig_pos(pos, oldnode)
    -- store oldnode name
    local node_name = oldnode.name
    local mine_list
    -- Find adjacent nodes to dug node
    local minvec = vector.offset(pos, -1, -1, -1)
    local maxvec = vector.offset(pos, 1, 1, 1)
    minetest.debug(node_name .. " from " .. tostring(minvec) .. " to " .. tostring(maxvec))

    local adjacent_nodes = minetest.find_nodes_in_area(minvec, maxvec, node_name, true)

    for k, node in pairs(adjacent_nodes) do
        for index, pos in pairs(node) do
            minetest.debug(k .. tostring(pos))
        end
    end
end

minetest.register_on_dignode(function(pos, oldnode, digger)
    local current_tool = digger:get_wielded_item()
    --if is_node_vein_diggable(oldnode.name, current_tool) then
    --    minetest.debug("Diggable")
    --end
    
    -- start vein mining
    if digger:get_player_control().sneak and current_tool ~= nil then
        dig_pos(pos, oldnode)
    end
end)

