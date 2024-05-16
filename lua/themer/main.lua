-- {{ cvars
local themer_enabled         = CreateClientConVar("themer_enabled", "1",           true)
local derma_skinname         = CreateClientConVar("derma_skinname", "gmoddefault", true)
local themer_skin            = CreateClientConVar("themer_skin",    "themer",      true)

local themer_options_gear    = CreateClientConVar("themer_options_gear",    "0", true)
local themer_spawnlist_icons = CreateClientConVar("themer_spawnlist_icons", "0", true)

local themer_icon_spawnlists = CreateClientConVar("themer_icon_spawnlists", "icon16/application_view_tile.png", true)
local themer_icon_weapons    = CreateClientConVar("themer_icon_weapons",    "icon16/gun.png",                   true)
local themer_icon_ents       = CreateClientConVar("themer_icon_ents",       "icon16/bricks.png",                true)
local themer_icon_npcs       = CreateClientConVar("themer_icon_npcs",       "icon16/group.png",                 true)
local themer_icon_cars       = CreateClientConVar("themer_icon_cars",       "icon16/car.png",                   true)
local themer_icon_pp         = CreateClientConVar("themer_icon_pp",         "icon16/image.png",                 true)
local themer_icon_dupes      = CreateClientConVar("themer_icon_dupes",      "icon16/brick_link.png",            true)
local themer_icon_saves      = CreateClientConVar("themer_icon_saves",      "icon16/disk.png",                  true)
-- }}}

include("themer/iconbrowser.lua")
include("themer/spawnmenu.lua")

-- {{{ helpers
local function getupvalues(f)
	local i, t = 0, {}

	while true do
		i = i + 1
		local key, val = debug.getupvalue(f, i)
		if not key then break end
		t[key] = val
	end

	return t
end
-- }}}

local function ColorHack()
	local DMenuOption = table.Copy(vgui.GetControlTable("DMenuOption"))
	local DComboBox = table.Copy(vgui.GetControlTable("DComboBox"))

	DMenuOption.Init = function(self)
		self:SetContentAlignment(4)
		self:SetTextInset(30,0)
		self:SetTextColor(self:GetSkin().Colours.Label.Dark)
		self:SetChecked(false)
	end

	DMenuOption.UpdateColours = function(self, skin)
		if self:IsHovered() then
			self:SetTextColor(skin.Colours.Label.Bright)
			return self:SetTextStyleColor(skin.Colours.Label.Bright)
		end

		self:SetTextColor(skin.Colours.Label.Dark)
		return self:SetTextStyleColor(skin.Colours.Label.Dark)
	end

	derma.DefineControl( "DMenuOption", "Menu Option Line", DMenuOption, "DButton" )
	derma.DefineControl( "DMenuOptionCVar", "", vgui.GetControlTable("DMenuOptionCVar"), "DMenuOption" )

	DComboBox.UpdateColours = function(self, skin)
		if self.Depressed or self:IsMenuOpen() then
			self:SetTextColor(skin.Colours.Label.Bright)
			return self:SetTextStyleColor(skin.Colours.Label.Bright)
		end

		self:SetTextColor(skin.Colours.Label.Dark)
		return self:SetTextStyleColor(skin.Colours.Label.Dark)
	end

	derma.DefineControl("DComboBox", "", DComboBox, "DButton")

	local DProperties = table.Copy(vgui.GetControlTable("DProperties"))
	local tblCategory = getupvalues(DProperties.GetCategory).tblCategory

	DProperties.GetCategory = function(self, name, bCreate)
		local cat = self.Categories[name]
		if IsValid(cat) then return cat end

		if not bCreate then return end

		cat = self:GetCanvas():Add(tblCategory)
		cat.Label:SetText(name)

		cat.Container.Paint = function(pnl, w, h)
			self:GetSkin():PaintListBox(pnl, w, h)
		end

		self.Categories[name] = cat

		return cat
	end

	derma.DefineControl("DProperties", "", DProperties, "Panel")

	local DTree_Node_Button = table.Copy(vgui.GetControlTable("DTree_Node_Button"))
	DTree_Node_Button.UpdateColours = function(self, skin)
		-- m_bSelectable is false on this for some reason
		if self.m_bSelected then
			return self:SetTextStyleColor(skin.Colours.Tree.Selected)
		end
		if self.Hovered then
			return self:SetTextStyleColor(skin.Colours.Tree.Hover)
		end

		return self:SetTextStyleColor(skin.Colours.Tree.Normal)
	end
	derma.DefineControl("DTree_Node_Button", "Tree Node Button", DTree_Node_Button, "DButton")
end

hook.Add("ForceDermaSkin", "Themer", function()
	if themer_enabled:GetBool() then
		return themer_skin:GetString() or "themer"
	end
end)

