weaponPlacer.spawnedEntities = {}
weaponPlacer.spawnableEntities = nil
weaponPlacer.ghostProp = nil
weaponPlacer.selectedClass = nil
weaponPlacer.currentMapSpawns = nil
weaponPlacer.hiddenWeapons = {}
weaponPlacer.menu = nil

weaponPlacer.settings = {
	spawnAmmo = false,
	collision = false,
	freeze = false,
	noclip = false,
	replaceSpawns = false,
	replaceWeapons = false,
	hideWeapons = false,
	hidePlayers = false
}

function weaponPlacer:SetNoclip(bool)
	if not self:CanUseWeaponPlacer() then
		return
	end

	net.Start("WeaponPlacer.SetNoclip")
		net.WriteBool(bool)
	net.SendToServer()
end

function weaponPlacer:GetSetting(setting)
	return self.settings[setting]
end

function weaponPlacer:SetSetting(setting, val, editPnl)
	if self:GetSetting(setting) == nil then
		return
	end

	if editPnl and self.menu then
		local pnl = self.menu:GetSettingPanel(setting)

		if pnl then
			pnl:SetValue(val)
			pnl.DataChanged(pnl, val == true and 1 or 0)
		end
	end

	self.settings[setting] = val
end

function weaponPlacer:ResetSettings()
	for setting, _ in pairs(self.settings) do
		self:SetSetting(setting, false, true)
	end
end

function weaponPlacer:GetSpawnedEntities()
	return self.spawnedEntities
end

function weaponPlacer:GetSpawnedEntity(entity)
	if not self:GetSpawnedEntities()[entity] then
		return false
	end

	return IsValid(self:GetSpawnedEntities()[entity].prop) and self:GetSpawnedEntities()[entity] or false
end

function weaponPlacer:GetSpawnableEntityFromClass(class)
	return self:GetSpawnableEntities()[class]
end

function weaponPlacer:GetWeaponAmmoFromClass(class)
	local ammo = self:GetSpawnableEntityFromClass(class).ammo
	return self:GetSpawnableEntityFromClass(ammo) or false
end

function weaponPlacer:GetSelectedClass()
	return self.selectedClass
end

function weaponPlacer:GetGhostProp()
	return IsValid(self.ghostProp) and self.ghostProp or false
end

function weaponPlacer:GetSpawnableEntities()
	if self.spawnableEntities then
		return self.spawnableEntities
	end

	self.spawnableEntities = {}

	self.spawnableEntities["ttt_random_weapon"] = {
		class = "ttt_random_weapon",
		name = "Random Weapon",
		model = "models/weapons/w_rif_m4a1.mdl",
		type = "Random Weapon"
	}

	self.spawnableEntities["ttt_random_ammo"] = {
		class = "ttt_random_ammo",
		name = "Random Ammo",
		model = "models/items/boxmrounds.mdl",
		type = "Random Ammo"
	}

	self.spawnableEntities["info_player_deathmatch"] = {
		class = "info_player_deathmatch",
		name = "Spawnpoint",
		model = "models/player.mdl",
		type = "Player Spawn"
	}

	for _, _wep in ipairs(weapons.GetList()) do
		local wep = weapons.Get(_wep.ClassName)
		local _type = "Weapon"

		if not wep.Kind then
			continue
		end

		if wep.ClassName == "ttt_weapon_placer" then
			continue
		end

		if wep.CanBuy then
			_type = "Role Weapon"
		end

		self.spawnableEntities[wep.ClassName] = {
			class = wep.ClassName,
			name = LANG.TryTranslation(wep.PrintName) or false,
			model = (wep.WorldModel and wep.WorldModel ~= "") and wep.WorldModel or "models/weapons/w_rif_m4a1.mdl",
			ammo = wep.AmmoEnt or false,
			type = _type
		}

		if wep.AmmoEnt and not self.spawnableEntities[wep.AmmoEnt] then
			local ent = scripted_ents.Get(wep.AmmoEnt)

			if not ent then
				continue
			end

			self.spawnableEntities[wep.AmmoEnt] = {
				class = wep.AmmoEnt,
				name = LANG.TryTranslation(ent.AmmoType),
				model = ent.Model or "models/items/boxmrounds.mdl",
				type = "Ammo"
			}
		end
	end

	-- just incase; this should only add ammo to spawnables
	for class, entTable in pairs(scripted_ents.GetList()) do
		if self.spawnableEntities[class] then
			continue
		end

		if not entTable then
			continue
		end

		if not (entTable.AutoSpawnable or (entTable.t and entTable.t.AutoSpawnable)) then
			continue
		end

		local ent = scripted_ents.Get(class)

		if not ent then
			continue
		end

		self.spawnableEntities[class] = {
			class = class,
			name = ent.AmmoType or class,
			model = ent.Model or "models/items/boxmrounds.mdl",
			type = ent.AmmoType and "Ammo" or "Unknown"
		}
	end

	return self.spawnableEntities
