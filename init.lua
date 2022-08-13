vein_miner = {}
-- Max distance from original veinmined node that can be vein mined
MAX_VEIN_MINE_OFFSET = 5

--local function is_node_vein_diggable(nodeName, wielded[1])
	-- -- Get the current tools capabilities
--	local caps = wielded[1]:get_tool_capabilities()
	-- -- Get the groups for the current node
--	local nodeGroups = minetest.registered_nodes[nodeName].groups
	-- -- Test if the current tool can dig the node
	--local test = minetest.get_dig_params(nodeGroups, caps)
	-- -- Return if the node is diggable
	--return test.diggable
--end

--local calc_wear(block_groups
local function dig_pos(pos, oldnode, center, digger)
	local wielded = digger:get_wielded_item()
	-- store oldnode name
	local node_name = oldnode.name
	-- Find adjacent nodes to dug node
	local minvec = vector.offset(pos, -1, -1, -1)
	local maxvec = vector.offset(pos, 1, 1, 1)
	local adjacent_nodes = minetest.find_nodes_in_area(minvec, maxvec, node_name, true)
	local drops = minetest.get_node_drops(node_name, wielded)
	-- calculate durability per block
	-- local test = ItemStack(ItemStack|itemstring|table|nil)
	local def = ItemStack(oldnode.name):get_definition()
	local wdef = wielded:get_definition()
	local tp = wielded:get_tool_capabilities()
	local groups = ""
	for k,v in pairs(def.groups) do
		groups = groups .. k .. v	
	end
	local dp = minetest.get_dig_params(def.groups, tp)
	-- Dig found nodes
	for k, node in pairs(adjacent_nodes) do
		for index, pos in pairs(node) do
			--            minetest.dig_node(pos)
			minetest.handle_node_drops(pos, drops, digger) 
			minetest.remove_node(pos)
			wielded:add_wear(dp.wear)
		end
	end
	digger:set_wielded_item(wielded)
	-- Attempt to find more nodes adjacent to the already dug nodes
	for k, node in pairs(adjacent_nodes) do
		for index, pos in pairs(node) do
			if vector.distance(pos, center) <= MAX_VEIN_MINE_OFFSET then
				dig_pos(pos, oldnode, center, digger)
			end
		end
	end
end

minetest.register_on_dignode(function(pos, oldnode, digger)
	local wielded = digger:get_wielded_item()

	-- start vein mining
	if digger:get_player_control().sneak and wielded ~= nil then
		dig_pos(pos, oldnode, pos, digger)
	end
end)

