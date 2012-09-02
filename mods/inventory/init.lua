minetest.register_on_joinplayer(function(player)
	if not minetest.setting_getbool("creative_mode") then
		player:get_inventory():set_width("craft", 2)
		player:get_inventory():set_size("craft", 4)
		player:set_inventory_formspec(
			"size[8,7.5;]"..
			"image[1,0.6;1,2;player.png]"..
			"list[current_player;main;0,3.5;8,4;]"..
			"list[current_player;craft;4,0.5;2,2;]"..
			"list[current_player;craftpreview;6.5,1;1,1;]")
	else
		player:get_inventory():set_width("craft", 3)
		player:get_inventory():set_size("craft", 9)
	end
end)

--minetest.nodedef_default.stack_max = 64 FIXME why does this not work?
minetest.after(0, function()
	for name,node in pairs(minetest.registered_nodes) do
		local new_node = {stack_max=64,}
		for attrib,value in pairs(node) do
			new_node[attrib] = value
		end
		minetest.register_node(":"..name, new_node)
	end
end)
