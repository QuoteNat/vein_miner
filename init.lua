vein_miner = {}
vein_miner.ore_content_ids = {}
vein_miner.stone_content_ids = {}

local function is_node_vein_diggable(nodeName)
    -- -- Get the current tools capabilities
    -- local caps = current_tool:get_tool_capabilities()
    -- -- Get the groups for the current node
    -- local nodeGroups = minetest.registered_nodes[nodeName].groups
    -- -- Test if the current tool can dig the node
    -- local test = minetest.get_dig_params(nodeGroups, caps)
    -- -- Return if the node is diggable

    -- Check if the mined node is a registered ore
    local node_id = minetest.get_content_id(nodeName)
    if vein_miner.ore_content_ids[node_id] then 
        return true 
    else 
        return false 
    end
end

minetest.register_on_dignode(function(pos, oldnode, digger)
    local current_tool = digger:get_wielded_item()
    minetest.debug(current_tool:get_name())
    if is_node_vein_diggable(oldnode.name) then
        minetest.debug("Diggable")
    end
end)

-- From ore cutting mod
-- https://github.com/minetest-mods/orecutting/blob/master/init.lua
minetest.after(0, function ()
	for _, ore in pairs(minetest.registered_ores) do
		if ore.wherein and ore.ore_type == "scatter" then
			local id = minetest.get_content_id(ore.ore)
			vein_miner.ore_content_ids[id] = ore.ore
			if type(ore.wherein) == "table" then
				for _, v in ipairs(ore.wherein) do
					id = minetest.get_content_id(v)
					vein_miner.stone_content_ids[id] = v
				end
			else
				id = minetest.get_content_id(ore.wherein)
				vein_miner.stone_content_ids[id] = ore.wherein
			end
		end
	end
end)