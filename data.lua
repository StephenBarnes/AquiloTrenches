local trenchTile = table.deepcopy(data.raw.tile["ammoniacal-ocean"])
trenchTile.name = "aquilo-trench"
trenchTile.autoplace = {probability_expression = "aquilo_trench"}
trenchTile.map_color = {0, 0, .05}
trenchTile.default_cover_tile = nil
trenchTile.tint = {.0, .0, .05, .5} -- For the icon in Factoriopedia, not for the actual ocean tile.
-- Water tiles reuse graphics from the main water tile, using effect color to make them look different.
trenchTile.effect_color = {18, 16, 39}
trenchTile.effect_color_secondary = {12, 24, 52}
-- Add to list of water tiles, so it uses tile transition graphics for water tiles.
table.insert(water_tile_type_names, "aquilo-trench")
-- I thought I would have to set collision masks or sth to block landfill/foundation/ice platform on aquilo-trench, and allow waterways. But it looks like it already behaves like that by default, so no changes necessary.
--[[
Actually it currently allows railway supports; want to block that.
	Lava has layers: water_tile, resource, doodad, rail, item, player, lava_tile.
	Water has layers: water_tile, resource, doodad, floor, item, player.
	Waterway has collision layers: waterway, rail, object.
	Rail support has layers: is_lower_object, is_object, rail, object, rail_support
		But after the deep-oil-ocean tech is researched, it changes to: is_lower_object, is_object, rail, object.
We want to allow waterways and ships on it, but not allow rail supports. Could add rail_support layer, but then it doesn't work after the deep-oil-ocean tech is researched.
So, need to create a new collision layer specifically for that.
]]
trenchTile.collision_mask.layers.aquilo_trench = true

-- Add aquilo_trench collision layer to rail supports.
data.raw["utility-constants"].default.default_collision_masks["rail-support"].layers.aquilo_trench = true
data.raw["utility-constants"].default.default_collision_masks["rail-support/allow_on_deep_oil_ocean"].layers.aquilo_trench = true

-- Create collision layer.
---@type data.CollisionLayerPrototype
local collisionLayer = {
	type = "collision-layer",
	name = "aquilo_trench",
}

data:extend{
	trenchTile, ---@diagnostic disable-line: assign-type-mismatch
	collisionLayer,
	{
		type = "noise-expression",
		name = "aquilo_trench",
		expression = "max(0, 1.8 + aquilo_starting_island) + aquilo_island_peaks + (noise * 0.8) < -0.28",
			-- FOR MYSELF OR OTHER MODDER: If you want to understand the expression above:
			-- The entire expression is "something < -0.28", so you can think of it as an elevation. Trench appears where elevation is under that threshold.
			-- aquilo_starting_island is a noise expression that starts around +1 on the starting island then decreases with distance, becoming negative.
			--     So max(0, 1.8+aquilo_starting_island) makes sure there's no trench in some distance of the starting island.
			--     Far away from starting island, the first arg of the max (0) takes over, so this term has no effect.
			--     The 1.8 here increases the radius where no trench appears.
			-- aquilo_island_peaks is a noise expression that is high on each resource deposit, and decreases with distance from deposits to a minimum of -1.
			-- Noise is just multioctave noise so trenches don't look too regular.
		local_expressions = {
			noise = "abs(multioctave_noise{x = x, y = y,\z
													seed0 = map_seed, seed1 = 3500,\z
													persistence = 0.75,\z
													input_scale = 1 / 16,\z
													output_scale = 1,\z
													offset_x = 10000,\z
													octaves = 5})"
		},
	},
}

data.raw.planet.aquilo.map_gen_settings.autoplace_settings.tile.settings["aquilo-trench"] = {}