---@meta _
---@diagnostic disable: lowercase-global



local function drawModMenu()

    local value, checked = rom.ImGui.Checkbox("Enable Aritificer Indicator", config.ArtificerIndicator)

    if checked then
		config.ArtificerIndicator = value
	end
	
	-- HUD/icon scale slider
	rom.ImGui.Separator()
	local hudScale = config.ArtificerHUDScale
	local newHud, changed = rom.ImGui.SliderFloat("Tray Icon HUDScale", hudScale, 0.05, 0.6)
	if changed then
		config.ArtificerHUDScale = newHud
	end

	rom.ImGui.Separator()
	if rom.ImGui.Button("Apply Now") then
		-- Trigger update immediately (exposed by the mod)
		if purpIe_ArtificerIndicator and purpIe_ArtificerIndicator.UpdateNow then
			purpIe_ArtificerIndicator.UpdateNow()
		else
			print("ArtificerIndicator: UpdateNow not available")
		end
	end
end



rom.gui.add_imgui(function()
	if rom.ImGui.Begin("ArtificerIndicator") then
		drawModMenu()
		rom.ImGui.End()
	end
end)

rom.gui.add_to_menu_bar(function()
	if rom.ImGui.BeginMenu("Configure") then
		drawModMenu()
		rom.ImGui.EndMenu()
	end
end)
