local themer_enabled = GetConVar("themer_enabled")
local derma_skinname = GetConVar("derma_skinname")
local themer_skin = GetConVar("themer_skin")

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
	local info = panel:Help([[This menu lets you select a custom skin for most elements. The spawnmenu is most noticable.
All skins will be from any addons or server downloads, or any custom ones you've made/downloaded manually.

If you're working on a skin and colors aren't updating, reapply changes.

All changes require applying changes.]])

	local enabled = panel:CheckBox("Use Custom Skin", "themer_enabled")

	local files = {}

	for _, filename in ipairs(file.Find("materials/gwenskin/*.png", "GAME")) do
		filename = filename:gsub(".png", "")
		files[filename] = true
	end
	for _, filename in ipairs(file.Find("materials/gwenskin/*.png", "THIRDPARTY")) do
		filename = filename:gsub(".png", "")
		files[filename] = true
	end

	local filelist = panel:ComboBox("Skin Image:", "derma_skinname")
	for filename in next, files do
		filelist:AddChoice(filename)
	end

	local skin_help = panel:Help("Alternatively, you can select a typical skin, which may have other features or better compatibiliy.")

	local skinlist = panel:ComboBox("Skin:", "themer_skin")
	for name in next, derma.SkinList do
		skinlist:AddChoice(name)
	end

	local refresh = panel:Button("Refresh Lists")
	refresh.DoClick = function()
		filelist:Clear()
		skinlist:Clear()
		files = {}

		for _, filename in ipairs(file.Find("materials/gwenskin/*.png", "GAME")) do
			filename = filename:gsub(".png", "")
			files[filename] = true
		end
		for _, filename in ipairs(file.Find("materials/gwenskin/*.png", "THIRDPARTY")) do
			filename = filename:gsub(".png", "")
			files[filename] = true
		end

		for filename in next, files do
			filelist:AddChoice(filename)
		end

		for name in next, derma.SkinList do
			skinlist:AddChoice(name)
		end
	end
	refresh:SetIcon("icon16/arrow_refresh.png")

	if GAMEMODE.IsSandboxDerived then
		local reload = panel:Button("Reload Spawnmenu", "spawnmenu_reload")
		reload:SetTooltip("Only do this if you really have to, such as if things aren't updating.")
		reload:SetIcon("icon16/application_view_tile.png")
	end

	local apply = panel:Button("Apply Changes", "themer_refresh_derma")
	apply:SetIcon("icon16/tick.png")
end

local function IconSettings(panel)
	panel:Help([[Why only be limited to just the theme? Here you can set icons for spawnmenu tabs and such.

Note: Spawnmenu tabs for addons (Pill Pack, SCars, etc) will not be changable.

All of these require reopening (not reloading) of the spawnmenu to apply changes.]])

	panel:CheckBox("Use Gear icon for Options tab", "themer_options_gear")

	panel:CheckBox("Better Spawnlist Icons", "themer_spawnlist_icons")
	panel:ControlHelp('Changes "Your Spawnlists" and "Browse" icons to more suitable icons.')

	local open_iconbrowser = panel:Button("Popout Icon Browser", "themer_iconbrowser")
	open_iconbrowser:SetIcon("icon16/folder_picture.png")

	local iconbrowser = vgui.Create("DCollapsibleCategory", panel) do
		iconbrowser:Dock(TOP)
		iconbrowser:DockMargin(4, 4, 4, 4)
		iconbrowser:SetExpanded(false)
		iconbrowser:SetLabel("Icon Browser")
		iconbrowser.Header:SetIcon("icon16/folder_picture.png")
		iconbrowser.AddItem = function(self, ctrl)
			ctrl:SetParent(self)
			ctrl:Dock(TOP)
		end
	end

	local top_wrapper = vgui.Create("EditablePanel", iconbrowser) do
		top_wrapper:DockMargin(0, 0, 0, 4)
		top_wrapper:SetTall(24)
		iconbrowser:AddItem(top_wrapper)
	end

	local path = vgui.Create("DTextEntry", top_wrapper) do
		path:SetText("")
		path:Dock(FILL)
		path:SetEditable(false)
	end

	local copy = vgui.Create("DButton", top_wrapper) do
		copy:Dock(RIGHT)
		copy:SetWide(24)
		copy:SetImage("icon16/page_copy.png")
		copy:SetText("")
		function copy:DoClick()
			SetClipboardText(path:GetText())
		end
	end

	local browser = vgui.Create("DIconBrowser", iconbrowser) do
		browser:SetTall(250)
		browser:DockMargin(0, 0, 0, 4)
		function browser:OnChange()
			path:SetText(self:GetSelectedIcon())
		end
		iconbrowser:AddItem(browser)
	end

	panel:TextEntry("#spawnmenu.content_tab",          "themer_icon_spawnlists")
	panel:TextEntry("#spawnmenu.category.weapons",     "themer_icon_weapons")
	panel:TextEntry("#spawnmenu.category.entities",    "themer_icon_ents")
	panel:TextEntry("#spawnmenu.category.npcs",        "themer_icon_npcs")
	panel:TextEntry("#spawnmenu.category.vehicles",    "themer_icon_cars")
	panel:TextEntry("#spawnmenu.category.postprocess", "themer_icon_pp")
	panel:TextEntry("#spawnmenu.category.dupes",       "themer_icon_dupes")
	panel:TextEntry("#spawnmenu.category.saves",       "themer_icon_saves")
