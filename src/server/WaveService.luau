--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local BaseService = require(script.Parent:WaitForChild("BaseService"))
local CharacterService = require(script.Parent:WaitForChild("CharacterService"))
local EconomyService = require(script.Parent:WaitForChild("EconomyService"))

local WaveService = {}

function WaveService.Init()
	local waveWarningEvent = Remotes.GetRemote("WaveWarning")
	local waveHitEvent = Remotes.GetRemote("WaveHit")

	task.spawn(function()
		while true do
			-- Wait until warning time
			task.wait(Config.WaveCycleTime - Config.WaveWarningTime)

			-- Warning phase (30 seconds)
			for i = Config.WaveWarningTime, 1, -1 do
				waveWarningEvent:FireAllClients(i)
				task.wait(1)
			end
			waveWarningEvent:FireAllClients(0)

			-- Wave hit phase (Translucent wave wall sweeping island over ~8s)
			waveHitEvent:FireAllClients(true)

			-- Create a physical wave wall part moving across the island
			pcall(function()
				local waveWall = Instance.new("Part")
				waveWall.Name = "NoodleTsunamiWall"
				waveWall.Size = Vector3.new(350, 40, 20)
				waveWall.Position = Vector3.new(0, 20, -180)
				waveWall.Anchored = true
				waveWall.CanCollide = false
				waveWall.Transparency = 0.5
				waveWall.Color = Color3.fromRGB(0, 150, 255)
				waveWall.Material = Enum.Material.Neon
				waveWall.Parent = Workspace

				local steps = 80
				local dt = Config.WaveDuration / steps
				local zStart = -180
				local zEnd = 180
				for step = 1, steps do
					local alpha = step / steps
					local currentZ = zStart + (zEnd - zStart) * alpha
					waveWall.Position = Vector3.new(0, 20, currentZ)

					-- Check players outside their base
					for _, player in ipairs(Players:GetPlayers()) do
						local carried = CharacterService.GetCarried(player)
						if carried then
							local plot = BaseService.GetPlayerPlot(player)
							local isInsideBase = false
							if plot then
								local pad = plot:FindFirstChild("Pad") :: Part?
								local char = player.Character
								if pad and char and char.PrimaryPart then
									if (char.PrimaryPart.Position - pad.Position).Magnitude < 18 then
										isInsideBase = true
									end
								end
							end

							if not isInsideBase then
								-- Drop carried creature!
								CharacterService.SetCarried(player, nil)
								EconomyService.SyncClientData(player)
								CharacterService.SpawnCharacter() -- respawn in wild
							end
						end
					end

					task.wait(dt)
				end

				waveWall:Destroy()
			end)

			waveHitEvent:FireAllClients(false)

			-- Calm period (10s) + Guaranteed Rare+ bonus spawn
			CharacterService.SpawnBonusRarePlus()
			task.wait(10)
		end
	end)

	print("WaveService initialized successfully")
end

return WaveService
