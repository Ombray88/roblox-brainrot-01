--!strict

local Workspace = game:GetService("Workspace")

local WorldBuilder = {}

function WorldBuilder.BuildWorld()
	local success, err = pcall(function()
		-- Main Island Ground
		local island = Instance.new("Part")
		island.Name = "Island"
		island.Size = Vector3.new(320, 4, 320)
		island.Position = Vector3.new(0, -2, 0)
		island.Anchored = true
		island.Color = Color3.fromRGB(90, 180, 90) -- Vibrant Grass
		island.Material = Enum.Material.Grass
		island.Parent = Workspace

		-- Beach Ring
		local beach = Instance.new("Part")
		beach.Name = "Beach"
		beach.Size = Vector3.new(360, 3, 360)
		beach.Position = Vector3.new(0, -3.5, 0)
		beach.Anchored = true
		beach.Color = Color3.fromRGB(240, 220, 160) -- Warm Sand
		beach.Material = Enum.Material.Sand
		beach.Parent = Workspace

		-- Central Plaza
		local plaza = Instance.new("Part")
		plaza.Name = "CentralPlaza"
		plaza.Size = Vector3.new(110, 0.6, 110)
		plaza.Position = Vector3.new(0, 0.3, 0)
		plaza.Anchored = true
		plaza.Color = Color3.fromRGB(220, 220, 230)
		plaza.Material = Enum.Material.SmoothPlastic
		plaza.Shape = Enum.PartType.Cylinder
		plaza.Orientation = Vector3.new(0, 0, 90)
		plaza.Parent = Workspace

		-- Conveyor Belt Ring (circular path around plaza for creatures)
		local conveyorFolder = Instance.new("Folder")
		conveyorFolder.Name = "ConveyorBelt"
		conveyorFolder.Parent = Workspace

		local conveyorRadius = 65
		local segmentCount = 36
		for i = 1, segmentCount do
			local angle = (i / segmentCount) * math.pi * 2
			local x = math.cos(angle) * conveyorRadius
			local z = math.sin(angle) * conveyorRadius

			local part = Instance.new("Part")
			part.Name = "BeltSegment"
			part.Size = Vector3.new(8, 0.8, 12)
			part.Position = Vector3.new(x, 0.6, z)
			part.Orientation = Vector3.new(0, -math.deg(angle), 0)
			part.Anchored = true
			part.Color = Color3.fromRGB(60, 60, 75)
			part.Material = Enum.Material.Metal
			part.Parent = conveyorFolder
		end

		-- Giant Noodle Statue in Plaza Center
		local statueFolder = Instance.new("Folder")
		statueFolder.Name = "NoodleStatue"
		statueFolder.Parent = Workspace

		local basePedestal = Instance.new("Part")
		basePedestal.Name = "Pedestal"
		basePedestal.Size = Vector3.new(18, 2.5, 18)
		basePedestal.Position = Vector3.new(0, 1.25, 0)
		basePedestal.Anchored = true
		basePedestal.Color = Color3.fromRGB(160, 160, 170)
		basePedestal.Material = Enum.Material.Slate
		basePedestal.Parent = statueFolder

		local noodleBody = Instance.new("Part")
		noodleBody.Name = "NoodleTrunk"
		noodleBody.Size = Vector3.new(6, 20, 6)
		noodleBody.Position = Vector3.new(0, 12, 0)
		noodleBody.Anchored = true
		noodleBody.Color = Color3.fromRGB(255, 220, 80)
		noodleBody.Material = Enum.Material.Neon
		noodleBody.Shape = Enum.PartType.Cylinder
		noodleBody.Parent = statueFolder

		-- Lighthouse Landmark on Coast
		local lighthouseFolder = Instance.new("Folder")
		lighthouseFolder.Name = "Lighthouse"
		lighthouseFolder.Parent = Workspace

		local lhBase = Instance.new("Part")
		lhBase.Name = "LighthouseBase"
		lhBase.Size = Vector3.new(14, 32, 14)
		lhBase.Position = Vector3.new(130, 16, 130)
		lhBase.Anchored = true
		lhBase.Color = Color3.fromRGB(230, 60, 60)
		lhBase.Material = Enum.Material.SmoothPlastic
		lhBase.Shape = Enum.PartType.Cylinder
		lhBase.Parent = lighthouseFolder

		local lhTop = Instance.new("Part")
		lhTop.Name = "LighthouseLight"
		lhTop.Size = Vector3.new(8, 8, 8)
		lhTop.Position = Vector3.new(130, 36, 130)
		lhTop.Anchored = true
		lhTop.Color = Color3.fromRGB(255, 255, 100)
		lhTop.Material = Enum.Material.Neon
		lhTop.Shape = Enum.PartType.Ball
		lhTop.Parent = lighthouseFolder

		-- 8 Base Plots around the outer edge (Radius ~ 120)
		local plotsFolder = Instance.new("Folder")
		plotsFolder.Name = "BasePlots"
		plotsFolder.Parent = Workspace

		local plotRadius = 120
		local baseColors = {
			Color3.fromRGB(255, 110, 110),
			Color3.fromRGB(110, 255, 110),
			Color3.fromRGB(110, 110, 255),
			Color3.fromRGB(255, 255, 110),
			Color3.fromRGB(255, 110, 255),
			Color3.fromRGB(110, 255, 255),
			Color3.fromRGB(255, 175, 0),
			Color3.fromRGB(190, 110, 255),
		}

		for i = 1, 8 do
			local angle = ((i - 1) / 8) * math.pi * 2
			local x = math.cos(angle) * plotRadius
			local z = math.sin(angle) * plotRadius

			local plot = Instance.new("Model")
			plot.Name = "BasePlot_" .. i
			plot.Parent = plotsFolder

			local pad = Instance.new("Part")
			pad.Name = "Pad"
			pad.Size = Vector3.new(26, 1, 26)
			pad.Position = Vector3.new(x, 0.5, z)
			pad.Anchored = true
			pad.Color = baseColors[i]
			pad.Material = Enum.Material.Neon
			pad.Parent = plot

			pad:SetAttribute("PlotIndex", i)
			pad:SetAttribute("Occupied", false)
			pad:SetAttribute("Tier", "Bronze")
		end

		print("WorldBuilder (Enhanced): Brainrot Bay generated successfully with polished tropical architecture!")
	end)

	if not success then
		warn("WorldBuilder failed: " + tostring(err))
	end
end

return WorldBuilder
