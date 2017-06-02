local themer_enabled = GetConVar("themer_enabled")
local derma_skinname = GetConVar("derma_skinname")

local themer_tweaks_uselabel = GetConVar("themer_tweaks_uselabel")
local themer_options_gear    = GetConVar("themer_options_gear")
local themer_spawnlist_icons = GetConVar("themer_spawnlist_icons")

local themer_icon_spawnlists = GetConVar("themer_icon_spawnlists")
local themer_icon_weapons    = GetConVar("themer_icon_weapons")
local themer_icon_ents       = GetConVar("themer_icon_ents")
local themer_icon_npcs       = GetConVar("themer_icon_npcs")
local themer_icon_cars       = GetConVar("themer_icon_cars")
local themer_icon_pp         = GetConVar("themer_icon_pp")
local themer_icon_dupes      = GetConVar("themer_icon_dupes")
local themer_icon_saves      = GetConVar("themer_icon_saves")

local function MakeMenu(panel)
	panel:Help([[This menu lets you select a custom skin for most elements. The spawnmenu is most noticable.
All skins will be from any addons or server downloads, or any custom ones you've made/downloaded manually.

If you're working on a skin and colors aren't updating, reapply changes.

All changes require applying changes.]])

	panel:CheckBox("Use Custom Skin","themer_enabled")

	local list = panel:ComboBox("Skin:","derma_skinname")
	for _,f in pairs(file.Find("materials/gwenskin/*.png","GAME")) do
		f = f:gsub(".png","")
		list:AddChoice(f)
	end

	local reload = panel:Button("Refresh List")
	reload.DoClick = function(s)
		list:Clear()
		for _,f in pairs(file.Find("materials/gwenskin/*.png","GAME")) do
			f = f:gsub(".png","")
			list:AddChoice(f)
		end
	end
	reload:SetIcon("icon16/arrow_refresh.png")

	local reload = panel:Button("Reload Spawnmenu","spawnmenu_reload")
	reload:SetTooltip("Only do this if you really have to, as in things aren't updating.")
	reload:SetIcon("icon16/application_view_tile.png")

	local apply = panel:Button("Apply Changes","themer_refresh_derma")
	apply:SetIcon("icon16/tick.png")
end

