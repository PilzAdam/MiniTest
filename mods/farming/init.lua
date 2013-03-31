farming = {}

function farming:add_plant(full_grown, names, interval, chance)
	minetest.register_abm({
		nodenames = names,
		interval = interval,
		chance = chance,
		action = function(pos, node)
			pos.y = pos.y-1
			if minetest.env:get_node(pos).name ~= "farming:soil_wet" then
				return
			end
			pos.y = pos.y+1
			if not minetest.env:get_node_light(pos) then
				return
			end
			if minetest.env:get_node_light(pos) < 8 then
				return
			end
			local step = nil
			for i,name in ipairs(names) do
				if name == node.name then
					step = i
					break
				end
			end
			if step == nil then
				return
			end
			local new_node = {name=names[step+1]}
			if new_node.name == nil then
				new_node.name = full_grown
			end
			minetest.env:set_node(pos, new_node)
		end
}	)
end

function farming:generate_tree(pos, trunk, leaves, underground, replacements)
	pos.y = pos.y-1
	local nodename = minetest.env:get_node(pos).name
	local ret = true
	for _,name in ipairs(underground) do
		if nodename == name then
			ret = false
			break
		end
	end
	pos.y = pos.y+1
	if not minetest.env:get_node_light(pos) then
		return
	end
	if ret or minetest.env:get_node_light(pos) < 8 then
		return
	end
	
	node = {name = ""}
	for dy=1,4 do
		pos.y = pos.y+dy
		if minetest.env:get_node(pos).name ~= "air" then
			return
		end
		pos.y = pos.y-dy
	end
	node.name = trunk
	for dy=0,4 do
		pos.y = pos.y+dy
		minetest.env:set_node(pos, node)
		pos.y = pos.y-dy
	end
	
	if not replacements then
		replacements = {}
	end
	
	node.name = leaves
	pos.y = pos.y+3
	for dx=-2,2 do
		for dz=-2,2 do
			for dy=0,3 do
				pos.x = pos.x+dx
				pos.y = pos.y+dy
				pos.z = pos.z+dz
				
				if dx == 0 and dz == 0 and dy==3 then
					if minetest.env:get_node(pos).name == "air" and math.random(1, 5) <= 4 then
						minetest.env:set_node(pos, node)
						for name,rarity in pairs(replacements) do
							if math.random(1, rarity) == 1 then
								minetest.env:set_node(pos, {name=name})
							end
						end
					end
				elseif dx == 0 and dz == 0 and dy==4 then
					if minetest.env:get_node(pos).name == "air" and math.random(1, 5) <= 4 then
						minetest.env:set_node(pos, node)
						for name,rarity in pairs(replacements) do
							if math.random(1, rarity) == 1 then
								minetest.env:set_node(pos, {name=name})
							end
						end
					end
				elseif math.abs(dx) ~= 2 and math.abs(dz) ~= 2 then
					if minetest.env:get_node(pos).name == "air" then
						minetest.env:set_node(pos, node)
						for name,rarity in pairs(replacements) do
							if math.random(1, rarity) == 1 then
								minetest.env:set_node(pos, {name=name})
							end
						end
					end
				else
					if math.abs(dx) ~= 2 or math.abs(dz) ~= 2 then
						if minetest.env:get_node(pos).name == "air" and math.random(1, 5) <= 4 then
							minetest.env:set_node(pos, node)
							for name,rarity in pairs(replacements) do
								if math.random(1, rarity) == 1 then
								minetest.env:set_node(pos, {name=name})
								end
							end
						end
					end
				end
				
				pos.x = pos.x-dx
				pos.y = pos.y-dy
				pos.z = pos.z-dz
			end
		end
	end
end

farming.seeds = {
	["farming:wheat_seed"]=20,
	["farming:cotton_seed"]=30,
	["farming:pumpkin_seed"]=60,
}

-- ========= ALIASES FOR FARMING MOD BY SAPIER =========
-- hoes
minetest.register_alias("farming:wood_hoe", "farming:hoe_wood")
minetest.register_alias("farming:cobble_hoe", "farming:hoe_stone")
minetest.register_alias("farming:steel_hoe", "farming:hoe_steel")
minetest.register_alias("farming:mese_hoe", "farming:hoe_steel")

-- wheat -> wheat
minetest.register_alias("farming:wheat_node", "farming:wheat")
--minetest.register_alias("farming:wheat", "farming_wheat_harvested") cant do this
minetest.register_alias("farming:wheat_straw", "farming:wheat")
minetest.register_alias("farming:seed_wheat", "farming:wheat_seed")
for lvl = 1, 6, 1 do
	minetest.register_entity(":farming:wheat_lvl"..lvl, {
		on_activate = function(self, staticdata)
			minetest.env:set_node(self.object:getpos(), {name="farming:wheat_1"})
		end
	})
end

-- rye -> wheat
minetest.register_alias("farming:rhy_node", "farming:wheat")
minetest.register_alias("farming:rhy", "farming:wheat_harvested")
minetest.register_alias("farming:rhy_straw", "farming:wheat")
minetest.register_alias("farming:seed_rhy", "farming:wheat_seed")
for lvl = 1, 6, 1 do
	minetest.register_entity(":farming:rhy_lvl"..lvl, {
		on_activate = function(self, staticdata)
			minetest.env:set_node(self.object:getpos(), {name="farming:wheat_1"})
		end
	})
end

-- corn -> wheat
minetest.register_alias("farming:corn_node", "farming:wheat")
minetest.register_alias("farming:corn", "farming:wheat_harvested")
minetest.register_alias("farming:corn_straw", "farming:wheat")
minetest.register_alias("farming:seed_corn", "farming:wheat_seed")
for lvl = 1, 6, 1 do
	minetest.register_entity(":farming:corn_lvl"..lvl, {
		on_activate = function(self, staticdata)
			minetest.env:set_node(self.object:getpos(), {name="farming:wheat_1"})
		end
	})
end


-- ========= SOIL =========
dofile(minetest.get_modpath("farming").."/soil.lua")

-- ========= HOES =========
dofile(minetest.get_modpath("farming").."/hoes.lua")

-- ========= CORN =========
dofile(minetest.get_modpath("farming").."/wheat.lua")

-- ========= COTTON =========
dofile(minetest.get_modpath("farming").."/cotton.lua")

-- ========= PUMPKIN =========
dofile(minetest.get_modpath("farming").."/pumpkin.lua")

-- ========= WEED =========
dofile(minetest.get_modpath("farming").."/weed.lua")

if minetest.setting_get("log_mods") then
	minetest.log("action", "farming loaded")
end
