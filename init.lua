vein_miner = {}
-- Max distance from original veinmined node that can be vein mined
MAX_VEIN_MINE_OFFSET = 5

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

local function dig_pos(pos, oldnode, center, current_tool, digger)
    -- store oldnode name
    local node_name = oldnode.name
    local mine_list
    -- Find adjacent nodes to dug node
    local minvec = vector.offset(pos, -1, -1, -1)
    local maxvec = vector.offset(pos, 1, 1, 1)
    local adjacent_nodes = minetest.find_nodes_in_area(minvec, maxvec, node_name, true)
    local drops = minetest.get_node_drops(node_name, current_tool)

    -- Dig found nodes
    for k, node in pairs(adjacent_nodes) do
        for index, pos in pairs(node) do
--            minetest.dig_node(pos)
           minetest.handle_node_drops(pos, drops, digger) 
           minetest.remove_node(pos)
        end
    end

    -- Attempt to find more nodes adjacent to the already dug nodes
     for k, node in pairs(adjacent_nodes) do
        for index, pos in pairs(node) do
            if vector.distance(pos, center) <= MAX_VEIN_MINE_OFFSET then
                dig_pos(pos, oldnode, center)
            end
        end
    end
end

minetest.register_on_dignode(function(pos, oldnode, digger)
    local current_tool = digger:get_wielded_item()
    
    -- start vein mining
    if digger:get_player_control().sneak and current_tool ~= nil then
        dig_pos(pos, oldnode, pos, current_tool, digger)
    end
end)

