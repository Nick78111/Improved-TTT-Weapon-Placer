local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
	self:InvalidateLayout(true)
	self:InvalidateParent(true)
	self:SetBackgroundColor(Color(0, 0, 0, 0))

	self.removeEmptyCategories = false

	self.entitySelectorSettings = vgui.Create("WePlacerEntitySelectorSettings")
	--self.settingsButton = vgui.Create("WepPlacerEntitySettingsButton", self:GetParent())

	self:CreateDivider("Default Groups")

	self:CreateCategory("Player Spawn")
	self:CreateCategory("Ammo")
	self:CreateCategory("Weapons")
	self:CreateCategory("Role Weapons")
	self:CreateCategory("Random")

	for _, entData in SortedPairs(weaponPlacer:GetSpawnableEntities()) do
		local toolTip = "Entity Information:"

		for k,v in pairs(entData) do
			toolTip = toolTip .. "\n" .. k .. ": " .. tostring(v)
		end

		self:AddButtonToCategory(entData.class, entData.type, toolTip)
	end
end

function PANEL:ButtonSelected(panel, item)
	weaponPlacer:SelectClass(item)
end

function PANEL:ButtonRightClicked(panel, item)
	local dMenu = DermaMenu()

	dMenu:AddOption("Delete all of type", function()
		local count = 0

		for entity, data in pairs(weaponPlacer:GetSpawnedEntities()) do
			if data.class == item then
				weaponPlacer:RemoveSpawnedEntity(entity)
				count = count + 1
			end
		end

		chat.AddText(Color(0, 255, 0), "Weapon Placer: Deleted " .. count .. " entities of type " .. item)
	end):SetIcon("icon16/table_delete.png")

	dMenu:Open()
end

function PANEL:OnRemove()
	if IsValid(self.entitySelectorSettings) then
		self.entitySelectorSettings:Remove()
	end
end

vgui.Register("WepPlacerEntitySelector", PANEL, "WepPlacerCategoryList")