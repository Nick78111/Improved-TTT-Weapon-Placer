util.AddNetworkString("WeaponPlacer.SetNoclip")
util.AddNetworkString("WeaponPlacer.TeleportToWeapon")
util.AddNetworkString("WeaponPlacer.SaveScript")
util.AddNetworkString("WeaponPlacer.LoadScript")
util.AddNetworkString("WeaponPlacer.SendScript")
util.AddNetworkString("WeaponPlacer.RequestSpawnPoints")
util.AddNetworkString("WeaponPlacer.SendSpawnPoints")
util.AddNetworkString("WeaponPlacer.DeleteMapScript")
util.AddNetworkString("WeaponPlacer.RequestMapCreatedEntities")
util.AddNetworkString("WeaponPlacer.SendMapCreatedEntities")

CreateConVar("weapon_placer_enabled", 1, FCVAR_ARCHIVE, "Enable/Disable weapon spawn script", 0, 1)

concommand.Add("weaponplacer", function(ply, cmd, args, str)
	if IsValid(ply) then
		ply:Give("ttt_weapon_placer")
	end
end)

weaponPlacer.mapSpawnPoints = weaponPlacer.mapSpawnPoints or nil

function weaponPlacer:GetCurrentMapScript(useTTT)
	local map = game.GetMap()
	local fileName = self:GetCurrentMapScriptName(useTTT)
	return file.Read(fileName, useTTT and "GAME" or "DATA")
end

function weaponPlacer:GetCurrentMapScriptName(useTTT)
	local map = game.GetMap()
	return useTTT and "maps/" .. map .. "_ttt.txt" or "weaponplacer/maps/" .. map .. ".txt"
end

function weaponPlacer:SetNoclip(ply, bool)
	if not self:CanUseWeaponPlacer(ply) then
		return
	end

	ply:SetMoveType(bool == true and MOVETYPE_NOCLIP or MOVETYPE_WALK)
end

local preventWin = false

function weaponPlacer:PauseRound()
	preventWin = GetConVar("ttt_debug_preventwin"):GetBool()

	timer.Stop("wait2prep")
	timer.Stop("prep2begin")
	timer.Stop("end2prep")
	timer.Stop("winchecker")

	GetConVar("ttt_debug_preventwin"):SetBool(true)

	SetRoundState(ROUND_PREP)
end

function weaponPlacer:RestartRound()
	if not preventWin then
		GetConVar("ttt_debug_preventwin"):SetBool(false)
	end

	RunConsoleCommand("ttt_roundrestart")
end

function weaponPlacer:DeleteCurrentMapScript()
	local fileName = self:GetCurrentMapScriptName()
	file.Delete(fileName)
end

function weaponPlacer:SaveScript(str, ply)
	if not weaponPlacer:CanUseWeaponPlacer(ply) then
		return
	end

	local map = game.GetMap()

	local buff = [[
# Trouble in Terrorist Town weapon/ammo placement overrides
# For map: %s
# Exported by: %s
]]
	buff = string.format(buff, map, ply:Nick())

	buff = buff .. str

	local fileName = self:GetCurrentMapScriptName()

	file.CreateDir("weaponplacer/maps")
	file.Write(fileName, buff)

	if ents.FindByClass("info_player_start") then
		--ply:SendLua('chat.AddText(Color(255, 255, 0), [[Weapon Placer: Warning! This map uses info_player_start for spawning. Creating your own spawns are recommended]])')
	end

	ply:SendLua('chat.AddText(Color(0, 255, 0), "Weapon Placer: Entity spawns saved!")')
end

function weaponPlacer:ConvertCurrentMapScriptToWeaponPlacerScript()
	local tttFileName = self:GetCurrentMapScriptName(true)
	local weaponPlacerFileName = self:GetCurrentMapScriptName()

	if not file.Exists(tttFileName, "GAME") then
		return false
	end

	if file.Exists(weaponPlacerFileName, "DATA") then
		return false
	end

	local script = self:GetCurrentMapScript(true)

	file.CreateDir("weaponplacer/maps", "DATA")
	file.Write(weaponPlacerFileName, script)
end

function weaponPlacer:SendPlayerScript(ply)
	if not self:CanUseWeaponPlacer(ply) then
		return
	end

	local script = self:GetCurrentMapScript()

	if not script then
		ply:SendLua('chat.AddText(Color(255, 0, 0), "Weapon Placer: This map does not have a spawn script!")')
		return
	end

	script = util.Compress(script)
	local len = script:len()

	net.Start("WeaponPlacer.SendScript")
		net.WriteUInt(len, 32)
		net.WriteData(script, len)
	net.Send(ply)
end

function weaponPlacer:SendMapSpawnPoints(ply)
	if not self:CanUseWeaponPlacer(ply) then
		return
	end

	if not self.mapSpawnPoints or table.IsEmpty(self.mapSpawnPoints) then
		ply:SendLua("chat.AddText(Color(255, 0, 0), 'Weapon Placer: This map has no spawnpoints!')")
		return
	end

	net.Start("WeaponPlacer.SendSpawnPoints")
		-- Using WriteTable should be safe on the server since this requires superadmin privileges,
		-- if your admins are crashing your server, not my problem...
		net.WriteTable(self.mapSpawnPoints)
	net.Send(ply)
end

