local PANEL = {}

function PANEL:Init()
	self:SetFont("Trebuchet24")
	self:SetTextColor(Color(255, 255, 255, 255))
	self.color = Color(75, 115, 140, 130)
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

function PANEL:OnCursorEntered()
	self.color = Color(94, 144, 175, 255)
end

function PANEL:OnCursorExited()
	self.color = Color(75, 115, 140, 130)
end

function PANEL:Paint(w, h)
	draw.RoundedBox(3, 0, 0, w, h, self.color)
end

vgui.Register("WepPlacerButton", PANEL, "DButton")