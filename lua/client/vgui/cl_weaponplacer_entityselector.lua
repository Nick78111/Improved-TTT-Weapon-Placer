local PANEL = {}

function PANEL:Init()
	self:AddColumn("Type"):SetWidth(10)
	self:AddColumn("Class")
	self:SetMultiSelect(false)
	self:SetDrawBackground(false)
	self:Dock(FILL)

	local types = {}

	for _, entityData in pairs(weaponPlacer:GetSpawnableEntities()) do
		types[entityData.type] = types[entityData.type] or {}
		table.insert(types[entityData.type], entityData)
	end

	for _, entities in SortedPairs(types) do
		for _, entityData in SortedPairsByMemberValue(entities, "class", false) do
			local line = self:AddLine(entityData.type, entityData.class)
			line.data = entityData

			local buf = "Entity Information:"

			for k, v in pairs(entityData) do
				buf = buf .. "\n" .. k .. ": " .. tostring(v)
			end

			line:SetToolTip(buf)
		end
	end
end

function PANEL:OnRowSelected(indx, row)
	local line = self:GetLine(indx)
	weaponPlacer:SelectClass(line.data.class)
end

function PANEL:OnRowRightClick(lineID, line)
	local menu = DermaMenu()

	menu:AddOption("Delete all of type", function()
		local count = 0

		for entity, data in pairs(weaponPlacer:GetSpawnedEntities()) do
			if data.class == line:GetColumnText(2) then
				weaponPlacer:RemoveSpawnedEntity(entity)
				count = count + 1
			end
		end

		chat.AddText(Color(0, 255, 0), "Weapon Placer: Deleted " .. count .. " entities of type " .. line:GetColumnText(2))
	end):SetIcon("icon16/table_delete.png")

	menu:Open()
end

vgui.Register("WepPlacerEntitySelector", PANEL, "WepPlacerDListView")