end

local function About(panel)
	local title = vgui.Create("DLabel", panel) do
		title:Dock(TOP)
		title:SetFont("Themer.Title")
		title:SetText("Themer")
		title:SizeToContents()
		title:DockMargin(8, 8, 8, 8)
		title:SetDark()
	end

	local github = panel:Button("GitHub") do
		github:SetIcon("icon16/world_link.png")
		github.DoClick = function()
			gui.OpenURL("https://github.com/wrldspawn/Themer")
		end
	end
end

hook.Add("PopulateToolMenu", "Themer.ToolMenu", function()
	spawnmenu.AddToolMenuOption("Theming", "Theming", "Theme Options",                 "Theme Options",                 "", "", MakeMenu)
	spawnmenu.AddToolMenuOption("Theming", "Theming", "\xe2\x80\x8bIcons",             "\xe2\x80\x8bIcons",             "", "", IconSettings)
	spawnmenu.AddToolMenuOption("Theming", "Theming", "\xe2\x80\x8b\xe2\x80\x8bAbout", "\xe2\x80\x8b\xe2\x80\x8bAbout", "", "", About)

	for _, tab in ipairs(spawnmenu.GetTools()) do
		if tab.Name == "Theming" then
			tab.Icon = "icon16/palette.png"
		elseif tab.Name == "Utilities" and themer_options_gear:GetBool() then
			tab.Icon = "icon16/cog.png"
		end
	end
end)

-- External Settings Menu
local function ExtSettings()
	local frame = vgui.Create("DFrame") do
		frame:SetSize(384, 768)
		frame:SetPos(ScrW() - 432, (ScrH() / 2) - 256)
		frame:SetTitle("Themer Settings")
		frame:SetIcon("icon16/palette.png")
		frame:MakePopup()
	end

	local tabs = vgui.Create("DPropertySheet", frame)
	tabs:Dock(FILL)

	local main = vgui.Create("DForm", tabs)
	MakeMenu(main)
	main:SetName("Theme Options")
	tabs:AddSheet("Theme Options", main, "icon16/palette.png")

	local icons = vgui.Create("DForm", tabs)
	IconSettings(icons)
	icons:SetName("Icons")
	tabs:AddSheet("Icons", icons, "icon16/pictures.png")

	local about = vgui.Create("DForm", tabs) do
		About(about)
		about:SetName("About")
		tabs:AddSheet("About", about, "icon16/information.png")
	end
end

concommand.Add("themer_settings", ExtSettings)
