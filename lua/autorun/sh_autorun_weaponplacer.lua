if engine.ActiveGamemode() != "terrortown" then
	return
end

if SERVER then
	AddCSLuaFile("client/cl_weaponplacer.lua")
	AddCSLuaFile("client/vgui/cl_weaponplacer_buttons.lua")
	AddCSLuaFile("client/vgui/cl_weaponplacer_dlistview.lua")
	AddCSLuaFile("client/vgui/cl_weaponplacer_entitylist.lua")
	AddCSLuaFile("client/vgui/cl_weaponplacer_entityselector.lua")
	AddCSLuaFile("client/vgui/cl_weaponplacer_frame.lua")
	AddCSLuaFile("client/vgui/cl_weaponplacer_menuframe.lua")
	AddCSLuaFile("client/vgui/cl_weaponplacer_settings.lua")
	AddCSLuaFile("shared/sh_weaponplacer.lua")

	include("shared/sh_weaponplacer.lua")
	include("server/sv_weaponplacer.lua")
	include("server/sv_weaponplacer_prep.lua")

	return
end

include("shared/sh_weaponplacer.lua")
include("client/cl_weaponplacer.lua")
include("client/vgui/cl_weaponplacer_buttons.lua")
include("client/vgui/cl_weaponplacer_dlistview.lua")
include("client/vgui/cl_weaponplacer_entitylist.lua")
include("client/vgui/cl_weaponplacer_entityselector.lua")
include("client/vgui/cl_weaponplacer_frame.lua")
include("client/vgui/cl_weaponplacer_menuframe.lua")
include("client/vgui/cl_weaponplacer_settings.lua")