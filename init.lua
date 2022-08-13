vein_miner = {}
-- Maximum number of nodes that can be vein mined at once
MAX_MINED_NODES = 188

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

-- Recursively mines a vein of blocks
-- params:
-- * pos: mined block pos
-- * oldnode: mined node
-- * center: center of the originally mined block
-- * digger: player who mined the block
local function dig_pos(pos, oldnode, center, digger, mined_nodes)
	-- get current tool
	local wielded = digger:get_wielded_item()

	-- store oldnode name
	local node_name = oldnode.name

	-- Find adjacent nodes to dug node
	local minvec = vector.offset(pos, -1, -1, -1)
	local maxvec = vector.offset(pos, 1, 1, 1)
	local adjacent_nodes = minetest.find_nodes_in_area(minvec, maxvec, node_name, true)

	-- Get drops for mined node
	local drops = minetest.get_node_drops(node_name, wielded)

	-- calculate durability per block
	local def = ItemStack(oldnode.name):get_definition()
	local tp = wielded:get_tool_capabilities()
	local dp = minetest.get_dig_params(def.groups, tp)

	-- Dig found nodes
	for k, node in pairs(adjacent_nodes) do
		for index, pos in pairs(node) do
			-- add drops to inventory or drop them if inventory is full
			minetest.handle_node_drops(pos, drops, digger) 
			-- remove the mined node
			minetest.remove_node(pos)
			-- add wear to wielded tool
			wielded:add_wear(dp.wear)
			mined_nodes["value"] = mined_nodes["value"] + 1
			minetest.debug(mined_nodes["value"])
		end
	end

	-- Update wielded item
	digger:set_wielded_item(wielded)

	-- Attempt to find more nodes adjacent to the already dug nodes
	for k, node in pairs(adjacent_nodes) do
		for index, pos in pairs(node) do
			if mined_nodes["value"] <= MAX_MINED_NODES then
				dig_pos(pos, oldnode, center, digger, mined_nodes)
			end
		end
	end
end

minetest.register_on_dignode(function(pos, oldnode, digger)
	local wielded = digger:get_wielded_item()
	local mined_nodes = { value=1 }

	-- start vein mining
	if digger:get_player_control().sneak and wielded ~= nil then
		dig_pos(pos, oldnode, pos, digger, mined_nodes)
	end
end)

