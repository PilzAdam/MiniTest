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
