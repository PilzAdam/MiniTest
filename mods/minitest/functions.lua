-- TNT Functions
function spawn_tnt(pos, entname)
    minetest.sound_play("", {pos = pos,gain = 1.0,max_hear_distance = 8,})
    return minetest.env:add_entity(pos, entname)
end

function activate_if_tnt(nname, np, tnt_np, tntr)
    if nname == "minitest:tnt" then
        local e = spawn_tnt(np, nname)
        e:setvelocity({x=(np.x - tnt_np.x)*3+(tntr / 4), y=(np.y - tnt_np.y)*3+(tntr / 3), z=(np.z - tnt_np.z)*3+(tntr / 4)})
    end
end

function do_tnt_physics(tnt_np,tntr)
    local objs = minetest.env:get_objects_inside_radius(tnt_np, tntr)
    for k, obj in pairs(objs) do
        local oname = obj:get_entity_name()
        local v = obj:getvelocity()
        local p = obj:getpos()
        if oname == "minitest:tnt" then
            obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 2) + v.x, y=(p.y - tnt_np.y) + tntr + v.y, z=(p.z - tnt_np.z) + (tntr / 2) + v.z})
        else
            if v ~= nil then
                obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 4) + v.x, y=(p.y - tnt_np.y) + (tntr / 2) + v.y, z=(p.z - tnt_np.z) + (tntr / 4) + v.z})
            else
                if obj:get_player_name() ~= nil then
                    obj:set_hp(obj:get_hp() - 1)
                end
            end
        end
    end
end

-- TNT Entity
minetest.register_on_punchnode(function(p, node)
	if node.name == "minitest:tnt" then
		minetest.env:remove_node(p)
		spawn_tnt(p, "minitest:tnt")
		nodeupdate(p)
	end
end)

local TNT_BOMB_RANGE = 2
local TNT_BOMB = {
	-- Static definition
	physical = true, -- Collides with things
	 --weight = -100,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	tile_images = {"default_tnt_top.png", "default_tnt_bottom.png",
			"default_tnt_side.png", "default_tnt_side.png",
			"default_tnt_side.png", "default_tnt_side.png"},
	-- Initial value for our timer
	timer = 0,
	-- Number of punches required to defuse
	health = 1,
	blinktimer = 0,
	blinkstatus = true,}

function TNT_BOMB:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function TNT_BOMB:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 10 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)
        do_tnt_physics(pos, TNT_BOMB_RANGE)
        minetest.sound_play("nuke_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})
        if minetest.env:get_node(pos).name == "minitest:water_source" or minetest.env:get_node(pos).name == "minitest:water_flowing" then
            -- Cancel the Explosion
            self.object:remove()
            return
        end
        for x=-TNT_BOMB_RANGE,TNT_BOMB_RANGE do
        for y=-TNT_BOMB_RANGE,TNT_BOMB_RANGE do
        for z=-TNT_BOMB_RANGE,TNT_BOMB_RANGE do
            if x*x+y*y+z*z <= TNT_BOMB_RANGE * TNT_BOMB_RANGE + TNT_BOMB_RANGE then
                local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
                local n = minetest.env:get_node(np)
                if n.name ~= "air" then
                    minetest.env:remove_node(np)					
                end
                activate_if_tnt(n.name, np, pos, TNT_BOMB_RANGE)
            end
        end
        end
        end
		self.object:remove()
	end
end

function TNT_BOMB:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "minitest:tnt")
	end
end

minetest.register_entity("minitest:tnt", TNT_BOMB)

-- Flint and Steel Functions
function get_nodedef_field(nodename, fieldname)
    if not minetest.registered_nodes[nodename] then
        return nil
    end
    return minetest.registered_nodes[nodename][fieldname]
end

function set_fire(pointed_thing)
		local n = minetest.env:get_node(pointed_thing.above)
		if n.name ~= ""  and n.name == "air" then
			minetest.env:set_node(pointed_thing.above, {name="fire:basic_flame"})
		end
end