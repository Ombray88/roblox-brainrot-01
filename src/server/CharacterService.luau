--!strict

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local EconomyService = require(script.Parent:WaitForChild("EconomyService"))
local BaseService = require(script.Parent:WaitForChild("BaseService"))

local CharacterService = {}

type CarriedCharacter = {
	Name: string,
	Rarity: string,
	Mutation: string,
	Income: number,
}

local carriedCreatures: { [Player]: CarriedCharacter } = {}

function CharacterService.GetCarried(player: Player): CarriedCharacter?
	return carriedCreatures[player]
end

function CharacterService.SetCarried(player: Player, data: CarriedCharacter?)
	carriedCreatures[player] = data
	local char = player.Character
	if char then
		local humanoid = char:FindFirstChild("Humanoid") :: Humanoid?
		if humanoid then
			humanoid.WalkSpeed = data and (16 * 0.85) or 16
		end
	end
end

function CharacterService.SpawnCharacter(forcedChar: Config.CharacterDef?, forcedMut: Config.MutationDef?)
	pcall(function()
		local charDef = forcedChar or Config.RollCharacter()
		local mutDef = forcedMut or Config.RollMutation()

		local model = Instance.new("Model")
		model.Name = charDef.Name

		local hrp = Instance.new("Part")
		hrp.Name = "PrimaryPart"
		hrp.Size = Vector3.new(4, 4, 4)
		-- Spawn on conveyor ring radius ~65
		local angle = math.random() * math.pi * 2
		local x = math.cos(angle) * 65
		local z = math.sin(angle) * 65
		hrp.Position = Vector3.new(x, 3, z)
		hrp.Anchored = true
		hrp.CanCollide = true
		hrp.Color = charDef.Color
		hrp.Material = Enum.Material.SmoothPlastic
		hrp.Parent = model
		model.PrimaryPart = hrp

		if mutDef.Name ~= "None" then
			local aura = Instance.new("SelectionBox")
			aura.Adornee = hrp
			aura.Color3 = mutDef.Color
			aura.Parent = hrp
		end

		model:SetAttribute("CharName", charDef.Name)
		model:SetAttribute("Rarity", charDef.Rarity)
		model:SetAttribute("Mutation", mutDef.Name)
		model:SetAttribute("Income", math.floor(charDef.BaseIncome * mutDef.Multiplier))

		hrp.Touched:Connect(function(hit)
			local char = hit.Parent
			if char and char:FindFirstChild("Humanoid") then
				local player = Players:GetPlayerFromCharacter(char)
				if player and not carriedCreatures[player] then
					local data = {
						Name = charDef.Name,
						Rarity = charDef.Rarity,
						Mutation = mutDef.Name,
						Income = math.floor(charDef.BaseIncome * mutDef.Multiplier),
					}
					CharacterService.SetCarried(player, data)
					model:Destroy()
				end
			end
		end)

		model.Parent = Workspace
	end)
end

function CharacterService.SpawnBonusRarePlus()
	pcall(function()
		-- Filter characters to Rare or better (Weight or Rarity)
		local rareChars = {}
		for _, c in ipairs(Config.Characters) do
			if c.Rarity ~= "Common" then
				table.insert(rareChars, c)
			end
		end
		local charDef = rareChars[math.random(1, #rareChars)] or Config.Characters[3]
		local mutDef = Config.RollMutation()
		CharacterService.SpawnCharacter(charDef, mutDef)
	end)
end

function CharacterService.Init()
	-- Spawn loop
	task.spawn(function()
		while true do
			task.wait(Config.SpawnInterval)
			pcall(function()
				local count = 0
				for _, child in ipairs(Workspace:GetChildren()) do
					if child:IsA("Model") and child.PrimaryPart and child:GetAttribute("CharName") then
						count += 1
					end
				end

				if count < Config.MaxActiveCharacters then
					CharacterService.SpawnCharacter()
				end
			end)
		end
	end)

	-- Base delivery detector loop
	task.spawn(function()
		while true do
			task.wait(0.5)
			pcall(function()
				for player, carried in pairs(carriedCreatures) do
					local char = player.Character
					if char and char.PrimaryPart then
						local plot = BaseService.GetPlayerPlot(player)
						if plot then
							local pad = plot:FindFirstChild("Pad") :: Part?
							if pad and (char.PrimaryPart.Position - pad.Position).Magnitude < 18 then
								local data = EconomyService.GetPlayerData(player)
								if data and #data.Collection < data.MaxSlots then
									table.insert(data.Collection, {
										Name = carried.Name,
										Rarity = carried.Rarity,
										Mutation = carried.Mutation,
										Income = carried.Income,
									})
									EconomyService.RecalculateIncome(player)
									EconomyService.SyncClientData(player)
									CharacterService.SetCarried(player, nil)
								end
							end
						end
					end
				end
			end)
		end
	end)

	print("CharacterService initialized successfully")
end

return CharacterService
