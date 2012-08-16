local player_ges = 0
local player_in_bed = 0

minetest.register_node("beds:bed_bottom", {
	description = "Bed",
	drawtype = "nodebox",
	tiles = {"beds_bed_top_bottom.png", "default_wood.png",  "beds_bed_side.png",  "beds_bed_side.png",  "beds_bed_side.png",  "beds_bed_side.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=3},
	sounds = default.node_sound_wood_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
					-- bed
					{-0.5, 0.0, -0.5, 0.5, 0.3, 0.5},
					
					-- stützen
					{-0.5, -0.5, -0.5, -0.4, 0.0, -0.4},
					{0.4, 0.0, -0.4, 0.5, -0.5, -0.5},
				}
	},
	selection_box = {
		type = "fixed",
		fixed = {
					{-0.5, -0.5, -0.5, 0.5, 0.3, 1.5},
				}
	},
	
	
	on_construct = function(pos)
		local node = minetest.env:get_node(pos)
		local param2 = node.param2
		if param2 == 0 then
			node.name = "beds:bed_top"
			pos.z = pos.z+1
			minetest.env:set_node(pos, node)
		elseif param2 == 1 then
			node.name = "beds:bed_top"
			pos.x = pos.x+1
			minetest.env:set_node(pos, node)
		elseif param2 == 2 then
			node.name = "beds:bed_top"
			pos.z = pos.z-1
			minetest.env:set_node(pos, node)
		elseif param2 == 3 then
			node.name = "beds:bed_top"
			pos.x = pos.x-1
			minetest.env:set_node(pos, node)
		end
	end,
	
	on_destruct = function(pos)
		local node = minetest.env:get_node(pos)
		local param2 = node.param2
		if param2 == 0 then
			pos.z = pos.z+1
			minetest.env:remove_node(pos)
		elseif param2 == 1 then
			pos.x = pos.x+1
			minetest.env:remove_node(pos)
		elseif param2 == 2 then
			pos.z = pos.z-1
			minetest.env:remove_node(pos)
		elseif param2 == 3 then
			pos.x = pos.x-1
			minetest.env:remove_node(pos)
		end
	end,
	
	on_punch = function(pos, node, puncher)
		if not puncher:is_player() then
			return
		end
		if puncher:get_wielded_item():get_name() == "" then
			local meta = minetest.env:get_meta(pos)
			local param2 = node.param2
			if param2 == 0 then
				pos.z = pos.z+1
			elseif param2 == 1 then
				pos.x = pos.x+1
			elseif param2 == 2 then
				pos.z = pos.z-1
			elseif param2 == 3 then
				pos.x = pos.x-1
			end
			if puncher:get_player_name() == meta:get_string("player") then
				if param2 == 0 then
					pos.x = pos.x-1
				elseif param2 == 1 then
					pos.z = pos.z+1
				elseif param2 == 2 then
					pos.x = pos.x+1
				elseif param2 == 3 then
					pos.z = pos.z-1
				end
				pos.y = pos.y-0.5
				puncher:setpos(pos)
				meta:set_string("player", "")
				player_in_bed = player_in_bed-1
			elseif meta:get_string("player") == "" then
				pos.y = pos.y-0.5
				puncher:setpos(pos)
				meta:set_string("player", puncher:get_player_name())
				player_in_bed = player_in_bed+1
			end
		end
	end
})

minetest.register_node("beds:bed_top", {
	drawtype = "nodebox",
	tiles = {"beds_bed_top_top.png", "default_wood.png",  "beds_bed_side_top_r.png",  "beds_bed_side_top_l.png",  "default_wood.png",  "beds_bed_side.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=3},
	sounds = default.node_sound_wood_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
					-- bed
					{-0.5, 0.0, -0.5, 0.5, 0.3, 0.5},
					
					-- stützen
					{-0.4, 0.0, 0.4, -0.5, -0.5, 0.5},
					{0.5, -0.5, 0.5, 0.4, 0.0, 0.4},
				}
	},
	selection_box = {
		type = "fixed",
		fixed = {
					{0, 0, 0, 0, 0, 0},
				}
	},
})

minetest.register_alias("beds:bed", "beds:bed_bottom")

minetest.register_craft({
	output = "beds:bed",
	recipe = {
		{"wool:red", "wool:blue", "wool:blue", },
		{"default:stick", "", "default:stick", }
	}
})

minetest.register_on_joinplayer(function(pl)
	player_ges = player_ges+1
end)

minetest.register_on_leaveplayer(function(pl)
	player_ges = player_ges-1
end)

local timer = 0
local wait = false
minetest.register_globalstep(function(dtime)
	if timer<10 then
		timer = timer+dtime
	end
	timer = 0
	
	if player_ges == player_in_bed and player_ges ~= 0 then
		if minetest.env:get_timeofday() < 0.2 or minetest.env:get_timeofday() > 0.805 then
			if not wait then
				minetest.chat_send_all("Good night!!!")
				minetest.after(2, function()
					minetest.env:set_timeofday(0.23)
					wait = false
				end)
				wait = true
			end
		end
	end
end)

minetest.register_abm({
	nodenames = {"beds:bed_bottom"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		local meta = minetest.env:get_meta(pos)
		if meta:get_string("player") ~= "" then
			local param2 = node.param2
			if param2 == 0 then
				pos.z = pos.z+1
			elseif param2 == 1 then
				pos.x = pos.x+1
			elseif param2 == 2 then
				pos.z = pos.z-1
			elseif param2 == 3 then
				pos.x = pos.x-1
			end
			local player = minetest.env:get_player_by_name(meta:get_string("player"))
			if player == nil then
				meta:set_string("player", "")
				player_in_bed = player_in_bed-1
				return
			end
			local player_pos = player:getpos()
			player_pos.x = math.floor(0.5+player_pos.x)
			player_pos.y = math.floor(0.5+player_pos.y)
			player_pos.z = math.floor(0.5+player_pos.z)
			if pos.x ~= player_pos.x or pos.y ~= player_pos.y or pos.z ~= player_pos.z then
				meta:set_string("player", "")
				player_in_bed = player_in_bed-1
				return
			end
		end
	end
})