end

function weaponPlacer:SetGhostProp(model)
	if not model then
		if self:GetGhostProp() then
			self.ghostProp:Remove()
		end

		self.ghostProp = nil

		return
	end

	if self:GetGhostProp() then
		self.ghostProp:SetModel(model)
	else
		local ghostProp = ents.CreateClientProp()
		ghostProp:SetModel(model)
		ghostProp:SetColor(Color(255, 0, 0))

		self.ghostProp = ghostProp
	end
end

local lastWep = nil

function weaponPlacer:SelectClass(class, selectAmmo)
	if selectAmmo or self:GetSetting("spawnAmmo") then
		lastWep = class

		local spawnableEntity = self:GetWeaponAmmoFromClass(class)

		if spawnableEntity then
			self.selectedClass = spawnableEntity.class
			self:SetGhostProp(spawnableEntity.model)

			return
		end
	end

	if lastWep then
		class = lastWep
		lastWep = nil
	end

	local spawnableEntity = self:GetSpawnableEntityFromClass(class)

	self.selectedClass = class
	self:SetGhostProp(spawnableEntity.model)
end

function weaponPlacer:CleanUpProps()
	if not table.IsEmpty(self:GetSpawnedEntities()) then
		for _, spawnedEntity in pairs(self:GetSpawnedEntities()) do
			if spawnedEntity.prop:IsValid() then
				spawnedEntity.prop:Remove()
				self.menu:RemoveSpawnedEntity(spawnedEntity.line)
			end
		end
	end

	self:SetGhostProp(nil)
	self.selectedClass = nil

	self.spawnedEntities = {}
end

function weaponPlacer:RemoveSpawnedEntity(entity)
	local spawnedEntity = self:GetSpawnedEntity(entity)

	if not spawnedEntity then
		return
	end

	self.menu:RemoveSpawnedEntity(spawnedEntity.line)
	spawnedEntity.prop:Remove()
	self:GetSpawnedEntities()[entity] = nil
end

function weaponPlacer:AddItem(class, pos, ang, freeze)
	local spawnableEntity = self:GetSpawnableEntityFromClass(class)

	if not spawnableEntity then
		return
	end

	local spawnedEntity = self:CreateProp(class, pos, ang, freeze)

	if not spawnedEntity then
		return
	end

	local tmp = {
		class = class,
		prop = spawnedEntity,
		line = self.menu:AddSpawnedEntity(spawnedEntity, class)
	}

	self:GetSpawnedEntities()[spawnedEntity] = tmp

	self.menu.spawnedEntities.VBar:InvalidateParent(true)
	self.menu.spawnedEntities.VBar:SetScroll(self.menu.spawnedEntities.VBar.CanvasSize)
end

function weaponPlacer:CreateProp(class, pos, ang, freeze)
	local spawnableEntity = self:GetSpawnableEntityFromClass(class)

	if not spawnableEntity then
		return
	end

	if not class and not weaponPlacer:GetGhostProp() then
		return
	end

	local prop = ents.CreateClientProp()

	prop:SetModel(spawnableEntity.model)

	prop:SetPos(pos or weaponPlacer:GetGhostProp():GetPos())
	prop:SetAngles(ang or weaponPlacer:GetGhostProp():GetAngles())

	prop:PhysicsInit(SOLID_VPHYSICS)

	prop:SetSolid(SOLID_VPHYSICS)

	prop:SetColor(Color(0, 255, 0))

	local phys = prop:GetPhysicsObject()

	if phys:IsValid() then
		phys:Wake()

		if self:GetSetting("freeze") or freeze then
			phys:EnableMotion(false)
		else
			if not self:GetSetting("collision") then
				prop:SetCollisionGroup(COLLISION_GROUP_WORLD)
			end

			phys:EnableMotion(true)
		end
	end

	return prop
end

function weaponPlacer:OpenMenu()
	if not self:CanUseWeaponPlacer() then
		return
	end

	if not self.menu or not self.menu:IsValid() then
		self.menu = vgui.Create("WepPlacerMenuFrame")
		self:GetSpawnableEntities()
		self:SetNoDrawMapWeapons(self:GetSetting("hideWeapons"))
	end

	self.menu:SetVisible(true)
	self.menu:MakePopup()
	self.menu:SetMouseInputEnabled(true)
	self.menu:SetKeyboardInputEnabled(false)
end

function weaponPlacer:CloseMenu(remove)
	if not IsValid(self.menu) then
		return
	end

	self.menu:SetVisible(false)

	if remove then
		self:ResetSettings()

		self.menu:Remove()
		hook.Remove("PlayerTick", "wep_placer_think")
	end
