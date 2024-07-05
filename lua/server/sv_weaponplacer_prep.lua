-- Copied and Modified from TTT 11/26/2022

local hl2_weapon_replace = {
	["weapon_smg1"] = "weapon_zm_mac10",
	["weapon_shotgun"] = "weapon_zm_shotgun",
	["weapon_ar2"] = "weapon_ttt_m16",
	["weapon_357"] = "weapon_zm_rifle",
	["weapon_crossbow"] = "weapon_zm_pistol",
	["weapon_rpg"] = "weapon_zm_sledge",
	["weapon_slam"] = "item_ammo_pistol_ttt",
	["weapon_frag"] = "weapon_zm_revolver",
	["weapon_crowbar"] = "weapon_zm_molotov"
}

local hl2_ammo_replace = {
	["item_ammo_pistol"] = "item_ammo_pistol_ttt",
	["item_box_buckshot"] = "item_box_buckshot_ttt",
	["item_ammo_smg1"] = "item_ammo_smg1_ttt",
	["item_ammo_357"] = "item_ammo_357_ttt",
	["item_ammo_357_large"] = "item_ammo_357_ttt",
	["item_ammo_revolver"] = "item_ammo_revolver_ttt",
	["item_ammo_ar2"] = "item_ammo_pistol_ttt",
	["item_ammo_ar2_large"] = "item_ammo_smg1_ttt",
	["item_ammo_smg1_grenade"] = "weapon_zm_pistol",
	["item_battery"] = "item_ammo_357_ttt",
	["item_healthkit"] = "weapon_zm_shotgun",
	["item_suitcharger"] = "weapon_zm_mac10",
	["item_ammo_ar2_altfire"] = "weapon_zm_mac10",
	["item_rpg_round"] = "item_ammo_357_ttt",
	["item_ammo_crossbow"] = "item_box_buckshot_ttt",
	["item_healthvial"] = "weapon_zm_molotov",
	["item_healthcharger"] = "item_ammo_revolver_ttt",
	["item_ammo_crate"] = "weapon_ttt_confgrenade",
	["item_item_crate"] = "ttt_random_ammo"
}

local spawnTypes = {
	["info_player_deathmatch"] = true,
	["info_player_combine"] = true,
	["info_player_rebel"] = true,
	["info_player_counterterrorist"] = true,
	["info_player_terrorist"] = true,
	["info_player_axis"] = true,
	["info_player_allies"] = true,
	["gmod_player_start"] = true,
	["info_player_teamspawn"] = true,
	["info_player_start"] = true
}

local weaponPlacerSpawnIDs = weaponPlacerSpawnIDs or {}

function weaponPlacer:RemoveSpawnEntities()
	for i, ent in ipairs(GetSpawnEnts(false, true)) do
		ent.BeingRemoved = true
		ent:Remove()
	end
end

function weaponPlacer:RemoveReplaceables()
	for _, ent in ipairs(ents.FindByClass("item_*")) do
		if hl2_ammo_replace[ent:GetClass()] then
			if ent:CreatedByMap() then
				ent:Remove()
			end
		end
	 end

	for _, ent in ipairs(ents.FindByClass("weapon_*")) do
		if hl2_weapon_replace[ent:GetClass()] then
			if ent:CreatedByMap() then
				ent:Remove()
			end
		end
	end
end

function weaponPlacer:RemoveWeaponEntities()
	self:RemoveReplaceables()

	for _, class in ipairs(ents.TTT.GetSpawnableAmmo()) do
		for _, ent in ipairs(ents.FindByClass(class)) do
			if ent:CreatedByMap() then
				ent:Remove()
			end
		end
	end

	for _, spawnableEnt in ipairs(ents.TTT.GetSpawnableSWEPs()) do
		local class = WEPS.GetClass(spawnableEnt)
		for _, ent in ipairs(ents.FindByClass(class)) do
			if ent:CreatedByMap() then
				ent:Remove()
			end
		end
	end
end

function weaponPlacer:CreateImportedEnt(class, pos, ang, kv)
	if not class or not pos or not ang or not kv then
		return false
	end

	local ent = ents.Create(class)

	if ent.class == "info_player_deathmatch" then
		ent.weaponPlacer = true
	end

	if not IsValid(ent) then
		--MsgC(Color(255, 0, 0), "Weapon Placer: Invalid weapon: " .. class .. " on map: " .. game.GetMap() .. "\n")
		return false
	end

	ent:SetPos(pos)
	ent:SetAngles(ang)

	for k,v in pairs(kv) do
		ent:SetKeyValue(k, v)
	end

	ent:Spawn()
	ent:PhysWake()

	return true
end

function weaponPlacer:ImportEntities(spawnsOnly)
	local ents = self:GetEntitiesFromScript(self:GetCurrentMapScript())

	for _, ent in ipairs(ents) do
		if spawnsOnly and not spawnTypes[ent.class] then
			continue
		end

		if not spawnsOnly and spawnTypes[ent.class] then
			continue
		end

		self:CreateImportedEnt(ent.class, ent.pos, ent.ang, ent.kv)
	end
end

hook.Add("TTTPrepareRound", "WeaponPlacerBeginRound", function()
	weaponPlacer.prepareRound = true
end)

function weaponPlacer.PostCleanupMap()
	if weaponPlacer.prepareRound then
		if not GetConVar("weapon_placer_enabled"):GetBool() then
			return nil
		end

		local weaponPlacerFileExists = file.Exists(weaponPlacer:GetCurrentMapScriptName(), "DATA")

		if not weaponPlacerFileExists then
			local tttFileExists = file.Exists(weaponPlacer:GetCurrentMapScriptName(true), "GAME")

			if not tttFileExists then
				return nil
			end

			weaponPlacer:ConvertCurrentMapScriptToWeaponPlacerScript()
		end

		if weaponPlacer:GetSettingsFromScript().replacespawns then
			weaponPlacer:RemoveSpawnEntities()
		end

		weaponPlacer:ImportEntities(true)

		if weaponPlacer:GetSettingsFromScript().replaceweapons then
			weaponPlacer:RemoveWeaponEntities()
		end

		weaponPlacer:ImportEntities()

		weaponPlacer.prepareRound = false
	end
end

hook.Add("PostCleanupMap", "WeaponPlacerPostCleanup", weaponPlacer.PostCleanupMap)