concommand.Add("themer_refresh_derma",function()
	include("skins/themer.lua")
	derma.RefreshSkins()
	ColorHack()

	local hooks = hook.GetTable()
	for name in pairs(hooks.ForceDermaSkin) do
		if name == "Themer" then continue end

		hook.Remove("ForceDermaSkin", name)
	end

	if IsValid(g_SpawnMenu) then
		for _, tab in ipairs(g_SpawnMenu.ToolMenu.Items) do
			local tool_panel = tab.Panel
			if IsValid(tool_panel) and IsValid(tool_panel.Content) then
				tool_panel = tool_panel.Content:GetCanvas()
			end

			if IsValid(tool_panel) then
				for _, panel in ipairs(tool_panel:GetChildren()) do
					local function recurse(c)
						if #c == 0 then return end

						for _, panel in ipairs(c) do
							panel:InvalidateLayout()

							recurse(panel:GetChildren())
						end
					end

					for _, item in ipairs(panel.Items) do
						recurse(item:GetChildren())
					end
				end
			end
		end
	end
end)

hook.Add("SpawnMenuOpen", "Themer.IconHack", function()
	local ToolMenuItems = g_SpawnMenu.ToolMenu.Items
	for _, item in ipairs(ToolMenuItems) do
		if item.Name == "Options" then
			item.Tab.Image:SetImage(themer_options_gear:GetBool() and "icon16/cog.png" or "icon16/wrench.png")
		end
		if item.Name == "Utilities" then
			item.Tab.Image:SetImage(themer_options_gear:GetBool() and "icon16/cog.png" or "icon16/page_white_wrench.png")
		end
	end

	local SpawnTabs = g_SpawnMenu.CreateMenu.Items
	for _, tab in ipairs(SpawnTabs) do
		if tab.Name == "#spawnmenu.content_tab" then
			tab.Tab.Image:SetImage(Material(themer_icon_spawnlists:GetString()):IsError() and "icon16/application_view_tile.png" or themer_icon_spawnlists:GetString())

			local spawnlists = tab.Panel:GetChildren()[1].ContentNavBar.Tree.RootNode.ChildNodes:GetChildren()
			for _, list in pairs(spawnlists) do
				if list:GetText() == "Your Spawnlists" then
					list:SetIcon(themer_spawnlist_icons:GetBool() and "icon16/folder_page.png" or "icon16/folder.png")
				end
				if list:GetText() == "Browse" then
					list:SetIcon(themer_spawnlist_icons:GetBool() and "icon16/folder_brick.png" or "icon16/cog.png")
				end
				if list:GetText() == "Browse Materials" then
					list:SetIcon(themer_spawnlist_icons:GetBool() and "icon16/folder_image.png" or "icon16/picture_empty.png")
				end
				if list:GetText() == "Browse Sounds" then
					list:SetIcon(themer_spawnlist_icons:GetBool() and "icon16/folder_bell.png" or "icon16/sound.png")
				end
			end
		end

		if tab.Name == "#spawnmenu.category.weapons" then
			tab.Tab.Image:SetImage(Material(themer_icon_weapons:GetString()):IsError() and "icon16/gun.png" or themer_icon_weapons:GetString())
		end

		if tab.Name == "#spawnmenu.category.entities" then
			tab.Tab.Image:SetImage(Material(themer_icon_ents:GetString()):IsError() and "icon16/bricks.png" or themer_icon_ents:GetString())
		end

		if tab.Name == "#spawnmenu.category.npcs" then
			tab.Tab.Image:SetImage(Material(themer_icon_npcs:GetString()):IsError() and "icon16/group.png" or themer_icon_npcs:GetString())
		end

		if tab.Name == "#spawnmenu.category.vehicles" then
			tab.Tab.Image:SetImage(Material(themer_icon_cars:GetString()):IsError() and "icon16/car.png" or themer_icon_cars:GetString())
		end

		if tab.Name == "#spawnmenu.category.postprocess" then
			tab.Tab.Image:SetImage(Material(themer_icon_pp:GetString()):IsError() and "icon16/image.png" or themer_icon_pp:GetString())
		end

		if tab.Name == "#spawnmenu.category.dupes" then
			tab.Tab.Image:SetImage(Material(themer_icon_dupes:GetString()):IsError() and "icon16/brick_link.png" or themer_icon_dupes:GetString())
		end

		if tab.Name == "#spawnmenu.category.saves" then
			tab.Tab.Image:SetImage(Material(themer_icon_saves:GetString()):IsError() and "icon16/disk.png" or themer_icon_saves:GetString())
		end
	end
end)

hook.Add("Initialize", "Themer", function()
	timer.Simple(0, function()
		ColorHack()

		local hooks = hook.GetTable()
		for name in pairs(hooks.ForceDermaSkin) do
			if name == "Themer" then continue end

			hook.Remove("ForceDermaSkin", name)
		end
	end)
end)

do
	local hooks = hook.GetTable()
	for name in pairs(hooks.ForceDermaSkin) do
		if name == "Themer" then continue end

		hook.Remove("ForceDermaSkin", name)
	end

	if hooks.OnGamemodeLoaded and hooks.OnGamemodeLoaded.CreateMenuBar then
		_G.__themer_oldCreateMenuBar = _G.__themer_oldCreateMenuBar or hooks.OnGamemodeLoaded.CreateMenuBar
		local oldCreateMenuBar = _G.__themer_oldCreateMenuBar
		hook.Add("OnGamemodeLoaded", "CreateMenuBar", function()
			ColorHack()
			oldCreateMenuBar()
		end)
	end
end