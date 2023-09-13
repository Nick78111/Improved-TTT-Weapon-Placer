local PANEL = {}

function PANEL:Init()
	weaponPlacer.menu = self

	self.w, self.h = 500, 600
	self.margin = 5

	self:SetTitle("TTT Weapon Placer")
	self:SetSize(self.w, self.h)
	self:SetPos(10, 10)
	self:ShowCloseButton(false)
	self:SetDraggable(true)
	self:SetBackgroundColor(Color(60, 60, 60, 255))
	self:SetVisible(false)

	self.btnMaxim:Hide()
	self.btnMinim:Hide()

	self.btnClose.DoClick = function()
		self:Remove()
	end

	self.bottomPanel = vgui.Create("DPanel", self)
	self.bottomPanel:Dock(BOTTOM)
	self.bottomPanel:DockPadding(0, 0, 0, 0)
	self.bottomPanel:DockMargin(0, self.margin, 0, 0)
	self.bottomPanel:SetTall(35)
	self.bottomPanel:SetPaintBackground(false)

	self.leftPanel = vgui.Create("DPanel", self)
	self.leftPanel:Dock(LEFT)
	self.leftPanel:DockPadding(0, 0, 0, 0)
	self.leftPanel:DockMargin(0, 0, self.margin, 0)
	self.leftPanel:SetWide(self.w / 2)
	self.leftPanel:SetPaintBackground(false)

	self.rightPanel = vgui.Create("DPanel", self)
	self.rightPanel:Dock(FILL)
	self.rightPanel:DockPadding(0, 0, 0, 0)
	self.rightPanel:SetPaintBackground(false)

	self.settingsFrame = vgui.Create("WepPlacerDFrame", self.leftPanel)
	self.settingsFrame:SetTitle("Settings")
	self.settingsFrame:Dock(TOP)
	self.settingsFrame:DockMargin(0, 0, 0, self.margin)
	self.settingsFrame:DockPadding(0, self.settingsFrame:GetHeaderHeight() + 2, 0, 0)
	self.settingsFrame:SetTall((self.h - self.settingsFrame:GetHeaderHeight() - self:GetHeaderHeight() - self.margin) / 2)

	self.settings = vgui.Create("WepPlacerSettings", self.settingsFrame)

	self.spawnedEntitiesFrame = vgui.Create("WepPlacerDFrame", self.leftPanel)
	self.spawnedEntitiesFrame:SetTitle("Spawned Entities")
	self.spawnedEntitiesFrame:Dock(FILL)
	self.spawnedEntitiesFrame:DockPadding(0, self.spawnedEntitiesFrame:GetHeaderHeight() + 2, 0, 0)

	self.spawnedEntities = vgui.Create("WepPlacerSpawnedEntities", self.spawnedEntitiesFrame)

	self.entitySelectorFrame = vgui.Create("WepPlacerDFrame", self.rightPanel)
	self.entitySelectorFrame:SetTitle("Entity Selector")
	self.entitySelectorFrame:DockPadding(0, self.entitySelectorFrame:GetHeaderHeight() + 2, 0, 0)
	self.entitySelectorFrame:Dock(FILL)

	self.entitySelector = vgui.Create("WepPlacerEntitySelector", self.entitySelectorFrame)

	self.saveButton = vgui.Create("WepPlacerButton", self.bottomPanel)
	self.saveButton:SetText("Save")
	self.saveButton:Dock(LEFT)
	self.saveButton:DockMargin(0, 0, 5, 0)
	self.saveButton:SetWide(self.w / 2)

	function self.saveButton:OnClick()
		weaponPlacer:Save()
	end

	self.loadButton = vgui.Create("WepPlacerButton", self.bottomPanel)
	self.loadButton:Dock(FILL)
	self.loadButton:SetText("Load")
	self.loadButton:SetToolTip("Loads the current map's spawn script")

	function self.loadButton:OnClick()
		local menu = DermaMenu(true, self.loadButton)

		menu:AddOption("Load map script", function()
			weaponPlacer:Load()
		end):SetIcon("icon16/script_go.png")

		menu:AddOption("Load spawnpoints from map", function()
			if not weaponPlacer:CanUseWeaponPlacer() then
				return
			end

			weaponPlacer:SetSetting("replaceSpawns", true, true)

			net.Start("WeaponPlacer.RequestSpawnPoints")
			net.SendToServer()
		end):SetIcon("icon16/script_go.png")

		menu:AddOption("Load weapons/ammo from map", function()
			if not weaponPlacer:CanUseWeaponPlacer() then
				return
			end

			weaponPlacer:SetSetting("replaceAmmo", true, true)

			net.Start("WeaponPlacer.RequestMapCreatedEntities")
			net.SendToServer()
		end):SetIcon("icon16/script_go.png")

		menu:AddOption("Delete map script", function()
			if not weaponPlacer:CanUseWeaponPlacer() then
				return
			end

			weaponPlacer:SetSetting("replaceSpawns", false, true)
			weaponPlacer:SetSetting("replaceWeapons", false, true)

			net.Start("WeaponPlacer.DeleteMapScript")
			net.SendToServer()

			weaponPlacer:CleanUpProps()
		end):SetIcon("icon16/delete.png")

		menu:Open()
	end
end

function PANEL:AddSpawnedEntity(spawnedEntity, class)
	return self.spawnedEntities:AddEntity(spawnedEntity, class)
end

function PANEL:RemoveSpawnedEntity(line)
	self.spawnedEntities:RemoveLine(line:GetID())
end

function PANEL:GetSettingPanel(setting)
	return self.settings.settings[setting] or nil
end

vgui.Register("WepPlacerMenuFrame", PANEL, "WepPlacerDFrame")