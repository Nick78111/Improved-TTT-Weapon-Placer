function ulx.giveWeaponPlacer(calling_ply)
	calling_ply:Give("ttt_weapon_placer")
	ulx.fancyLogAdmin(calling_ply, "#A gave themself ttt_weapon_placer")
end
local placer = ulx.command("Weapon Placer", "ulx weaponplacer", ulx.giveWeaponPlacer, "!weaponplacer")
placer:defaultAccess(ULib.ACCESS_SUPERADMIN)
placer:help("Gives the improved ttt weapon placer.")