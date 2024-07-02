local PANEL = {}

AccessorFunc(PANEL, "bRemoveEmptyCategories", "RemoveEmptyCategories", FORCE_BOOLEAN)

function PANEL:Init()
	self.categories = {}
	self:SetSkin("WepPlacerSkin")
	self.VBar:SetWide(5)
	self:SetRemoveEmptyCategories(false)
	self:CreateCollapseButton()
end

function PANEL:CreateCategory(category, randomize, custom)
	if self:GetCategoryPanelFromName(category) then
		return
	end

	local cat = self:Add(category)

	cat:SetExpanded(false)
	cat.countItems = false

	cat.SetCountItems = function(pnl, bool)
		cat.countItems = bool
		cat.UpdateLabelCount()
	end

	cat.UpdateLabelCount = function(pnl, text)
		if not cat.countItems then
			cat:SetLabel(category)
			return
		end

		cat:SetLabel(string.format(category .. " (%s)", tostring(#self:GetAllButtonsFromCategory(category))))
	end

	self.categories[category] = {
		category = cat,
		buttons = {}
	}
end

function PANEL:RemoveCategoryPanel(name)
	if IsValid(self:GetCategoryPanelFromName(name)) then
		self:GetCategoryPanelFromName(name):Remove()
		self.categories[name] = nil
	end
end

function PANEL:GetAllCategoryPanels()
	local tmp = {}

	for categoryName, tbl in pairs(self.categories) do
		table.insert(tmp, tbl.category)
	end

	return tmp
end

function PANEL:GetCategoryTableFromName(name)
	return self.categories[name]
end

function PANEL:GetCategoryPanelFromName(name)
	return self.categories[name] and self.categories[name].category or nil
end

function PANEL:AddButtonToCategory(item, category, toolTip)
	if not self:GetCategoryPanelFromName(category) then
		self:CreateCategory(category)
	end

	local cat = self:GetCategoryPanelFromName(category)
	local button = cat:Add(item)

	button.class = item
	button.category = category

	if toolTip then
		button:SetToolTip(toolTip)
	end

	button.DoClick = function()
		self:ButtonSelected(button, item)
	end

	button.DoRightClick = function()
		self:ButtonRightClicked(button, item)
	end

	table.insert(self.categories[category].buttons, button)

	cat:UpdateLabelCount()

	return button, cat
end

function PANEL:RemoveButton(button)
	if not IsValid(button) or not self:IsOurChild(button) then
		return
	end

	if self:GetRemoveEmptyCategories() then
		if #self:GetAllButtonsFromCategory(button.category) <= 1 then
			self:RemoveCategoryPanel(button.category)
			return
		end
	end

	table.RemoveByValue(self:GetCategoryTableFromName(button.category).buttons, button)

	self:GetCategoryPanelFromName(button.category):UpdateLabelCount()

	button:Remove()
end

function PANEL:GetAllButtons()
	local tmp = {}

	for categoryName, tbl in pairs(self.categories) do
		for _, button in ipairs(tbl.buttons) do
			table.insert(tmp, button)
		end
	end

	return tmp
end

function PANEL:GetAllButtonsFromCategory(name)
	local tmp = {}

	for _, button in ipairs(self:GetAllButtons()) do
		if button.category == name then
			table.insert(tmp, button)
		end
	end

	return tmp
end

function PANEL:CreateCollapseButton()
	self.collapseButton = vgui.Create("DImageButton", self:GetParent())
	self.collapseButton:SetImage("icon16/bullet_arrow_down.png")
	self.collapseButton:SizeToContents()

	local titleW, titleH = self:GetParent().lblTitle:GetTextSize()
	self.collapseButton:SetPos(titleW + 10, 5)

	self.collapseButton.collapse = false

	self.collapseButton.DoClick = function()
		for k,v in pairs(self.categories) do
			v.category:DoExpansion(not self.collapseButton.collapse)
		end

		self.collapseButton.collapse = not self.collapseButton.collapse
		self.collapseButton:SetImage(self.collapseButton.collapse and "icon16/bullet_arrow_up.png" or "icon16/bullet_arrow_down.png")
	end

	self.collapseButton.Think = function()
		for _, category in ipairs(self:GetAllCategoryPanels()) do
			if category:GetExpanded() and not self.collapseButton.collapse then
				self.collapseButton.collapse = true
				self.collapseButton:SetImage("icon16/bullet_arrow_up.png")
				return
			elseif self.collapseButton.collapse and category:GetExpanded() then
				return
			end
		end

		if self.collapseButton.collapse then
			self.collapseButton.collapse = false
			self.collapseButton:SetImage("icon16/bullet_arrow_down.png")
		end
	end
end

function PANEL:CreateDivider(text)
	local divider = vgui.Create("DLabel", self)

	divider:SetText(text)
	divider:SetContentAlignment(5)
	divider:SetTall(20)
	divider:SetTextColor(Color(135, 206, 250, 255))
	divider:SetFont("WeaponPlacerFont")

	divider.Paint = function(panel, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,80))
	end

	self:AddItem(divider)
end

function PANEL:ButtonSelected(panel, item) -- override
end

function PANEL:ButtonRightClicked(panel, item) -- override
end

vgui.Register("WepPlacerCategoryList", PANEL, "DCategoryList")