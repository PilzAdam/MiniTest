minetest.register_on_joinplayer(function(player)
	player:set_inventory_formspec(
		"invsize[8,7.5;]"..
		"image[1,0.6;1,2;player.png]"..
		"list[current_player;main;0,3.5;8,4;]"..
		"list[current_player;craft;3,0;3,3;]"..
		"list[current_player;craftpreview;7,1;1,1;]")
end)