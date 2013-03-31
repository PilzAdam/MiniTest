-- minetest/default/mapgen.lua

--
-- Aliases for map generator outputs
--

minetest.register_alias("mapgen_air", "air")
minetest.register_alias("mapgen_stone", "minitest:stone")
minetest.register_alias("mapgen_tree", "minitest:tree")
minetest.register_alias("mapgen_leaves", "minitest:leaves")
minetest.register_alias("mapgen_jungletree", "minitest:jungletree")
minetest.register_alias("mapgen_jungleleaves", "minitest:jungleleaves")
minetest.register_alias("mapgen_apple", "minitest:apple")
minetest.register_alias("mapgen_water_source", "minitest:water_source")
minetest.register_alias("mapgen_dirt", "minitest:dirt")
minetest.register_alias("mapgen_sand", "minitest:sand")
minetest.register_alias("mapgen_gravel", "minitest:gravel")
minetest.register_alias("mapgen_clay", "minitest:clay")
minetest.register_alias("mapgen_lava_source", "minitest:lava_source")
minetest.register_alias("mapgen_cobble", "minitest:cobble")
minetest.register_alias("mapgen_mossycobble", "minitest:mossycobble")
minetest.register_alias("mapgen_dirt_with_grass", "minitest:dirt_with_grass")
minetest.register_alias("mapgen_junglegrass", "minitest:junglegrass")
minetest.register_alias("mapgen_stone_with_coal", "minitest:stone_with_coal")
minetest.register_alias("mapgen_stone_with_iron", "minitest:stone_with_iron")
minetest.register_alias("mapgen_desert_sand", "minitest:sand")
minetest.register_alias("mapgen_desert_stone", "minitest:sandstone")

--
-- Ore generation
--

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "minitest:stone_with_coal",
	wherein        = "minitest:stone",
	clust_scarcity = 8*8*8,
	clust_num_ores = 8,
	clust_size     = 3,
	height_min     = -31000,
	height_max     = 64,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "minitest:stone_with_coal",
	wherein        = "minitest:stone",
	clust_scarcity = 24*24*24,
	clust_num_ores = 27,
	clust_size     = 6,
	height_min     = -31000,
	height_max     = 0,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "minitest:stone_with_iron",
	wherein        = "minitest:stone",
	clust_scarcity = 12*12*12,
	clust_num_ores = 3,
	clust_size     = 2,
	height_min     = -15,
	height_max     = 2,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "minitest:stone_with_iron",
	wherein        = "minitest:stone",
	clust_scarcity = 9*9*9,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = -63,
	height_max     = -16,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "minitest:stone_with_iron",
	wherein        = "minitest:stone",
	clust_scarcity = 7*7*7,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = -31000,
	height_max     = -64,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "minitest:stone_with_iron",
	wherein        = "minitest:stone",
	clust_scarcity = 24*24*24,
	clust_num_ores = 27,
	clust_size     = 6,
	height_min     = -31000,
	height_max     = -64,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "minitest:stone_with_gold",
	wherein        = "minitest:stone",
	clust_scarcity = 15*15*15,
	clust_num_ores = 3,
	clust_size     = 2,
	height_min     = -255,
	height_max     = -64,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "minitest:stone_with_gold",
	wherein        = "minitest:stone",
	clust_scarcity = 13*13*13,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = -31000,
	height_max     = -256,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "minitest:stone_with_diamond",
	wherein        = "minitest:stone",
	clust_scarcity = 17*17*17,
	clust_num_ores = 4,
	clust_size     = 3,
	height_min     = -255,
	height_max     = -128,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "minitest:stone_with_diamond",
	wherein        = "minitest:stone",
	clust_scarcity = 15*15*15,
	clust_num_ores = 4,
	clust_size     = 3,
	height_min     = -31000,
	height_max     = -256,
})

function default.generate_ore(name, wherein, minp, maxp, seed, chunks_per_volume, chunk_size, ore_per_chunk, height_min, height_max)
	minetest.log('action', "WARNING: default.generate_ore is deprecated")

	if maxp.y < height_min or minp.y > height_max then
		return
	end
	local y_min = math.max(minp.y, height_min)
	local y_max = math.min(maxp.y, height_max)
	if chunk_size >= y_max - y_min + 1 then
		return
	end
	local volume = (maxp.x-minp.x+1)*(y_max-y_min+1)*(maxp.z-minp.z+1)
	local pr = PseudoRandom(seed)
	local num_chunks = math.floor(chunks_per_volume * volume)
	local inverse_chance = math.floor(chunk_size*chunk_size*chunk_size / ore_per_chunk)
	--print("generate_ore num_chunks: "..dump(num_chunks))
	for i=1,num_chunks do
		local y0 = pr:next(y_min, y_max-chunk_size+1)
		if y0 >= height_min and y0 <= height_max then
			local x0 = pr:next(minp.x, maxp.x-chunk_size+1)
			local z0 = pr:next(minp.z, maxp.z-chunk_size+1)
			local p0 = {x=x0, y=y0, z=z0}
			for x1=0,chunk_size-1 do
			for y1=0,chunk_size-1 do
			for z1=0,chunk_size-1 do
				if pr:next(1,inverse_chance) == 1 then
					local x2 = x0+x1
					local y2 = y0+y1
					local z2 = z0+z1
					local p2 = {x=x2, y=y2, z=z2}
					if minetest.env:get_node(p2).name == wherein then
						minetest.env:set_node(p2, {name=name})
					end
				end
			end
			end
			end
		end
	end
	--print("generate_ore done")
