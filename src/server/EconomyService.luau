--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local EconomyService = {}

type PlayerData = {
	Money: number,
	Rebirths: number,
	IncomeRate: number,
	Slots: number,
	MaxSlots: number,
	Locked: boolean,
	LockEndTime: number,
	LockCooldownTime: number,
	Collection: { { Name: string, Rarity: string, Mutation: string, Income: number } },
}

local playerData: { [Player]: PlayerData } = {}

function EconomyService.GetPlayerData(player: Player): PlayerData?
	return playerData[player]
end

function EconomyService.SyncClientData(player: Player)
	local data = playerData[player]
	if not data then return end
	local syncEvent = Remotes.GetRemote("DataSync")
	syncEvent:FireClient(player, {
		Money = data.Money,
		Rebirths = data.Rebirths,
		IncomeRate = data.IncomeRate,
		Collection = data.Collection,
	})
end

function EconomyService.AddMoney(player: Player, amount: number)
	local data = playerData[player]
	if data then
		data.Money += amount
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local moneyStat = leaderstats:FindFirstChild("Money") :: NumberValue?
			if moneyStat then
				moneyStat.Value = math.floor(data.Money)
			end
		end
		EconomyService.SyncClientData(player)
	end
end

function EconomyService.RemoveMoney(player: Player, amount: number): boolean
	local data = playerData[player]
	if data and data.Money >= amount then
		data.Money -= amount
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local moneyStat = leaderstats:FindFirstChild("Money") :: NumberValue?
			if moneyStat then
				moneyStat.Value = math.floor(data.Money)
			end
		end
		EconomyService.SyncClientData(player)
		return true
	end
	return false
end

function EconomyService.RecalculateIncome(player: Player)
	local data = playerData[player]
	if not data then return end
	local total = 0
	for _, item in ipairs(data.Collection) do
		total += item.Income
	end
	local rebirthMult = 1 + (data.Rebirths * 0.25)
	data.IncomeRate = math.floor(total * rebirthMult)
end

function EconomyService.Init()
	Players.PlayerAdded:Connect(function(player)
		local data: PlayerData = {
			Money = 50,
			Rebirths = 0,
			IncomeRate = 0,
			Slots = 4,
			MaxSlots = 12,
			Locked = false,
			LockEndTime = 0,
			LockCooldownTime = 0,
			Collection = {},
		}
		playerData[player] = data

		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player

		local money = Instance.new("NumberValue")
		money.Name = "Money"
		money.Value = data.Money
		money.Parent = leaderstats

		local rebirths = Instance.new("IntValue")
		rebirths.Name = "Rebirths"
		rebirths.Value = data.Rebirths
		rebirths.Parent = leaderstats

		task.defer(function()
			EconomyService.SyncClientData(player)
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		playerData[player] = nil
	end)

	-- 1 second income tick loop
	task.spawn(function()
		while true do
			task.wait(1)
			pcall(function()
				for player, data in pairs(playerData) do
					if data.IncomeRate > 0 then
						EconomyService.AddMoney(player, data.IncomeRate)
					end
				end
			end)
		end
	end)

	print("EconomyService initialized successfully")
end

return EconomyService
