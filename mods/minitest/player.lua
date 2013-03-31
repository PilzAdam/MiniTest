-- Minetest 0.4 mod: player
-- See README.txt for licensing and other information.

--
-- Start of configuration area:
--

-- Player animation speed
animation_speed = 30

-- Player animation blending
-- Note: This is currently broken due to a bug in Irrlicht, leave at 0
animation_blend = 0

-- Default player appearance
default_model = "character.x"
default_textures = {"character.png", }

-- Frame ranges for each player model
function player_get_animations(model)
	if model == "character.x" then
		return {
		stand_START = 0,
		stand_END = 79,
		sit_START = 81,
		sit_END = 160,
		lay_START = 162,
		lay_END = 166,
		walk_START = 168,
		walk_END = 187,
		mine_START = 189,
		mine_END = 198,
		walk_mine_START = 200,
		walk_mine_END = 219
		}
	end
end

--
-- End of configuration area.
--

-- Player stats and animations
local player_model = {}
local player_anim = {}
local player_sneak = {}
local ANIM_STAND = 1
local ANIM_SIT = 2
local ANIM_LAY = 3
local ANIM_WALK  = 4
local ANIM_WALK_MINE = 5
local ANIM_MINE = 6

-- Called when a player's appearance needs to be updated
function player_update_visuals(pl)
	local name = pl:get_player_name()

	player_model[name] = default_model
	player_anim[name] = 0 -- Animation will be set further below immediately
	player_sneak[name] = false
	prop = {
		mesh = default_model,
		textures = default_textures,
		visual = "mesh",
		visual_size = {x=1, y=1},
	}
	pl:set_properties(prop)
end

-- Update appearance when the player joins
minetest.register_on_joinplayer(player_update_visuals)

-- Check each player and apply animations
function player_step(dtime)
	for _, pl in pairs(minetest.get_connected_players()) do
		local name = pl:get_player_name()
		local anim = player_get_animations(player_model[name])
		local controls = pl:get_player_control()
		local walking = false
		local animation_speed_mod = animation_speed

		-- Determine if the player is walking
		if controls.up or controls.down or controls.left or controls.right then
			walking = true
		end

		-- Determine if the player is sneaking, and reduce animation speed if so
		if controls.sneak and pl:get_hp() ~= 0 and (walking or controls.LMB) then
			animation_speed_mod = animation_speed_mod / 2
			-- Refresh player animation below if sneak state changed
			if not player_sneak[name] then
				player_anim[name] = 0
				player_sneak[name] = true
			end
		else
			-- Refresh player animation below if sneak state changed
			if player_sneak[name] then
				player_anim[name] = 0
				player_sneak[name] = false
			end
		end

		-- Apply animations based on what the player is doing
		if pl:get_hp() == 0 then
			if player_anim[name] ~= ANIM_LAY then
				pl:set_animation({x=anim.lay_START, y=anim.lay_END}, animation_speed_mod, animation_blend)
				player_anim[name] = ANIM_LAY
			end
		elseif walking and controls.LMB then
			if player_anim[name] ~= ANIM_WALK_MINE then
				pl:set_animation({x=anim.walk_mine_START, y=anim.walk_mine_END}, animation_speed_mod, animation_blend)
				player_anim[name] = ANIM_WALK_MINE
			end
		elseif walking then
			if player_anim[name] ~= ANIM_WALK then
				pl:set_animation({x=anim.walk_START, y=anim.walk_END}, animation_speed_mod, animation_blend)
				player_anim[name] = ANIM_WALK
			end
		elseif controls.LMB then
			if player_anim[name] ~= ANIM_MINE then
				pl:set_animation({x=anim.mine_START, y=anim.mine_END}, animation_speed_mod, animation_blend)
				player_anim[name] = ANIM_MINE
			end
		elseif player_anim[name] ~= ANIM_STAND then
			pl:set_animation({x=anim.stand_START, y=anim.stand_END}, animation_speed_mod, animation_blend)
			player_anim[name] = ANIM_STAND
		end
	end
end
minetest.register_globalstep(player_step)

-- END