local function Tweaks(panel)
	panel:Help([[Here you can tweak various settings to match the theme.
Things like text entries and options in menus don't have their own color setting within the image file, so you can set them here.]])

	panel:CheckBox("Use Label Color for Text Entry and Menu Options","themer_tweaks_uselabel")
	panel:ControlHelp("(requires theme reapplication)")
end

local function IconSettings(panel)
	panel:Help([[Why only be limited to just the theme? Here you can set icons for spawnmenu tabs and such.

Note: Spawnmenu tabs for addons (Pill Pack, simfphys vehicles, SCars, etc) will not be changable.

All of these require reopening (not reloading) of the spawnmenu to apply changes.]])

	panel:CheckBox("Use Gear icon for Options tab","themer_options_gear")

	panel:CheckBox("Better Spawnlist Icons","themer_spawnlist_icons")
	panel:ControlHelp("Changes \"Your Spawnlists\" and \"Browse\" icons to more suitable icons.")

	local ib = panel:Button("Popout Icon Browser","themer_iconbrowser")
	ib:SetIcon("icon16/folder_picture.png")

	local cat_ib = vgui.Create("DCollapsibleCategory",panel)
	cat_ib:Dock(TOP)
	cat_ib:DockMargin(4,4,4,4)
	cat_ib:SetExpanded(false)
	cat_ib:SetLabel("Icon Browser")
	cat_ib.Header:SetIcon("icon16/folder_picture.png")
	cat_ib.AddItem = function(cat,ctrl) ctrl:SetParent(cat) ctrl:Dock(TOP) end

	local path_pnl = vgui.Create("EditablePanel",panel)
	path_pnl:DockMargin(0,0,0,4)
	path_pnl:SetTall(24)
	cat_ib:AddItem(path_pnl)
	local path = vgui.Create("DTextEntry",path_pnl)
	path:SetText("")
	path:Dock(FILL)
	path:SetEditable(false)
	local copy = vgui.Create("DButton",path_pnl)
	copy:Dock(RIGHT)
	copy:SetWide(24)
	copy:SetImage("icon16/page_copy.png")
	copy:SetText("")
	function copy:DoClick()
		SetClipboardText(path:GetText())
	end
	local browser = vgui.Create("DIconBrowser",panel)
	browser:SetTall(250)
	browser:DockMargin(0,0,0,4)
	function browser:OnChange()
		path:SetText(self:GetSelectedIcon())
	end
	cat_ib:AddItem(browser)

	panel:TextEntry("#spawnmenu.content_tab",          "themer_icon_spawnlists")
	panel:TextEntry("#spawnmenu.category.weapons",     "themer_icon_weapons")
	panel:TextEntry("#spawnmenu.category.entities",    "themer_icon_ents")
	panel:TextEntry("#spawnmenu.category.npcs",        "themer_icon_npcs")
	panel:TextEntry("#spawnmenu.category.vehicles",    "themer_icon_cars")
	panel:TextEntry("#spawnmenu.category.postprocess", "themer_icon_pp")
	panel:TextEntry("#spawnmenu.category.dupes",       "themer_icon_dupes")
	panel:TextEntry("#spawnmenu.category.saves",       "themer_icon_saves")
end

local function ServerSettings(panel)
	panel:Help("soon\xe2\x84\xa2")
end

local function About(panel)
	local title = vgui.Create("DLabel",panel)
	title:Dock(TOP)
	title:SetFont("Themer.Title")
	title:SetText("Themer")
	title:SizeToContents()
	title:DockMargin(8,8,8,8)

	local github = panel:Button("GitHub")
	github:SetIcon("icon16/world_link.png")
	github.DoClick = function(s) gui.OpenURL("https://github.com/wrldspawn/Themer") end
end

hook.Add("PopulateToolMenu","Themer.ToolMenu",function()
	spawnmenu.AddToolMenuOption("Theming","Theming","\1Theme Options","Theme Options","","",MakeMenu)
	spawnmenu.AddToolMenuOption("Theming","Configuration","Finer Tweaking","Finer Tweaking","","",Tweaks)
	spawnmenu.AddToolMenuOption("Theming","Configuration","Icons","Icons","","",IconSettings)
	spawnmenu.AddToolMenuOption("Theming","Server","Server Settings","Server Settings","","",ServerSettings)
	spawnmenu.AddToolMenuOption("Theming","Misc","About","About","","",About)

	for k,v in pairs(spawnmenu.GetTools()) do
		if v.Name == "Theming" then
			v.Icon = "icon16/palette.png"
		end
	end
end)

--External Settings Menu
local function ExtSettings()
	local frame = vgui.Create("DFrame")
	frame:SetSize(384,768)
	frame:SetPos(ScrW()-432,ScrH()/2-256)
	frame:SetTitle("Themer Settings")
	frame:SetIcon("icon16/palette.png")
	frame:MakePopup()

	local tabs = vgui.Create("DPropertySheet",frame)
	tabs:Dock(FILL)

	-- Main Area --
	local main = vgui.Create("DForm",tabs)
	MakeMenu(main)
	main:SetName("Theme Options")
	tabs:AddSheet("Theme Options",main,"icon16/palette.png")

	--Tweaks--
	local tweaks = vgui.Create("DForm",tabs)
	Tweaks(tweaks)
	tweaks:SetName("Finer Tweaks")
	tabs:AddSheet("Finer Tweaks",tweaks,"icon16/wrench.png")

	--Icons--
	local icons = vgui.Create("DForm",tabs)
	IconSettings(icons)
	icons:SetName("Icons")
	tabs:AddSheet("Icons",icons,"icon16/pictures.png")

	--Server Settings--
	local sv = vgui.Create("DForm",tabs)
	ServerSettings(sv)
	sv:SetName("Server Settings")
	tabs:AddSheet("Server Settings",sv,"icon16/server.png")

	--About--
	local about = vgui.Create("DForm",tabs)
	About(about)
	about:SetName("About")
	tabs:AddSheet("About",about,"icon16/information.png")
end

concommand.Add("themer_settings",ExtSettings)