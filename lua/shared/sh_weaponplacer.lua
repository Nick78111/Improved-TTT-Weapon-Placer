weaponPlacer = weaponPlacer or {}
weaponPlacer.CAMI = weaponPlacer.CAMI or false

weaponPlacer.CAMIPrivilege = {
	Name = "weaponplacer",
	MinAccess = "superadmin",
	Description = "Gives weapon placer"
}

function weaponPlacer:GetCAMI()
	if self.CAMI then
		return true
	end

	if CAMI then
		CAMI.RegisterPrivilege(self.CAMIPrivilege)
		self.CAMI = true

		return true
	end

	return false
end

function weaponPlacer:CanUseWeaponPlacer(ply)
	ply = CLIENT and LocalPlayer() or ply

	if not IsValid(ply) then
		return false
	end

	if ULib then -- if ULX is available use it
		if not ply:query("ulx weaponplacer") then
			return false
		end

		return true
	end

	if self:GetCAMI() then -- if CAMI is available use it, im too lazy to include it
		if not CAMI.PlayerHasAccess(ply, "weaponplacer") then
			return false
		end

		return true
	end

	-- if neither, check if user is superadmin

	if SERVER then
		if not ply:IsFullyAuthenticated() then
			return false
		end
	end

	if not ply:IsSuperAdmin() then
		return false
	end

	return true
end

function weaponPlacer:GetEntitiesFromScript(spawnScript)
	local ents = {}

	for i, line in ipairs(string.Explode("\n", spawnScript)) do
		local tmp = {}

		if not string.match(line, "^#") and not string.match(line, "^setting") and line ~= "" and string.byte(line) ~= 0 then
			local data = string.Explode("\t", line)
			local fail = true

			if data[2] and data[3] then
				local class = data[1]
				local ang = nil
				local pos = nil

				local posRaw = string.Explode(" ", data[2])
				pos = Vector(tonumber(posRaw[1]), tonumber(posRaw[2]), tonumber(posRaw[3]))

				local angRaw = string.Explode(" ", data[3])
				ang = Angle(tonumber(angRaw[1]), tonumber(angRaw[2]), tonumber(angRaw[3]))

				local kv = {}

				if data[4] then
					local kvRaw = string.Explode(" ", data[4])
					local key = kvRaw[1]
					local val = tonumber(kvRaw[2])

					if key and val then
						kv[key] = val
					end
				end

				tmp = {
					class = class,
					ang = ang,
					pos = pos,
					kv = kv
				}

				table.insert(ents, tmp)
			end
		end
	end

	return ents
end

function weaponPlacer:GetSettingsFromScript(spawnScript)
	local script = SERVER and self:GetCurrentMapScript() or spawnScript

	if not script then
		return
	end

	local settings = {}
	local lines = string.Explode("\n", script)

	for i, line in ipairs(lines) do
		if string.match(line, "^setting") then
			local key, val = string.match(line, "^setting:\t(%w*) ([0-9]*)")
			val = tonumber(val)

			if key and val then
				settings[key] = val
			else
				ErrorNoHalt("Invalid weapon placer setting line " .. i .. " in " .. fileName .. "\n")
			end
		end
	end

	return settings
end