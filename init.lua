local function is_node_vein_diggable(nodeName, current_tool)
    local caps = current_tool:get_tool_capabilities()
    local nodeGroups = minetest.registered_nodes[nodeName].groups
    local test = minetest.get_dig_params(nodeGroups, caps)

    return test["diggable"]
end

minetest.register_on_dignode(function(pos, node, digger)
    local current_tool = digger:get_wielded_item()
    minetest.debug(current_tool:get_name())
    if is_node_vein_diggable(node.name, current_tool) then
        minetest.debug("Diggable")
    end
end)