function weaponPlacer:SendMapCreatedEntities(ply)
	if not self:CanUseWeaponPlacer(ply) then
		return
	end

	if not self.mapEntities or table.IsEmpty(self.mapEntities) then
		ply:SendLua("chat.AddText(Color(255, 0, 0), 'Weapon Placer: This map has no weapon or ammo spawns!')")
		return
	end

	net.Start("WeaponPlacer.SendMapCreatedEntities")
		net.WriteTable(self.mapEntities)
	net.Send(ply)
end

net.Receive("WeaponPlacer.SetNoclip", function(len, ply)
	if not weaponPlacer:CanUseWeaponPlacer(ply) then
		return
	end

	local bool = net.ReadBool()

	weaponPlacer:SetNoclip(ply, bool)
end)

net.Receive("WeaponPlacer.TeleportToWeapon", function(len, ply)
	if not weaponPlacer:CanUseWeaponPlacer(ply) then
		return
	end

	local wep = ply:GetActiveWeapon()

	if IsValid(wep) and wep:GetClass() == "ttt_weapon_placer" then
		local pos = net.ReadVector()
		ply:SetPos(pos)
		ply:SetEyeAngles(Angle(90, 0, 0))
	end
end)

net.Receive("WeaponPlacer.SaveScript", function(len, ply)
	if not weaponPlacer:CanUseWeaponPlacer(ply) then
		return
	end

	local len = net.ReadUInt(32)

	local str = net.ReadData(len)
	str = util.Decompress(str)

	weaponPlacer:SaveScript(str, ply)
end)

net.Receive("WeaponPlacer.LoadScript", function(len, ply)
	weaponPlacer:SendPlayerScript(ply)
end)

net.Receive("WeaponPlacer.RequestSpawnPoints", function(len, ply)
	weaponPlacer:SendMapSpawnPoints(ply)
end)

net.Receive("WeaponPlacer.RequestMapCreatedEntities", function(len, ply)
	weaponPlacer:SendMapCreatedEntities(ply)
end)

net.Receive("WeaponPlacer.DeleteMapScript", function(len, ply)
	if not weaponPlacer:CanUseWeaponPlacer(ply) then
		return
	end

	weaponPlacer:DeleteCurrentMapScript()

	ply:SendLua("chat.AddText(Color(0, 255, 0), 'Weapon Placer: Spawn script deleted!')")
end)

hook.Add("PlayerCanPickupWeapon", "WeaponPlacerPickupWeapon", function(ply, wep)
	if IsValid(ply:GetWeapon("ttt_weapon_placer")) then
		return false
	end

	if wep:GetClass() == "ttt_weapon_placer" then
		if not weaponPlacer:CanUseWeaponPlacer(ply) then
			return false
		else
			ply:StripWeapons()
			ply:GodEnable()
			weaponPlacer:PauseRound()
			return true
		end
	end
end)

hook.Add("PlayerDroppedWeapon", "WeaponPlacerDroppedWeapon", function(ply, wep)
	if wep:GetClass() == "ttt_weapon_placer" and weaponPlacer:CanUseWeaponPlacer(ply) then
		weaponPlacer:RestartRound()
		ply:GodDisable()
	end
end)

hook.Add("PlayerDisconnected", "WeaponPlacerPlayerDropped", function(ply)
	if IsValid(ply:GetWeapon("ttt_weapon_placer")) then
		weaponPlacer:RestartRound()
	end
end)

hook.Add("Initialize", "WeaponPlacerDisableSpawnScripts", function()
	if not GetConVar("weapon_placer_enabled"):GetBool() then
		return
	end

	GetConVar("ttt_use_weapon_spawn_scripts"):SetBool(false)
end)

hook.Add("InitPostEntity", "WeaponPlacerGetMapEntities", function()
	if not GetConVar("weapon_placer_enabled"):GetBool() then
		return
	end

	if not weaponPlacer.mapEntities then
		weaponPlacer.mapEntities = {}

		 for _, class in ipairs(ents.TTT.GetSpawnableAmmo()) do
			for _, ent in ipairs(ents.FindByClass(class)) do
				if ent:CreatedByMap() then
					table.insert(weaponPlacer.mapEntities, {
						class = class,
						pos = ent:GetPos(),
						ang = ent:GetAngles()
					})
				end
			end
		end

		for _, spawnableEnt in ipairs(ents.TTT.GetSpawnableSWEPs()) do
			local class = WEPS.GetClass(spawnableEnt)
			for _, ent in ipairs(ents.FindByClass(class)) do
				if ent:CreatedByMap() then
					table.insert(weaponPlacer.mapEntities, {
						class = class,
						pos = ent:GetPos(),
						ang = ent:GetAngles()
					})
				end
			end
		end

		for _, ent in ipairs(ents.FindByClass("ttt_random_ammo")) do
			if ent:CreatedByMap() then
				table.insert(weaponPlacer.mapEntities, {
					class = "ttt_random_ammo",
					pos = ent:GetPos(),
					ang = ent:GetAngles()
				})
			end
		end

		for _, ent in ipairs(ents.FindByClass("ttt_random_weapon")) do
			if ent:CreatedByMap() then
				table.insert(weaponPlacer.mapEntities, {
					class = "ttt_random_weapon",
					pos = ent:GetPos(),
					ang = ent:GetAngles()
				})
			end
		end
	end

	if not weaponPlacer.mapSpawnPoints then
		weaponPlacer.mapSpawnPoints = {}

		local spawnEntities = GetSpawnEnts(false, true)

		if spawnEntities then
			for i, ent in ipairs(spawnEntities) do
				weaponPlacer.mapSpawnPoints[i] = {
					pos = ent:GetPos(),
					ang = ent:GetAngles()
				}
			end
		end
	end
end)