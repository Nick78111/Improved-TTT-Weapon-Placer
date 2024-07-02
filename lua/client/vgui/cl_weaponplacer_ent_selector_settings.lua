local PANEL = {}

DEFINE_BASECLASS("DFrame")

function PANEL:Init()
	self:SetSize(500, 600)
	self:SetDraggable(true)
	self:ShowCloseButton(true)
	self:SetVisible(false)
	self:SetPos(weaponPlacer:GetMenu():GetPos())
	self:SetBackgroundColor(Color(60, 60, 60, 255))
	self:DockPadding(5, 30, 5, 5)
	self:DockMargin(0, 0, 0, 0)
	self:InvalidateLayout(true)
	self:InvalidateParent(true)

	self.btnMaxim:Hide()
	self.btnMinim:Hide()

	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)

	self:SetTitle("Entity Selector Settings")

	self.weaponGroupFrame = vgui.Create("WepPlacerDFrame", self)
	self.weaponGroupFrame:SetTitle("Entity Groups")
	self.weaponGroupFrame:DockMargin(0, 0, 0, 0)
	self.weaponGroupFrame:DockPadding(0, self:GetHeaderHeight() + 2, 0, 0)
	self.weaponGroupFrame:Dock(LEFT)
	self.weaponGroupFrame:SetWide(200)
	self.weaponGroupFrame:InvalidateLayout(true)
	self.weaponGroupFrame:InvalidateParent(true)

	self.selectorFrame = vgui.Create("WepPlacerDFrame", self)
	self.selectorFrame:SetTitle("Editor")
	self.selectorFrame:DockMargin(5, 0, 0, 0)
	self.selectorFrame:DockPadding(0, self:GetHeaderHeight() + 2, 0, 0)
	self.selectorFrame:Dock(RIGHT)
	self.selectorFrame:Dock(FILL)
	self.selectorFrame:InvalidateLayout(true)
	self.selectorFrame:InvalidateParent(true)

	self.weaponGroups = vgui.Create("WepPlacerCategoryList", self.weaponGroupFrame)
	self.weaponGroups:Dock(FILL)
	self.weaponGroups:InvalidateLayout(true)
	self.weaponGroups:InvalidateParent(true)

	for i = 1, 4 do
		self.weaponGroups:AddButtonToCategory("test"..i, "test")
	end
end

function PANEL:Open()
	weaponPlacer:CloseMenu()

	self:SetVisible(true)
	self:MakePopup()
	self:SetPos(weaponPlacer:GetMenu():GetPos())
end

function PANEL:Close()
	self:SetVisible(false)
	weaponPlacer:GetMenu():SetPos(self:GetPos())
end

function PANEL:Think()
	if self:IsVisible() and IsValid(weaponPlacer:GetMenu()) and weaponPlacer:GetMenu():IsVisible() then
		weaponPlacer:GetMenu():SetVisible(false)
	end

	BaseClass.Think(self)
end

vgui.Register("WePlacerEntitySelectorSettings", PANEL, "WepPlacerDFrame")