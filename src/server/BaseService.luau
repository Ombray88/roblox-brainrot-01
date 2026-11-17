--!strict

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local BaseService = {}

local playerPlots: { [Player]: Model } = {}
local plotOwners: { [Model]: Player } = {}

function BaseService.GetPlayerPlot(player: Player): Model?
	return playerPlots[player]
end

function BaseService.GetPlotOwner(plot: Model): Player?
	return plotOwners[plot]
end

function BaseService.UpdateBaseTier(player: Player, rebirths: number)
	local plot = playerPlots[player]
	if not plot then return end
	local pad = plot:FindFirstChild("Pad") :: Part?
	if not pad then return end

	local tier = "Bronze"
	local color = Color3.fromRGB(205, 127, 50)
	local material = Enum.Material.SmoothPlastic

	if rebirths == 1 then
		tier = "Silver"
		color = Color3.fromRGB(192, 192, 192)
		material = Enum.Material.Foil
	elseif rebirths == 2 then
		tier = "Gold"
		color = Color3.fromRGB(255, 215, 0)
		material = Enum.Material.Neon
	elseif rebirths >= 3 then
		tier = "Diamond"
		color = Color3.fromRGB(0, 245, 255)
		material = Enum.Material.Glass
	end

	pad.Color = color
	pad.Material = material
	pad:SetAttribute("Tier", tier)
end

function BaseService.Init()
	local plotsFolder = Workspace:WaitForChild("BasePlots", 5)
	if not plotsFolder then return end

	Players.PlayerAdded:Connect(function(player)
		for _, child in ipairs(plotsFolder:GetChildren()) do
			if child:IsA("Model") then
				local pad = child:FindFirstChild("Pad")
				if pad and pad:GetAttribute("Occupied") == false then
					pad:SetAttribute("Occupied", true)
					playerPlots[player] = child
					plotOwners[child] = player
					pad:SetAttribute("Owner", player.Name)
					BaseService.UpdateBaseTier(player, 0)
					break
				end
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		local plot = playerPlots[player]
		if plot then
			local pad = plot:FindFirstChild("Pad")
			if pad then
				pad:SetAttribute("Occupied", false)
				pad:SetAttribute("Owner", "")
				pad.Color = Color3.fromRGB(150, 150, 150)
				pad.Material = Enum.Material.SmoothPlastic
			end
			plotOwners[plot] = nil
			playerPlots[player] = nil
		end
	end)
end

return BaseService
