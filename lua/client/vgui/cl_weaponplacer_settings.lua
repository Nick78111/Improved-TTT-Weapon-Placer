local PANEL = {}

function PANEL:Init()
	local SKIN = table.Copy(derma.GetNamedSkin("Default"))
	SKIN.Colours.Properties.Title = {r = 135, g = 206, b = 250, a = 255} -- yeah...
	derma.DefineSkin("WepPlacerDprop", "Weapon Placer Dprop Skin", SKIN)

	self.settings = {}

	self:SetSkin("WepPlacerDprop")

	self:Dock(FILL)

	local vBar = self:GetCanvas():GetVBar()

	vBar:SetWide(7)
	vBar.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100)) end
	vBar.btnUp.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(135, 206, 250, 255)) end
	vBar.btnDown.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(135, 206, 250, 255)) end
	vBar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(135, 206, 250, 255)) end

	self:CreateSetting("SPAWNPOINTS", "Replace Spawns", 'Replace exisiting player spawnpoints or "Add" to them', "Boolean", "replaceSpawns", function(pnl, data)
		weaponPlacer:SetSetting("replaceSpawns", data == 1 and true or false)
	end)

	self:CreateSetting("WEAPON SPAWNING", "Spawn Ammo", "Spawns the currently selected weapon's ammo", "Boolean", "spawnAmmo", function(pnl, data)
		weaponPlacer:SetSetting("spawnAmmo", data == 1 and true or false)

		if not weaponPlacer:GetSelectedClass() then
			return
		end

		local id, line = weaponPlacer.menu.entitySelector:GetSelectedLine()

		if line then
			weaponPlacer:SelectClass(line.data.class)
		end
	end)

	self:CreateSetting("WEAPON SPAWNING", "Enable Collisions", "Enables collisions with spawned entities (Don't recommend)", "Boolean", "collision", function(pnl, data)
		weaponPlacer:SetSetting("collision", data == 1 and true or false)
	end)

	self:CreateSetting("WEAPON SPAWNING", "Freeze Entities", "Freezes spawned entities", "Boolean", "freeze", function(pnl, data)
		weaponPlacer:SetSetting("freeze", data == 1 and true or false)
	end)

	self:CreateSetting("PLAYER", "Enable Noclip", "Enables noclip mode", "Boolean", "noclip", function(pnl, data)
		local bool = data == 1 and true or false
		weaponPlacer:SetNoclip(bool)
		weaponPlacer:SetSetting("noclip", bool)
	end)

	self:CreateSetting("WORLD", "Hide Map Entities", "Hide the current weapons and ammo on the map", "Boolean", "hideWeapons", function(pnl, data)
		local bool = data == 1 and true or false
		weaponPlacer:SetSetting("hideWeapons", bool)
		weaponPlacer:SetNoDrawMapWeapons(bool)
	end)

	self:CreateSetting("WORLD", "Hide Players", "Hide other players", "Boolean", "hideWeapons", function(pnl, data)
		local bool = data == 1 and true or false
		weaponPlacer:SetSetting("hidePlayers", bool)
		weaponPlacer:SetNodrawPlayers(bool)
	end)

	for name, cat in pairs(self.Categories) do
		cat.Paint = function(self, w, h)
			return
		end

		cat.Container.Paint = function(self, w, h)
			return
		end

		cat.Header.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 255))
		end

		for rName, row in pairs(cat.Rows) do
			row.Label:SetFont("DermaDefault")
			row.Label:SetTextColor(Color(255, 255, 255, 255))

			row.Paint = function(self, w, h)
				return
			end

			row.Panel.Paint = function(self, w, h)
				return
			end
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