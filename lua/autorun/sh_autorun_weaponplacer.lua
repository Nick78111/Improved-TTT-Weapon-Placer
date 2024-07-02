if engine.ActiveGamemode() != "terrortown" then
	return
end

if SERVER then
	AddCSLuaFile("client/cl_weaponplacer.lua")
	AddCSLuaFile("client/vgui/cl_weaponplacer_category_list.lua")
	AddCSLuaFile("client/vgui/cl_weaponplacer_buttons.lua")
	AddCSLuaFile("client/vgui/cl_weaponplacer_spawned_ent_list.lua")
	AddCSLuaFile("client/vgui/cl_weaponplacer_ent_selector.lua")
	AddCSLuaFile("client/vgui/cl_weaponplacer_frame.lua")
	AddCSLuaFile("client/vgui/cl_weaponplacer_menu_frame.lua")
	AddCSLuaFile("client/vgui/cl_weaponplacer_settings.lua")
	AddCSLuaFile("client/vgui/cl_weaponplacer_ent_selector_settings.lua")
	AddCSLuaFile("client/vgui/cl_weaponplacer_skin.lua")
	AddCSLuaFile("shared/sh_weaponplacer.lua")

	include("shared/sh_weaponplacer.lua")
	include("server/sv_weaponplacer.lua")
	include("server/sv_weaponplacer_prep.lua")

	return
end

include("shared/sh_weaponplacer.lua")
include("client/cl_weaponplacer.lua")
include("client/vgui/cl_weaponplacer_category_list.lua")
include("client/vgui/cl_weaponplacer_buttons.lua")
include("client/vgui/cl_weaponplacer_spawned_ent_list.lua")
include("client/vgui/cl_weaponplacer_ent_selector.lua")
include("client/vgui/cl_weaponplacer_frame.lua")
include("client/vgui/cl_weaponplacer_menu_frame.lua")
include("client/vgui/cl_weaponplacer_settings.lua")
include("client/vgui/cl_weaponplacer_ent_selector_settings.lua")
include("client/vgui/cl_weaponplacer_skin.lua")
