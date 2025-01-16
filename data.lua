local trenchTile = table.deepcopy(data.raw.tile["ammoniacal-ocean"])
trenchTile.name = "aquilo-trench"
trenchTile.autoplace = {probability_expression = "aquilo_trench"}
trenchTile.map_color = {0, 0, 0}
trenchTile.default_cover_tile = nil
-- Water tiles reuse graphics from the main water tile, using effect color to make them look different.
trenchTile.effect_color = {18, 16, 39}
trenchTile.effect_color_secondary = {12, 24, 52}
-- I thought I would have to set collision masks or sth to block landfill/foundation/ice platform on aquilo-trench, and allow waterways. But it looks like it already behaves like that by default, so no changes necessary.

data:extend{
	trenchTile,
	{
		type = "noise-expression",
		name = "aquilo_trench",
		expression = "max(0, 1.8 + aquilo_starting_island) + aquilo_island_peaks + (noise * 0.8) < -0.28",
			-- FOR MYSELF OR OTHER MODDER: If you want to understand the expression above:
			-- The entire expression is "something < -0.28", so you can think of it as an elevation. Trench appears where elevation is low.
			-- aquilo_starting_island is a noise expression that starts around +1 on the starting island then becomes negative.
			-- So max(0, 1.8+aquilo_starting_island) makes sure there's no trench in some distance of the starting island.
			--     Far away from starting island, the first arg of the max (0) takes over, so this term has no effect.
			--     The 1.8 here increases the radius where no trench appears.
			-- aquilo_island_peaks is a noise expression that is high on each resource deposit, and decreases away from islands to a minimum around -1 I think.
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