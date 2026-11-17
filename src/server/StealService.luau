--!strict

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local BaseService = require(script.Parent:WaitForChild("BaseService"))
local EconomyService = require(script.Parent:WaitForChild("EconomyService"))
local CharacterService = require(script.Parent:WaitForChild("CharacterService"))

local StealService = {}

local lastStealTimes: { [Player]: number } = {}

function StealService.Init()
	local plotsFolder = Workspace:WaitForChild("BasePlots", 5)
	if not plotsFolder then return end

	local stealAlertEvent = Remotes.GetRemote("StealAlert")

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") then
			local pad = plot:FindFirstChild("Pad") :: Part?
			if pad then
				pad.Touched:Connect(function(hit)
					local char = hit.Parent
					if not char or not char:FindFirstChild("Humanoid") then return end
					local stealer = Players:GetPlayerFromCharacter(char)
					if not stealer then return end

					local owner = BaseService.GetPlotOwner(plot)
					if not owner or owner == stealer then return end

					-- Check if stealer already carrying something
					if CharacterService.GetCarried(stealer) ~= nil then return end

					-- Check cooldown (30s)
					local lastTime = lastStealTimes[stealer] or 0
					if tick() - lastTime < 30 then return end

					-- Check if base is locked
					local ownerData = EconomyService.GetPlayerData(owner)
					if ownerData and ownerData.Locked and tick() < ownerData.LockEndTime then
						-- Locked! Cannot steal
						return
					end

					-- Steal!
					if ownerData and #ownerData.Collection > 0 then
						lastStealTimes[stealer] = tick()

						-- Take random or last item from collection
						local index = math.random(1, #ownerData.Collection)
						local stolenItem = table.remove(ownerData.Collection, index)

						if stolenItem then
							CharacterService.SetCarried(stealer, {
								Name = stolenItem.Name,
								Rarity = stolenItem.Rarity,
								Mutation = stolenItem.Mutation,
								Income = stolenItem.Income,
							})

							EconomyService.RecalculateIncome(owner)
							EconomyService.SyncClientData(owner)
							EconomyService.SyncClientData(stealer)

							-- Alert victim
							stealAlertEvent:FireClient(owner, stealer.Name, stolenItem.Name)
							print(stealer.Name .. " stole " .. stolenItem.Name .. " from " .. owner.Name)
						end
					end
				end)
			end
		end
	end

	print("StealService initialized successfully")
end

return StealService
