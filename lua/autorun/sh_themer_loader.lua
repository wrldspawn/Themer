AddCSLuaFile("skins/themer.lua")
AddCSLuaFile("themer/main.lua")
AddCSLuaFile("themer/iconbrowser.lua")
AddCSLuaFile("themer/spawnmenu.lua")

if SERVER then return end
include'skins/themer.lua'

surface.CreateFont("Themer.Title",{
	font = "Roboto",
	size = 48,
	weight = 400,
})

surface.CreateFont("Themer.Title2",{
	font = "Roboto",
	size = 32,
	weight = 400,
})

include'themer/main.lua'