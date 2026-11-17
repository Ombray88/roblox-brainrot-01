--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local Server = ServerScriptService:WaitForChild("Server")

local WorldBuilder = require(Server:WaitForChild("WorldBuilder"))
local EconomyService = require(Server:WaitForChild("EconomyService"))
local BaseService = require(Server:WaitForChild("BaseService"))
local CharacterService = require(Server:WaitForChild("CharacterService"))
local StealService = require(Server:WaitForChild("StealService"))
local WaveService = require(Server:WaitForChild("WaveService"))
local RebirthService = require(Server:WaitForChild("RebirthService"))

print("Starting Brainrot Bay server...")

pcall(function()
	WorldBuilder.BuildWorld()
end)

pcall(function()
	EconomyService.Init()
end)

pcall(function()
	BaseService.Init()
end)

pcall(function()
	CharacterService.Init()
end)

pcall(function()
	StealService.Init()
end)

pcall(function()
	WaveService.Init()
end)

pcall(function()
	RebirthService.Init()
end)

print("Brainrot Bay server initialized successfully!")
