AddCSLuaFile()

DEFINE_BASECLASS("weapon_tttbase")

SWEP.PrintName = "TTT Weapon Placer"

SWEP.Base                   = "weapon_tttbase"

SWEP.HoldType               = "pistol"

SWEP.AutoSpawnable          = false
SWEP.AllowDrop              = true

SWEP.NoSights               = true

SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"

SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"

SWEP.AutoSwitchTo           = true
SWEP.AutoSwitchFrom         = false

SWEP.ViewModel              = "models/weapons/v_stunbaton.mdl"
SWEP.WorldModel             = "models/weapons/w_stunbaton.mdl"

if CLIENT then
	SWEP.ViewModelFOV       = 80
	SWEP.ViewModelFlip      = false
	SWEP.Slot               = 0
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:PrimaryAttack()
	if SERVER then
		return
	end

	if not IsFirstTimePredicted() then
		return
	end

	if not weaponPlacer:GetSelectedClass() then
		return
	end

	weaponPlacer:AddItem(weaponPlacer:GetSelectedClass())
end

if SERVER then
	function SWEP:OnDrop()
		self:Remove()
	end

	return
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then
		return
	end

	-- this kind of sucks, I couldn't find a bettery way to do it
	-- with clientside props

	local trace = self:GetOwner():GetEyeTrace()
	local entity, dist = nil, nil

	for _, itemData in pairs(weaponPlacer:GetSpawnedEntities()) do
		local d = itemData.prop:GetPos():Distance(trace.HitPos)

		if not entity or d < dist then
			entity = itemData.prop
			dist = d
		end
	end

	if dist and dist < 10 then
		weaponPlacer:RemoveSpawnedEntity(entity)
	end
end

function SWEP:OnRemove()
	self:Disable()
end

function SWEP:Holster()
	if not IsFirstTimePredicted() then
		return
	end

	self:Remove()

	return true
end

function SWEP:Disable()
	weaponPlacer:CleanUpProps()
	weaponPlacer:CloseMenu(true)
end

function SWEP:DrawHUD()
	local ply = LocalPlayer()

	local x, y = ScrW(), ScrH()

	local frame = {}
	frame.w = 280
	frame.h = 0
	frame.x = x - frame.w
	frame.y = y - frame.h - y / 2.5

	local margin = 2

	local curEnt = weaponPlacer:GetSpawnableEntityFromClass(weaponPlacer:GetSelectedClass())
	curEnt = (curEnt and curEnt.class) and curEnt.class or "None"

	local entText = "Selected Entity: " .. curEnt
	local openText = curEnt ~= "None" and "Hold E or R to rotate entities" or "Hold Z to open menu"

	surface.SetFont("DebugFixed")
	local eth = select(2, surface.GetTextSize(entText))
	local oth = select(2, surface.GetTextSize(openText))

	frame.h = eth + oth

	surface.SetDrawColor(0, 0, 0, 220)
	surface.DrawRect(frame.x, frame.y, frame.w, frame.h)

	surface.SetTextColor(135, 206, 250, 255)

	surface.SetTextPos(frame.x + margin, frame.y)
	surface.DrawText(entText)

	surface.SetTextPos(frame.x + margin, frame.y + eth)
	surface.DrawText(openText)

	self.BaseClass.DrawHUD(self)
end

function SWEP:Think()
	local prop = weaponPlacer:GetGhostProp()

	if prop then
		local tr = util.GetPlayerTrace(self:GetOwner())
		local trace = util.TraceEntity(tr, prop)
		local rotate = (input.IsKeyDown(KEY_R) and 1 or input.IsKeyDown(KEY_E) and 0) or false

		prop:SetPos(trace.HitPos)

		if rotate then
			local angs = prop:GetAngles()
			local rotation = rotate == 0 and angs.y + (RealFrameTime() * 100) or angs.y - (RealFrameTime() * 100)

			prop:SetLocalAngles(Angle(0, rotation, 0))
		end
	end

	if input.WasMousePressed(MOUSE_MIDDLE) then
		local class = weaponPlacer:GetSelectedClass()
		if class then
			local spawnableEntity = weaponPlacer:GetWeaponAmmoFromClass(class)

			if spawnableEntity then
				weaponPlacer:AddItem(spawnableEntity.class)
			end
		end
	end

	if input.WasKeyPressed(KEY_Z) then
		weaponPlacer:OpenMenu()
	elseif input.WasKeyReleased(KEY_Z) then
		weaponPlacer:CloseMenu()
	end
end