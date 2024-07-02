local PANEL = {}

AccessorFunc(PANEL, "iHeaderHeight", "HeaderHeight", FORCE_NUMBER)
AccessorFunc(PANEL, "cHeaderColor", "HeaderColor", FORCE_COLOR)
AccessorFunc(PANEL, "cHeaderLineColor", "HeaderLineColor", FORCE_COLOR)
AccessorFunc(PANEL, "cBackgroundColor", "BackgroundColor", FORCE_COLOR)

function PANEL:Init()
	self:SetBackgroundColor(Color(0, 0, 0, 150))
	self:SetHeaderColor(Color(30, 30, 30, 255))
	self:SetHeaderLineColor(Color(94, 144, 175, 255))
	self:SetHeaderHeight(25)
	self:SetDraggable(false)
	self:ShowCloseButton(false)
	self:DockPadding(5, 30, 5, 5)
	self:InvalidateLayout(true)
	self:InvalidateParent(true)
	self:SetSkin("WepPlacerSkin")


	self.lblTitle:SetTextColor(Color(135, 206, 250, 255))
	self.lblTitle:SetFont("CreditsText")
	self.btnMaxim:Hide()
	self.btnMinim:Hide()
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, self:GetBackgroundColor())
	draw.RoundedBox(0, 0, 0, w, self:GetHeaderHeight(), self:GetHeaderColor())
	draw.RoundedBox(0, 0, self:GetHeaderHeight(), w, 1, self:GetHeaderLineColor())
end

vgui.Register("WepPlacerDFrame", PANEL, "DFrame")