end

function default.make_papyrus(pos, size)
	for y=0,size-1 do
		local p = {x=pos.x, y=pos.y+y, z=pos.z}
		local nn = minetest.env:get_node(p).name
		if minetest.registered_nodes[nn] and
			minetest.registered_nodes[nn].buildable_to then
			minetest.env:set_node(p, {name="minitest:papyrus"})
		else
			return
		end
	end
end

function default.make_cactus(pos, size)
	for y=0,size-1 do
		local p = {x=pos.x, y=pos.y+y, z=pos.z}
		local nn = minetest.env:get_node(p).name
		if minetest.registered_nodes[nn] and
			minetest.registered_nodes[nn].buildable_to then
			minetest.env:set_node(p, {name="minitest:cactus"})
		else
			return
		end
	end
end

-- facedir: 0/1/2/3 (head node facedir value)
-- length: length of rainbow tail
function default.make_nyancat(pos, facedir, length)
	local tailvec = {x=0, y=0, z=0}
	if facedir == 0 then
		tailvec.z = 1
	elseif facedir == 1 then
		tailvec.x = 1
	elseif facedir == 2 then
		tailvec.z = -1
	elseif facedir == 3 then
		tailvec.x = -1
	else
		print("default.make_nyancat(): Invalid facedir: "+dump(facedir))
		facedir = 0
		tailvec.z = 1
	end
	local p = {x=pos.x, y=pos.y, z=pos.z}
	minetest.env:set_node(p, {name="minitest:nyancat", param2=facedir})
	for i=1,length do
		p.x = p.x + tailvec.x
		p.z = p.z + tailvec.z
		minetest.env:set_node(p, {name="minitest:nyancat_rainbow"})
	end
end

function generate_nyancats(seed, minp, maxp)
	local height_min = -31000
	local height_max = -32
	if maxp.y < height_min or minp.y > height_max then
		return
	end
	local y_min = math.max(minp.y, height_min)
	local y_max = math.min(maxp.y, height_max)
	local volume = (maxp.x-minp.x+1)*(y_max-y_min+1)*(maxp.z-minp.z+1)
	local pr = PseudoRandom(seed + 9324342)
	local max_num_nyancats = math.floor(volume / (16*16*16))
	for i=1,max_num_nyancats do
		if pr:next(0, 1000) == 0 then
			local x0 = pr:next(minp.x, maxp.x)
			local y0 = pr:next(minp.y, maxp.y)
			local z0 = pr:next(minp.z, maxp.z)
			local p0 = {x=x0, y=y0, z=z0}
			default.make_nyancat(p0, pr:next(0,3), pr:next(3,15))
		end
	end
end