end

function weaponPlacer:Save()
	if not self:CanUseWeaponPlacer() then
		return
	end

	local buff = "setting:\treplacespawns %s\nsetting:\treplaceweapons %s\n"

	buff = string.format(buff, self:GetSetting("replaceSpawns") == true and "1" or "0", self:GetSetting("replaceWeapons") == true and "1" or "0")

	for _, entData in SortedPairsByMemberValue(self:GetSpawnedEntities(), "class", false) do
		local str = string.format("%s\t%s\t%s\n", entData.class, tostring(entData.prop:GetPos()), tostring(entData.prop:GetAngles()))
		buff = buff .. str
	end

	buff = util.Compress(buff)
	local len = buff:len()

	net.Start("WeaponPlacer.SaveScript")
		net.WriteUInt(len, 32)
		net.WriteData(buff, len)
	net.SendToServer()
end

function weaponPlacer:LoadScript(script)
	self:CleanUpProps()

	local entityList = self:GetEntitiesFromScript(script)

	for _, data in ipairs(entityList) do
		self:AddItem(data.class, data.pos, data.ang, true)
	end

	local settings = self:GetSettingsFromScript(script)

	if settings then
		self:SetSetting("replaceSpawns", tobool(settings.replacespawns), true)
		self:SetSetting("replaceWeapons", tobool(settings.replaceweapons), true)
	end

	chat.AddText(Color(0, 255, 0), "Weapon Placer: Loaded spawn script!")
end

function weaponPlacer:Load()
	if not self:CanUseWeaponPlacer() then
		return
	end

	net.Start("WeaponPlacer.LoadScript")
	net.SendToServer()
end

hook.Add("PostPlayerDraw", "WeaponPlacerHidePlayers", function(ply)
	if weaponPlacer:GetSetting("hidePlayers") then
		ply:SetNoDraw(true)
	end
end)

function weaponPlacer:SetNodrawPlayers(bool)
	for _, ply in ipairs(player.GetAll()) do
		ply:SetNoDraw(bool)
	end
end

function weaponPlacer:SetNoDrawMapWeapons(bool)
	-- overriding these functions is necessary because if setting nodraw then exiting and re-entering PVS would draw them again
	-- same for hiding players, hence the use of PostPlayerDraw
	for _, ent in ipairs(ents.GetAll()) do
		if bool then
			if ent:IsWeapon() then
				ent:SetNoDraw(true)
				ent.OldDrawWorldModel = ent.DrawWorldModel
				ent.DrawWorldModel = function()
					return
				end
			elseif ent.AmmoType then
				ent:SetNoDraw(true)
				ent.OldDraw = ent.Draw
				ent.Draw = function()
					return
				end
			end
		else
			if ent.OldDrawWorldModel then
				ent:SetNoDraw(false)
				ent.DrawWorldModel = ent.OldDrawWorldModel
			end

			if ent.OldDraw then
				ent.Draw = ent.OldDraw
			end
		end
	end
end

net.Receive("WeaponPlacer.SendScript", function()
	if not weaponPlacer:CanUseWeaponPlacer() then
		return
	end

	local len = net.ReadUInt(32)
	local script = net.ReadData(len)
	script = util.Decompress(script)

	weaponPlacer:LoadScript(script)
end)

net.Receive("WeaponPlacer.SendSpawnPoints", function()
	if not weaponPlacer:CanUseWeaponPlacer() then
		return
	end

	local spawnPoints = net.ReadTable()

	for entity, data in pairs(weaponPlacer:GetSpawnedEntities()) do
		if data.class == "info_player_deathmatch" then
			weaponPlacer:RemoveSpawnedEntity(entity)
		end
	end

	for _, spawn in ipairs(spawnPoints) do
		weaponPlacer:AddItem("info_player_deathmatch", spawn.pos, spawn.ang)
	end

	weaponPlacer:SetSetting("replaceSpawns", true, true)

	chat.AddText(Color(0, 255, 0), "Weapon Placer: Loaded spawnpoints!")
end)

net.Receive("WeaponPlacer.SendMapCreatedEntities", function()
	if not weaponPlacer:CanUseWeaponPlacer() then
		return
	end

	local mapEntities = net.ReadTable()

	for entity, data in pairs(weaponPlacer:GetSpawnedEntities()) do
		if data.class != "info_player_deathmatch" then
			weaponPlacer:RemoveSpawnedEntity(entity)
		end
	end

	for _, entData in ipairs(mapEntities) do
		weaponPlacer:AddItem(entData.class, entData.pos, entData.ang, true)
	end

	weaponPlacer:SetSetting("replaceWeapons", true, true)

	chat.AddText(Color(0, 255, 0), "Weapon Placer: Loaded map created entities!")
end)