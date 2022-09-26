local PANEL = {}

DEFINE_BASECLASS("DListView")

AccessorFunc(PANEL, "m_cHeaderColor", "HeaderColor", FORCE_COLOR)

function PANEL:Init()
	self.lineCol = true

	self:SetHeaderColor(Color(94, 144, 175, 255))

	self:SetSortable(false)

	self.VBar:SetWide(7)
	self.VBar.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100)) end
	self.VBar.btnUp.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(135, 206, 250, 255)) end
	self.VBar.btnDown.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(135, 206, 250, 255)) end
	self.VBar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(135, 206, 250, 255)) end
end

function PANEL:AddColumn(...)
	local column = BaseClass.AddColumn(self, ...)

	column.Header.Paint = function(pnl, w, h)
		draw.RoundedBox(0, 0, 0, w, h, self:GetHeaderColor())
	end

	column.Header:SetTextColor(Color(255, 255, 255, 255))
	column.Header:SetFont("Trebuchet18")

	return column
end

function PANEL:PerformLayout()
	local Wide = self:GetWide()
	local YPos = 0

	if (IsValid(self.VBar)) then
		self.VBar:SetPos(self:GetWide() - self.VBar:GetWide(), 0)
		self.VBar:SetSize(self.VBar:GetWide(), self:GetTall())
		self.VBar:SetUp(self.VBar:GetTall() - self:GetHeaderHeight(), self.pnlCanvas:GetTall())
		YPos = self.VBar:GetOffset()

		if self.VBar.Enabled then Wide = Wide - self.VBar:GetWide() end
	end

	if self.m_bHideHeaders then
		self.pnlCanvas:SetPos(0, YPos)
	else
		self.pnlCanvas:SetPos(0, YPos + self:GetHeaderHeight())
	end

	self.pnlCanvas:SetSize(Wide, self.pnlCanvas:GetTall())

	self:FixColumnsLayout()

	if self:GetDirty() then
		self:SetDirty(false)
		local y = self:DataLayout()
		self.pnlCanvas:SetTall(y)

		self:InvalidateLayout(true)
	end
end

function PANEL:Paint(w, h)
	if not self:GetDrawBackground() then
		return
	end

	draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
end

function PANEL:AddLine(...)
	local line = BaseClass.AddLine(self, ...)

	local _linecol = self.lineCol and Color(0, 0, 0, 100) or Color(0, 0, 0, 20)
	local hoverColor = Color(135, 206, 250, 50)

	line.Paint = function(self, w, h)
		if self:IsHovered() then
			self:SetCursor("hand")
		end

		draw.RoundedBox(0, 0, 0, w, h, (self:IsHovered() or self:IsSelected()) and hoverColor or _linecol)
	end

	for _, label in ipairs(line.Columns) do
		label:SetTextColor(Color(255, 255, 255, 255))
	end

	self.lineCol = not self.lineCol

	return line
end

-- simple hack to update 'scrollpanel' and remove void space when removing lines
function PANEL:RemoveLine(...)
	BaseClass.RemoveLine(self, ...)
	self.VBar:AnimateTo( self.VBar:GetScroll(), 0, 0, 1 )
end

vgui.Register("WepPlacerDListView", PANEL, "DListView")