local PANEL = {}

function PANEL:Init()
	self.settings = {}

	self:SetSkin("WepPlacerSkin")

	self:Dock(FILL)
	self:InvalidateLayout(true)
	self:InvalidateParent(true)

	self:GetCanvas().VBar:SetWide(5)

	self:CreateSetting("Spawn Points", "Replace Spawns", 'Replace exisiting player spawnpoints or "Add" to them', "Boolean", "replaceSpawns", function(pnl, data)
		weaponPlacer:SetSetting("replaceSpawns", data == 1 and true or false)
	end)

	self:CreateSetting("Weapon Spawning", "Replace Weapons", "Replace existing weapon spawns or add to them", "Boolean", "replaceWeapons", function(pnl, data)
		weaponPlacer:SetSetting("replaceWeapons", data == 1 and true or false)
	end)

	self:CreateSetting("Weapon Spawning", "Spawn Ammo", "Spawns the currently selected weapon's ammo", "Boolean", "spawnAmmo", function(pnl, data)
		local bool = data == 1 and true or false

		weaponPlacer:SetSetting("spawnAmmo", bool)

		if not weaponPlacer:GetSelectedClass() then
			return
		end

		weaponPlacer:SelectClass(weaponPlacer:GetSelectedClass(), bool)
	end)

	self:CreateSetting("Weapon Spawning", "Enable Collisions", "Enables collisions with spawned entities (Don't recommend)", "Boolean", "collision", function(pnl, data)
		weaponPlacer:SetSetting("collision", data == 1 and true or false)
	end)

	self:CreateSetting("Weapon Spawning", "Freeze Entities", "Freezes spawned entities", "Boolean", "freeze", function(pnl, data)
		weaponPlacer:SetSetting("freeze", data == 1 and true or false)
	end)

	self:CreateSetting("Player", "Enable Noclip", "Enables noclip mode", "Boolean", "noclip", function(pnl, data)
		local bool = data == 1 and true or false
		weaponPlacer:SetNoclip(bool)
		weaponPlacer:SetSetting("noclip", bool)
	end)

	self:CreateSetting("Player", "Hide Map Entities", "Hide the current weapons and ammo on the map", "Boolean", "hideWeapons", function(pnl, data)
		local bool = data == 1 and true or false
		weaponPlacer:SetSetting("hideWeapons", bool)
		weaponPlacer:SetNoDrawMapWeapons(bool)
	end)

	self:CreateSetting("Player", "Hide Players", "Hide other players", "Boolean", "hideWeapons", function(pnl, data)
		local bool = data == 1 and true or false
		weaponPlacer:SetSetting("hidePlayers", bool)
		weaponPlacer:SetNodrawPlayers(bool)
	end)

	for name, cat in pairs(self.Categories) do
		cat.Label:SetFont("WeaponPlacerFont")

		cat.Container.Paint = function(self, w, h)
			return
		end

		cat.Header.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 255))
		end
	end
end

function PANEL:CreateButton(category, text, toolTip)
	local row = self:CreateRow(category, "")

	local button = vgui.Create("WepPlacerButton", row)
	button:SetText(text)

	button.PerformLayout = function(pnl, w, h)
		button:SetWide(self:GetCanvas():GetWide())
		button:SetTall(20)
	end

	return row
end

function PANEL:CreateSetting(category, name, toolTip, _type, settingName, callback)
	local setting = self:CreateRow(category, name)
	local val = weaponPlacer:GetSetting(settingName)

	setting:Setup(_type)
	setting:SetValue(val)

	setting.DataChanged = function(pnl, data)
		callback(setting, data)
	end

	setting:SetToolTip(toolTip)

	self.settings[settingName] = setting

	return setting
end

vgui.Register("WepPlacerSettings", PANEL, "DProperties")