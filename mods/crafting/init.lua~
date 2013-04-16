wb = false
local guy = nil
local tmp
local wp
SURVIVAL_FORMSPEC = "size[8,8.5]"..
	"background[-0.19,-0.25;8.41,9.25;crafting_inventory.png]"..
	"image[1,0;3,4;crafting_inventory_player.png]"..	
	"list[current_player;armor;0,0;1,4;]"..	
	"list[current_player;main;0,4.5;8,4;]"..
	"list[current_player;craft;4,1;2,2;]"..
	"list[current_player;craftpreview;7,1.5;1,1;]"
	
minetest.register_alias("workbench:3x3", "crafting:workbench")


function weg(player, pos)
	local inv = player:get_inventory()
	local dir = player:get_look_dir()
	if minetest.env:get_node({x=pos.x-dir.x, y=pos.y, z=pos.z}).name == "air" then
		pos.x = pos.x - dir.x
	elseif minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z-dir.z}).name == "air" then
		pos.z = pos.z - dir.z
	else
		pos.y = pos.y+1
	end
	for i,stack in ipairs(inv:get_list("craft")) do
		minetest.env:add_item(pos, stack)
		stack:clear()
		inv:set_stack("craft", i, stack)
	end
end

local function reset_player_inventory(player)
	if wp ~= nil then weg(player,wp) end
	player:get_inventory():set_width("craft", 2)
	player:get_inventory():set_size("craft", 4)
	player:set_inventory_formspec(
	"size[8,8.5]"..
	"background[-0.19,-0.25;8.41,9.25;crafting_inventory.png]"..
	"image[1,0;3,4;crafting_inventory_player.png]"..	
	"list[current_player;armor;0,0;1,4;]"..	
	"list[current_player;main;0,4.5;8,4;]"..
	"list[current_player;craft;4,1;2,2;]"..
	"list[current_player;craftpreview;7,1.5;1,1;]")
	wb = false
end

minetest.register_on_joinplayer(function(player)
	player_update_visuals(player)
end)

local function set_player_inventory(player)
	player:get_inventory():set_width("craft", 3)
	player:get_inventory():set_size("craft", 9)
	local form = "size[8,8.5]"..
	"background[-0.19,-0.25;8.41,9.25;crafting_workbench.png]"..
	"list[current_player;main;0,4.5;8,4;]"..
	"list[current_player;craft;1.75,0.5;3,3;]"..
	"list[current_player;craftpreview;5.75,1.5;1,1;]"
	player:set_inventory_formspec(form)
	minetest.show_formspec("singleplayer", "main", form)
end

minetest.register_node("crafting:workbench", {
	description = "Workbench",
	tiles = {"crafting_workbench_top.png", "default_wood.png", "crafting_workbench_side.png",
		"crafting_workbench_side.png", "crafting_workbench_front.png", "crafting_workbench_front.png"},
	paramtype2 = "facedir",
	paramtype = "light",
	groups = {choppy=2,oddly_breakable_by_hand=2,flammable=2},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5,-0.5,-0.5,0.5,0.5,0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5,-0.5,-0.5,0.5,0.5,0.5}
	},
	on_rightclick = function(pos, node, clicker, itemstack)
		wb = true
		guy = clicker
		tmp = clicker:get_look_yaw()
		set_player_inventory(clicker)
		wp = pos
	end
})

local timer = 0
minetest.register_globalstep(function(dtime)
 if wb == true then
	timer = timer + dtime;
	if timer >= 0.8 then
		timer = 0
		if tmp ~= guy:get_look_yaw() then
			reset_player_inventory(guy)
			wb = false
		end
	end
 end
end)

minetest.register_craft({
	output = "crafting:workbench",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})
