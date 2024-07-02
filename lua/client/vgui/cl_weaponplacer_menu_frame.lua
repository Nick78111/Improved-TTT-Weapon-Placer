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

	self.btnMaxim:Hide()
	self.btnMinim:Hide()

	self.bottomPanel = vgui.Create("DPanel", self)
	self.bottomPanel:Dock(BOTTOM)
	self.bottomPanel:DockPadding(0, 0, 0, 0)
	self.bottomPanel:DockMargin(0, self.margin, 0, 0)
	self.bottomPanel:InvalidateLayout(true)
	self.bottomPanel:InvalidateParent(true)
	self.bottomPanel:SetTall(30)
	self.bottomPanel:SetPaintBackground(false)

	self.leftPanel = vgui.Create("DPanel", self)
	self.leftPanel:Dock(LEFT)
	self.leftPanel:DockPadding(0, 0, 0, 0)
	self.leftPanel:DockMargin(0, 0, self.margin, 0)
	self.leftPanel:InvalidateLayout(true)
	self.leftPanel:InvalidateParent(true)
	self.leftPanel:SetWide(self.w / 2)
	self.leftPanel:SetPaintBackground(false)

	self.rightPanel = vgui.Create("DPanel", self)
	self.rightPanel:Dock(FILL)
	self.rightPanel:DockPadding(0, 0, 0, 0)
	self.rightPanel:InvalidateLayout(true)
	self.rightPanel:InvalidateParent(true)
	self.rightPanel:SetPaintBackground(false)

	self.settingsFrame = vgui.Create("WepPlacerDFrame", self.leftPanel)
	self.settingsFrame:SetTitle("Settings")
	self.settingsFrame:Dock(TOP)
	self.settingsFrame:DockMargin(0, 0, 0, self.margin)
	self.settingsFrame:DockPadding(0, self.settingsFrame:GetHeaderHeight() + 4, 0, 0)
	self.settingsFrame:InvalidateLayout(true)
	self.settingsFrame:InvalidateParent(true)
	self.settingsFrame:SetTall((self.h - self.settingsFrame:GetHeaderHeight() - self:GetHeaderHeight() - self.margin) / 2)

	self.settings = vgui.Create("WepPlacerSettings", self.settingsFrame)

	self.spawnedEntitiesFrame = vgui.Create("WepPlacerDFrame", self.leftPanel)
	self.spawnedEntitiesFrame:SetTitle("Spawned Entities")
	self.spawnedEntitiesFrame:Dock(FILL)
	self.spawnedEntitiesFrame:DockPadding(0, self.spawnedEntitiesFrame:GetHeaderHeight() + 4, 0, 0)
	self.spawnedEntitiesFrame:InvalidateLayout(true)
	self.spawnedEntitiesFrame:InvalidateParent(true)

	self.spawnedEntities = vgui.Create("WepPlacerSpawnedEntities", self.spawnedEntitiesFrame)

	self.entitySelectorFrame = vgui.Create("WepPlacerDFrame", self.rightPanel)
	self.entitySelectorFrame:SetTitle("Entity Selector")
	self.entitySelectorFrame:DockPadding(0, self.entitySelectorFrame:GetHeaderHeight() + 2, 0, 0)
	self.entitySelectorFrame:Dock(FILL)
	self.entitySelectorFrame:InvalidateLayout(true)
	self.entitySelectorFrame:InvalidateParent(true)

	self.entitySelector = vgui.Create("WepPlacerEntitySelector", self.entitySelectorFrame)

	self.saveButton = vgui.Create("WepPlacerSaveButton", self.bottomPanel)
	self.loadButton = vgui.Create("WepPlacerLoadButton", self.bottomPanel)

	self.deletePanel = vgui.Create("DPanel", self.bottomPanel)
	self.deletePanel:Dock(RIGHT)
	self.deletePanel:DockPadding(0, 0, 0, 0)
	self.deletePanel:InvalidateLayout(true)
	self.deletePanel:InvalidateParent(true)
	self.deletePanel:SetWide(25)
	self.deletePanel:DockMargin(self.margin, 0, 0, 0)
	self.deletePanel:SetBackgroundColor(Color(0, 0, 0, 150))

	self.deleteButton = vgui.Create("WepPlacerTrashButton", self.deletePanel)
end

function PANEL:AddSpawnedEntity(prop, class)
	return self.spawnedEntities:AddButton(prop, class)
end

function PANEL:RemoveSpawnedEntity(prop)
	self.spawnedEntities:RemoveButton(prop.button)
end

function PANEL:GetSettingPanel(setting)
	return self.settings.settings[setting] or nil
end

vgui.Register("WepPlacerMenuFrame", PANEL, "WepPlacerDFrame")