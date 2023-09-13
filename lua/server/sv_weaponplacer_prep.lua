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

function weaponPlacer:RemoveSpawnEntities()
	for i, ent in ipairs(GetSpawnEnts(false, true)) do
		ent.BeingRemoved = true
		ent:Remove()
	end
end

function weaponPlacer:RemoveReplaceables()
	for _, ent in ipairs(ents.FindByClass("item_*")) do
		if hl2_ammo_replace[ent:GetClass()] then
			ent:Remove()
		end
	 end

	for _, ent in ipairs(ents.FindByClass("weapon_*")) do
		if hl2_weapon_replace[ent:GetClass()] then
			ent:Remove()
		end
	end
end

function weaponPlacer:RemoveCrowbars()
	for _, ent in ipairs(ents.FindByClass("weapon_zm_improvised)")) do
		ent:Remove()
	end
end

function weaponPlacer:RemoveWeaponEntities()
	self:RemoveReplaceables()

	for _, class in ipairs(ents.TTT.GetSpawnableAmmo()) do
		for _, ent in ipairs(ents.FindByClass(class)) do
			ent:Remove()
		end
	end

	for _, spawnableEnt in ipairs(ents.TTT.GetSpawnableSWEPs()) do
		local class = WEPS.GetClass(spawnableEnt)
		for _, ent in ipairs(ents.FindByClass(class)) do
			ent:Remove()
		end
	end

	ents.TTT.RemoveRagdolls(false)
	self:RemoveCrowbars()
end

function weaponPlacer:CreateImportedEnt(class, pos, ang, kv)
	if not class or not pos or not ang or not kv then
		return false
	end

	local ent = ents.Create(class)

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

function weaponPlacer:ImportEntities()
	local ents = self:GetEntitiesFromScript(self:GetCurrentMapScript())

	for _, ent in ipairs(ents) do
		self:CreateImportedEnt(ent.class, ent.pos, ent.ang, ent.kv)
	end
end

function weaponPlacer.PrepareRound()
	if not GetConVar("weapon_placer_enabled"):GetBool() then
		return
	end

	local weaponPlacerFileExists = file.Exists(weaponPlacer:GetCurrentMapScriptName(), "DATA")
	local tttFileExists = file.Exists(weaponPlacer:GetCurrentMapScriptName(true), "MOD")

	if not weaponPlacerFileExists then
		if not tttFileExists then
			return
		end

		weaponPlacer:ConvertCurrentMapScriptToWeaponPlacerScript()
	end

	local settings = weaponPlacer:GetSettingsFromScript()

	if tobool(settings.replacespawns) then
		weaponPlacer:RemoveSpawnEntities()
	end

	if tobool(settings.replaceweapons) then
		weaponPlacer:RemoveWeaponEntities()
	end

	weaponPlacer:ImportEntities()
end

hook.Add("TTTPrepareRound", "WeaponPlacerBeginRound", weaponPlacer.PrepareRound)