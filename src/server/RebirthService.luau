--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local EconomyService = require(script.Parent:WaitForChild("EconomyService"))
local BaseService = require(script.Parent:WaitForChild("BaseService"))

local RebirthService = {}

function RebirthService.Init()
	local rebirthEvent = Remotes.GetRemote("RebirthRequest")
	local rebirthDoneEvent = Remotes.GetRemote("RebirthDone")

	rebirthEvent.OnServerEvent:Connect(function(player)
		local data = EconomyService.GetPlayerData(player)
		if not data then return end

		local cost = Config.GetRebirthCost(data.Rebirths)
		if data.Money >= cost then
			-- Pay cost, reset money and collection, increment rebirths
			data.Money = 0
			data.Collection = {}
			data.Rebirths += 1

			EconomyService.RecalculateIncome(player)
			EconomyService.SyncClientData(player)

			-- Update leaderstats
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local moneyVal = leaderstats:FindFirstChild("Money") :: NumberValue?
				local rebirthVal = leaderstats:FindFirstChild("Rebirths") :: IntValue?
				if moneyVal then moneyVal.Value = 0 end
				if rebirthVal then rebirthVal.Value = data.Rebirths end
			end

			-- Update base tier visual
			BaseService.UpdateBaseTier(player, data.Rebirths)

			rebirthDoneEvent:FireClient(player, data.Rebirths)
			print(player.Name .. " rebirthed to tier " .. data.Rebirths)
		end
	end)

	print("RebirthService initialized successfully")
end

return RebirthService
