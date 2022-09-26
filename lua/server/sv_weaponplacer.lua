util.AddNetworkString("WeaponPlacer.SettingChanged")
util.AddNetworkString("WeaponPlacer.TeleportToWeapon")
util.AddNetworkString("WeaponPlacer.SaveScript")
util.AddNetworkString("WeaponPlacer.LoadScript")
util.AddNetworkString("WeaponPlacer.SendScript")
util.AddNetworkString("WeaponPlacer.RequestSpawnPoints")
util.AddNetworkString("WeaponPlacer.SendSpawnPoints")
util.AddNetworkString("WeaponPlacer.DeleteMapScript")

CreateConVar("weapon_placer_enabled", 1, FCVAR_ARCHIVE, "Enable/Disable weapon spawn script", 0, 1)

weaponPlacer.mapSpawnPoints = weaponPlacer.mapSpawnPoints or nil

function weaponPlacer:GetCurrentMapScript(useTTT)
	local map = game.GetMap()
	local fileName = self:GetCurrentMapScriptName(useTTT)
	return file.Read(fileName, useTTT and "MOD" or "DATA")
end

function weaponPlacer:GetCurrentMapScriptName(useTTT)
	local map = game.GetMap()
	return useTTT and "maps/" .. map .. "_ttt.txt" or "weaponplacer/maps/" .. map .. ".txt"
end

function weaponPlacer:ChangeSetting(ply, setting, bool)
	if not self:CanUseWeaponPlacer(ply) then
		return
	end

	if setting == 0 then
		if bool == true then
			ply:SetMoveType(MOVETYPE_NOCLIP)
		else
			ply:SetMoveType(MOVETYPE_WALK)
		end
	end
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

	if not file.Exists(tttFileName, "MOD") then
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

	if not self.mapSpawnPoints or #self.mapSpawnPoints == 0 then
		ply:SendLua("chat.AddText(Color(255, 0, 0), 'Weapon Placer: This map has no spawnpoints!')")
		return
	end

	net.Start("WeaponPlacer.SendSpawnPoints")
		-- Using WriteTable should be safe on the server since this requires superadmin privileges,
		-- if your admins are crashing your server, not my problem...
		net.WriteTable(self.mapSpawnPoints)
	net.Send(ply)
end

net.Receive("WeaponPlacer.SettingChanged", function(len, ply)
	if not weaponPlacer:CanUseWeaponPlacer(ply) then
		return
	end

	local settingType = net.ReadInt(1)
	local settingBool = net.ReadBool()

	weaponPlacer:ChangeSetting(ply, settingType, settingBool)
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