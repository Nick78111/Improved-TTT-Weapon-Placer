local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
	self:InvalidateLayout(true)
	self:InvalidateParent(true)
	self:SetBackgroundColor(Color(0, 0, 0, 0))
	self:SetRemoveEmptyCategories(true)
end

function PANEL:AddButton(prop, class)
	local spawnableEntity = weaponPlacer:GetSpawnableEntityFromClass(class)

	if not spawnableEntity then
		return
	end

	local button, category = self:AddButtonToCategory(class, spawnableEntity.type)

	category:SetCountItems(true)

	button.entity = prop
	prop.button = button
end

function PANEL:ButtonSelected(button, class)
	weaponPlacer:SelectClass(class)
end

function PANEL:ButtonRightClicked(button, class)
	local dMenu = DermaMenu()

	dMenu:AddOption("Delete all of type", function()
		local count = 0

		for entity, data in pairs(weaponPlacer:GetSpawnedEntities()) do
			if data.class == class then
				weaponPlacer:RemoveSpawnedEntity(entity)
				count = count + 1
			end
		end

		chat.AddText(Color(0, 255, 0), "Weapon Placer: Deleted " .. count .. " entities of type " .. class)
	end):SetIcon("icon16/table_delete.png")

	dMenu:AddOption("Delete Entity", function()
		weaponPlacer:RemoveSpawnedEntity(button.entity)
	end):SetIcon("icon16/table_delete.png")

	dMenu:AddOption("Delete all entities", function()
		weaponPlacer:CleanUpProps()
		chat.AddText(Color(0, 255, 0), "Weapon Placer: Deleted all entities!")
	end):SetIcon("icon16/table_delete.png")

	dMenu:AddOption("Go To", function()
		if not weaponPlacer:CanUseWeaponPlacer() then
			return
		end

		local pos = button.entity:GetPos()

		net.Start("WeaponPlacer.TeleportToWeapon")
			net.WriteVector(pos)
		net.SendToServer()
	end):SetIcon("icon16/arrow_down.png")

	dMenu:Open()
end

function PANEL:OnRemove()
	if IsValid(self.entitySelectorSettings) then
		self.entitySelectorSettings:Remove()
	end
end

vgui.Register("WepPlacerSpawnedEntities", PANEL, "WepPlacerCategoryList")