minetest.register_on_generated(function(minp, maxp, seed)
	if maxp.y >= 2 and minp.y <= 0 then
		-- Generate clay
		-- Assume X and Z lengths are equal
		local divlen = 4
		local divs = (maxp.x-minp.x)/divlen+1;
		for divx=0+1,divs-1-1 do
		for divz=0+1,divs-1-1 do
			local cx = minp.x + math.floor((divx+0.5)*divlen)
			local cz = minp.z + math.floor((divz+0.5)*divlen)
			if minetest.env:get_node({x=cx,y=1,z=cz}).name == "minitest:water_source" and
					minetest.env:get_node({x=cx,y=0,z=cz}).name == "minitest:sand" then
				local is_shallow = true
				local num_water_around = 0
				if minetest.env:get_node({x=cx-divlen*2,y=1,z=cz+0}).name == "minitest:water_source" then
					num_water_around = num_water_around + 1 end
				if minetest.env:get_node({x=cx+divlen*2,y=1,z=cz+0}).name == "minitest:water_source" then
					num_water_around = num_water_around + 1 end
				if minetest.env:get_node({x=cx+0,y=1,z=cz-divlen*2}).name == "minitest:water_source" then
					num_water_around = num_water_around + 1 end
				if minetest.env:get_node({x=cx+0,y=1,z=cz+divlen*2}).name == "minitest:water_source" then
					num_water_around = num_water_around + 1 end
				if num_water_around >= 2 then
					is_shallow = false
				end	
				if is_shallow then
					for x1=-divlen,divlen do
					for z1=-divlen,divlen do
						if minetest.env:get_node({x=cx+x1,y=0,z=cz+z1}).name == "minitest:sand" then
							minetest.env:set_node({x=cx+x1,y=0,z=cz+z1}, {name="minitest:clay"})
						end
					end
					end
				end
			end
		end
		end
		-- Generate papyrus
		local perlin1 = minetest.env:get_perlin(354, 3, 0.7, 100)
		-- Assume X and Z lengths are equal
		local divlen = 8
		local divs = (maxp.x-minp.x)/divlen+1;
		for divx=0,divs-1 do
		for divz=0,divs-1 do
			local x0 = minp.x + math.floor((divx+0)*divlen)
			local z0 = minp.z + math.floor((divz+0)*divlen)
			local x1 = minp.x + math.floor((divx+1)*divlen)
			local z1 = minp.z + math.floor((divz+1)*divlen)
			-- Determine papyrus amount from perlin noise
			local papyrus_amount = math.floor(perlin1:get2d({x=x0, y=z0}) * 45 - 20)
			-- Find random positions for papyrus based on this random
			local pr = PseudoRandom(seed+1)
			for i=0,papyrus_amount do
				local x = pr:next(x0, x1)
				local z = pr:next(z0, z1)
				if minetest.env:get_node({x=x,y=1,z=z}).name == "minitest:dirt_with_grass" and
						minetest.env:find_node_near({x=x,y=1,z=z}, 1, "minitest:water_source") then
					default.make_papyrus({x=x,y=2,z=z}, pr:next(2, 4))
				end
			end
		end
		end
		-- Generate cactuses
		local perlin1 = minetest.env:get_perlin(230, 3, 0.6, 100)
		-- Assume X and Z lengths are equal
		local divlen = 16
		local divs = (maxp.x-minp.x)/divlen+1;
		for divx=0,divs-1 do
		for divz=0,divs-1 do
			local x0 = minp.x + math.floor((divx+0)*divlen)
			local z0 = minp.z + math.floor((divz+0)*divlen)
			local x1 = minp.x + math.floor((divx+1)*divlen)
			local z1 = minp.z + math.floor((divz+1)*divlen)
			-- Determine cactus amount from perlin noise
			local cactus_amount = math.floor(perlin1:get2d({x=x0, y=z0}) * 6 - 3)
			-- Find random positions for cactus based on this random
			local pr = PseudoRandom(seed+1)
			for i=0,cactus_amount do
				local x = pr:next(x0, x1)
				local z = pr:next(z0, z1)
				-- Find ground level (0...15)
				local ground_y = nil
				for y=30,0,-1 do
					if minetest.env:get_node({x=x,y=y,z=z}).name ~= "air" then
						ground_y = y
						break
					end
				end
				-- If desert sand, make cactus
				if ground_y and minetest.env:get_node({x=x,y=ground_y,z=z}).name == "minitest:desert_sand" then
					default.make_cactus({x=x,y=ground_y+1,z=z}, pr:next(3, 4))
				end
			end
		end
		end
		-- Generate grass
		local perlin1 = minetest.env:get_perlin(329, 3, 0.6, 100)
		-- Assume X and Z lengths are equal
		local divlen = 16
		local divs = (maxp.x-minp.x)/divlen+1;
		for divx=0,divs-1 do
		for divz=0,divs-1 do
			local x0 = minp.x + math.floor((divx+0)*divlen)
			local z0 = minp.z + math.floor((divz+0)*divlen)
			local x1 = minp.x + math.floor((divx+1)*divlen)
			local z1 = minp.z + math.floor((divz+1)*divlen)
			-- Determine grass amount from perlin noise
			local grass_amount = math.floor(perlin1:get2d({x=x0, y=z0}) ^ 3 * 9)
			-- Find random positions for grass based on this random
			local pr = PseudoRandom(seed+1)
			for i=0,grass_amount do
				local x = pr:next(x0, x1)
				local z = pr:next(z0, z1)
				-- Find ground level (0...15)
				local ground_y = nil
				for y=30,0,-1 do
					if minetest.env:get_node({x=x,y=y,z=z}).name ~= "air" then
						ground_y = y
						break
					end
				end
				
				if ground_y then
					local p = {x=x,y=ground_y+1,z=z}
					local nn = minetest.env:get_node(p).name
					-- Check if the node can be replaced
					if minetest.registered_nodes[nn] and
						minetest.registered_nodes[nn].buildable_to then
						nn = minetest.env:get_node({x=x,y=ground_y,z=z}).name
						-- If desert sand, add dry shrub
						if nn == "minitest:desert_sand" then
							minetest.env:set_node(p,{name="minitest:dry_shrub"})
							
						-- If dirt with grass, add grass
						elseif nn == "minitest:dirt_with_grass" then
							minetest.env:set_node(p,{name="minitest:grass_"..pr:next(1, 5)})
						end
					end
				end
				
			end
		end
		end
	end

	-- Generate nyan cats
	generate_nyancats(seed, minp, maxp)
end)

