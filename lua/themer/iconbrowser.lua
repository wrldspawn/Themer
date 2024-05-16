local function iconbrowser()
	local frame = vgui.Create("DFrame") do
		frame:SetSize(400, 300)
		frame:SetPos(5, ScrH() - 305)
		frame:SetTitle("Icon Browser")
		frame:MakePopup()
		frame:SetIcon("icon16/folder_picture.png")
	end

	local top_wrapper = vgui.Create("EditablePanel", frame) do
		top_wrapper:Dock(TOP)
		top_wrapper:DockMargin(4, 0, 4, 4)
		top_wrapper:SetTall(24)
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

	local browser = vgui.Create("DIconBrowser", frame) do
		browser:Dock(FILL)
		browser:DockMargin(4,0,4,4)

		function browser:OnChange()
			path:SetText(self:GetSelectedIcon())
		end
	end
end

concommand.Add("themer_iconbrowser", iconbrowser)
