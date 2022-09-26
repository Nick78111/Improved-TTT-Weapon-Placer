local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
	self:SetMultiSelect(true)
	self:SetDrawBackground(false)

	self:AddColumn("Type"):SetWidth(10)
	self:AddColumn("Class")
end

function PANEL:AddEntity(spawnedEntity, class)
	local spawnableEntity = weaponPlacer:GetSpawnableEntityFromClass(class)
	local line = self:AddLine(spawnableEntity.type, class)
	line.prop = spawnedEntity

	return line
end

function PANEL:Refresh()
	self:Clear()

	for _, spawnedEntity in ipairs(weaponPlacer:GetSpawnedEntities()) do
		self:AddEntity(spawnedEntity.data, spawnedEntity.prop)
	end
end

function PANEL:OnRowRightClick(lineID, line)
	local menu = DermaMenu()

	menu:AddOption("Delete", function()
		for _, _line in ipairs(self:GetSelected()) do
			weaponPlacer:RemoveSpawnedEntity(_line.prop)
		end
	end):SetIcon("icon16/tag_blue_edit.png")

	menu:AddOption("Delete all of type", function()
		local count = 0

		for entity, data in pairs(weaponPlacer:GetSpawnedEntities()) do
			if data.class == line:GetColumnText(2) then
				weaponPlacer:RemoveSpawnedEntity(entity)
				count = count + 1
			end
		end

		chat.AddText(Color(0, 255, 0), "Weapon Placer: Deleted " .. count .. " entities of type " .. line:GetColumnText(2))
	end):SetIcon("icon16/tag_blue_edit.png")

	menu:AddOption("Delete all entities", function()
		local count = table.Count(weaponPlacer:GetSpawnedEntities())

		weaponPlacer:CleanUpProps()
		chat.AddText(Color(0, 255, 0), "Weapon Placer: Deleted all entities!")
	end):SetIcon("icon16/tag_blue_edit.png")

	if #self:GetSelected() <= 1 then
		menu:AddOption("Go To", function()
			if not weaponPlacer:CanUseWeaponPlacer() then
				return
			end

			local pos = line.prop:GetPos()

			net.Start("WeaponPlacer.TeleportToWeapon")
				net.WriteVector(pos)
			net.SendToServer()
		end):SetIcon("icon16/tag_blue_edit.png")
	end

	menu:Open()
end

vgui.Register("WepPlacerSpawnedEntities", PANEL, "WepPlacerDListView")