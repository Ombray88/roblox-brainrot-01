--!strict

export type CharacterDef = {
	Name: string,
	Rarity: string,
	BaseIncome: number,
	Weight: number,
	Color: Color3,
}

export type MutationDef = {
	Name: string,
	Multiplier: number,
	Chance: number,
	Color: Color3,
}

local Config = {}

Config.Characters = {
	{ Name = "Sir Noodlephant", Rarity = "Common", BaseIncome = 1, Weight = 20, Color = Color3.fromRGB(180, 180, 190) },
	{ Name = "Captain Picklebeard", Rarity = "Common", BaseIncome = 2, Weight = 20, Color = Color3.fromRGB(50, 160, 80) },
	{ Name = "DJ Toaster", Rarity = "Rare", BaseIncome = 5, Weight = 15, Color = Color3.fromRGB(200, 200, 210) },
	{ Name = "Professor Sock", Rarity = "Rare", BaseIncome = 8, Weight = 15, Color = Color3.fromRGB(240, 240, 250) },
	{ Name = "Bananaconda", Rarity = "Epic", BaseIncome = 15, Weight = 7.5, Color = Color3.fromRGB(240, 220, 50) },
	{ Name = "Waffle Wizard", Rarity = "Epic", BaseIncome = 25, Weight = 7.5, Color = Color3.fromRGB(210, 160, 100) },
	{ Name = "The Grand Gherkin", Rarity = "Legendary", BaseIncome = 50, Weight = 5, Color = Color3.fromRGB(30, 120, 50) },
	{ Name = "Turbo Turnip", Rarity = "Legendary", BaseIncome = 80, Weight = 5, Color = Color3.fromRGB(140, 60, 160) },
	{ Name = "Quantum Quokka", Rarity = "Mythic", BaseIncome = 150, Weight = 4, Color = Color3.fromRGB(0, 220, 255) },
	{ Name = "The Almighty Avocado", Rarity = "Secret", BaseIncome = 300, Weight = 1, Color = Color3.fromRGB(255, 215, 0) },
} :: { CharacterDef }

Config.Mutations = {
	{ Name = "None", Multiplier = 1, Chance = 70, Color = Color3.fromRGB(255, 255, 255) },
	{ Name = "Golden", Multiplier = 2, Chance = 15, Color = Color3.fromRGB(255, 215, 0) },
	{ Name = "Frozen", Multiplier = 1.5, Chance = 8, Color = Color3.fromRGB(100, 200, 255) },
	{ Name = "Shadow", Multiplier = 2.5, Chance = 5, Color = Color3.fromRGB(80, 40, 120) },
	{ Name = "Rainbow", Multiplier = 3, Chance = 2, Color = Color3.fromRGB(255, 100, 255) },
} :: { MutationDef }

Config.SlotPrices = {
	100,
	500,
	2500,
	10000,
	25000,
	50000,
	100000,
	200000,
}

Config.BaseLockCost = 500
Config.BaseLockDuration = 60
Config.BaseLockCooldown = 120

Config.WaveCycleTime = 180
Config.WaveWarningTime = 30
Config.WaveDuration = 8

Config.MaxActiveCharacters = 14
Config.SpawnInterval = 6

function Config.RollCharacter(): CharacterDef
	local totalWeight = 0
	for _, char in ipairs(Config.Characters) do
		totalWeight += char.Weight
	end
	local roll = math.random() * totalWeight
	local current = 0
	for _, char in ipairs(Config.Characters) do
		current += char.Weight
		if roll <= current then
			return char
		end
	end
	return Config.Characters[1]
end

function Config.RollMutation(): MutationDef
	local roll = math.random(1, 100)
	local current = 0
	for _, mut in ipairs(Config.Mutations) do
		current += mut.Chance
		if roll <= current then
			return mut
		end
	end
	return Config.Mutations[1]
end

function Config.GetRebirthCost(rebirths: number): number
	return 25000 * ((rebirths + 1) ^ 2)
end

return Config
