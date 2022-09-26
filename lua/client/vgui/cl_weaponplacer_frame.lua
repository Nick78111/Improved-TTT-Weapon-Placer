local PANEL = {}

AccessorFunc(PANEL, "m_iHeaderHeight", "HeaderHeight", FORCE_NUMBER)
AccessorFunc(PANEL, "m_cHeaderColor", "HeaderColor", FORCE_COLOR)
AccessorFunc(PANEL, "m_cHeaderLineColor", "HeaderLineColor", FORCE_COLOR)
AccessorFunc(PANEL, "m_cBackgroundColor", "BackgroundColor", FORCE_COLOR)

function PANEL:Init()
	self:SetBackgroundColor(Color(0, 0, 0, 150))
	self:SetHeaderColor(Color(30, 30, 30, 255))
	self:SetHeaderLineColor(Color(94, 144, 175, 255))
	self:SetHeaderHeight(25)
	self:SetDraggable(false)
	self:ShowCloseButton(false)
	self:DockPadding(5, 30, 5, 5)

	self.lblTitle:SetTextColor(Color(135, 206, 250, 255))
	self.btnMaxim:Hide()
	self.btnMinim:Hide()

	self.btnClose.Paint = function(pnl, w, h)
		if pnl:IsVisible() then
			draw.RoundedBox(0, 5, 6, w - 6, h - 12, self.btnClose:IsHovered() and Color(255, 0, 0, 255) or Color(150, 0, 0, 255))
			draw.SimpleText("x", "DermaDefault", (w - 2.5)/2, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, self:GetBackgroundColor())
	draw.RoundedBox(0, 0, 0, w, self:GetHeaderHeight(), self:GetHeaderColor())
	draw.RoundedBox(0, 0, self:GetHeaderHeight(), w, 1, self:GetHeaderLineColor())
end

vgui.Register("WepPlacerDFrame", PANEL, "DFrame")