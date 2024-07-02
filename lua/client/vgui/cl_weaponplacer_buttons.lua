local PANEL = {}

function PANEL:Init()
	self:SetFont("Trebuchet24")
	self:SetTextColor(Color(255, 255, 255, 255))
	self.color = Color(75, 115, 140, 130)

	self:SetSkin("WepPlacerSkin")
end

function PANEL:Think()
	if self:IsHovered() then
		self:SetCursor("hand")
	end
end

function PANEL:DoClick(x, y)
	surface.PlaySound("ui/buttonclick.wav")

	if not self.OnClick then
		return
	end

	self:OnClick()
end

vgui.Register("WepPlacerButton", PANEL, "DButton")

local PANEL = {}

function PANEL:Init()
	self:SetText("Save")
	self:Dock(LEFT)
	self:DockMargin(0, 0, 5, 0)
	self:InvalidateLayout(true)
	self:InvalidateParent(true)
	self:SetWide(weaponPlacer:GetMenu().w / 2)
end

function PANEL:OnClick()
	weaponPlacer:Save()
end

vgui.Register("WepPlacerSaveButton", PANEL, "WepPlacerButton")

local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
	self:InvalidateLayout(true)
	self:InvalidateParent(true)
	self:SetText("Load")

	self.dMenu = DermaMenu(false, self:GetParent())
	self.dMenu:SetDeleteSelf(false)
	self.dMenu:Hide()

	self.dMenu:AddOption("Load map script", function()
		weaponPlacer:Load()
	end):SetIcon("icon16/script_go.png")

	self.dMenu:AddOption("Load spawnpoints from map", function()
		if not weaponPlacer:CanUseWeaponPlacer() then
			return
		end

		weaponPlacer:SetSetting("replaceSpawns", true, true)

		net.Start("WeaponPlacer.RequestSpawnPoints")
		net.SendToServer()
	end):SetIcon("icon16/script_go.png")

	self.dMenu:AddOption("Load weapons/ammo from map", function()
		if not weaponPlacer:CanUseWeaponPlacer() then
			return
		end

		weaponPlacer:SetSetting("replaceAmmo", true, true)

		net.Start("WeaponPlacer.RequestMapCreatedEntities")
		net.SendToServer()
	end):SetIcon("icon16/script_go.png")
end

function PANEL:OnClick()
	self.dMenu:Open()
end

vgui.Register("WepPlacerLoadButton", PANEL, "WepPlacerButton")

local PANEL = {}

function PANEL:Init()
	self:SetSize(16, 16)
	self:SetImage("icon16/script_delete.png")
	self:SetToolTip("Delete Map Script")
	self:Center()
	self:InvalidateLayout(true)
	self:InvalidateParent(true)

	self.dMenu = DermaMenu(false, self:GetParent())
	self.dMenu:SetDeleteSelf(false)
	self.dMenu:Hide()

	local label = vgui.Create("DLabel", self.dMenu)

	label:SetText("Delete Script?")
	label:SetContentAlignment(5)

	self.dMenu:AddPanel(label)
	self.dMenu:AddSpacer()

	self.dMenu:AddOption("Yes", function()
		if not weaponPlacer:CanUseWeaponPlacer() then
			return
		end

		weaponPlacer:SetSetting("replaceSpawns", false, true)
		weaponPlacer:SetSetting("replaceWeapons", false, true)

		net.Start("WeaponPlacer.DeleteMapScript")
		net.SendToServer()

		weaponPlacer:CleanUpProps()
	end):SetIcon("icon16/accept.png")

	self.dMenu:AddOption("No", function()
	end):SetIcon("icon16/cancel.png")
end

function PANEL:DoClick()
	surface.PlaySound("ui/buttonclick.wav")
	self.dMenu:Open()
end

function PANEL:OnMousePressed(mouseCode)
	if mouseCode != MOUSE_LEFT then
		return
	end

	DButton.OnMousePressed(self, mouseCode)
	self:DepressImage()
end

vgui.Register("WepPlacerTrashButton", PANEL, "DImageButton")

local PANEL = {}

function PANEL:Init()
	self.hoverColor = Color(255, 255, 255, 255)
	self.buttonColor = Color(190, 190, 190, 240)

	self:SetImage("icon16/cog_edit.png")
	self:SetColor(self.buttonColor)
	self:SizeToContents()
	self:SetDepressImage(false)
	self:SetPos(self:GetParent():GetWide() - self:GetWide() - 5, self:GetParent():GetHeaderHeight() / 2 - self:GetTall() / 2)
end

function PANEL:DoClick()
	surface.PlaySound("ui/buttonclick.wav")
	weaponPlacer:GetMenu().entitySelector.entitySelectorSettings:Open()
end

function PANEL:OnCursorEntered()
	self:SetColor(self.hoverColor)
end

function PANEL:OnCursorExited()
	self:SetColor(self.buttonColor)
end

vgui.Register("WepPlacerEntitySettingsButton", PANEL, "DImageButton")