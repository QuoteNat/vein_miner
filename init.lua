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

local function dig_pos(pos)

end

minetest.register_on_dignode(function(pos, oldnode, digger)
    local current_tool = digger:get_wielded_item()
    minetest.debug(current_tool:get_name())
    --if is_node_vein_diggable(oldnode.name, current_tool) then
    --    minetest.debug("Diggable")
    --end

    
end)


