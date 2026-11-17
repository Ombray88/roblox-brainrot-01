--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 5)
local function getRemote(name: string): RemoteEvent?
	if remotesFolder then
		return remotesFolder:WaitForChild(name, 5) :: RemoteEvent?
	end
	return nil
end

local dataSyncEvent = getRemote("DataSync")
local waveWarningEvent = getRemote("WaveWarning")
local waveHitEvent = getRemote("WaveHit")
local stealAlertEvent = getRemote("StealAlert")
local rebirthDoneEvent = getRemote("RebirthDone")
local rebirthRequestEvent = getRemote("RebirthRequest")

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotBayGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- Start Screen
local startScreen = Instance.new("Frame")
startScreen.Name = "StartScreen"
startScreen.Size = UDim2.fromScale(1, 1)
startScreen.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
startScreen.Parent = gui

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(0, 700, 0, 90)
titleLabel.AnchorPoint = Vector2.new(0.5, 0)
titleLabel.Position = UDim2.new(0.5, 0, 0.15, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Brainrot Bay"
titleLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
titleLabel.TextSize = 48
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.Parent = startScreen

local instructions = Instance.new("TextLabel")
instructions.Name = "Instructions"
instructions.Size = UDim2.new(0, 750, 0, 160)
instructions.AnchorPoint = Vector2.new(0.5, 0)
instructions.Position = UDim2.new(0.5, 0, 0.32, 0)
instructions.BackgroundTransparency = 1
instructions.Text = "1. Catch meme creatures walking the plaza & conveyor!\n2. Carry them to your base pad to earn $/s.\n3. Sprint home when the Noodle Tsunami horn sounds!"
instructions.TextColor3 = Color3.fromRGB(240, 240, 240)
instructions.TextSize = 26
instructions.Font = Enum.Font.SourceSansBold
instructions.TextWrapped = true
instructions.Parent = startScreen

local playButton = Instance.new("TextButton")
playButton.Name = "PlayButton"
playButton.Size = UDim2.new(0, 260, 0, 75)
playButton.AnchorPoint = Vector2.new(0.5, 0)
playButton.Position = UDim2.new(0.5, 0, 0.62, 0)
playButton.BackgroundColor3 = Color3.fromRGB(80, 210, 100)
playButton.Text = "PLAY"
playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playButton.TextSize = 38
playButton.Font = Enum.Font.FredokaOne
playButton.Parent = startScreen

local playCorner = Instance.new("UICorner")
playCorner.CornerRadius = UDim.new(0, 12)
playCorner.Parent = playButton

-- Main HUD (hidden until play)
local hud = Instance.new("Frame")
hud.Name = "HUD"
hud.Size = UDim2.fromScale(1, 1)
hud.BackgroundTransparency = 1
hud.Visible = false
hud.Parent = gui

-- Top-Centre Money & Income
local moneyLabel = Instance.new("TextLabel")
moneyLabel.Name = "MoneyLabel"
moneyLabel.Size = UDim2.new(0, 450, 0, 65)
moneyLabel.AnchorPoint = Vector2.new(0.5, 0)
moneyLabel.Position = UDim2.new(0.5, 0, 0.02, 0)
moneyLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
moneyLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
moneyLabel.TextSize = 28
moneyLabel.Font = Enum.Font.FredokaOne
moneyLabel.Text = "$50 (+0/s)"
moneyLabel.Parent = hud

local moneyCorner = Instance.new("UICorner")
moneyCorner.CornerRadius = UDim.new(0, 10)
moneyCorner.Parent = moneyLabel

-- Top-Right Wave Timer & Rebirth Button container
local topConfigRight = Instance.new("Frame")
topConfigRight.Size = UDim2.new(0, 250, 0, 70)
topConfigRight.AnchorPoint = Vector2.new(1, 0)
topConfigRight.Position = UDim2.new(0.98, 0, 0.02, 0)
topConfigRight.BackgroundTransparency = 1
topConfigRight.Parent = hud

local waveTimerLabel = Instance.new("TextLabel")
waveTimerLabel.Name = "WaveTimer"
waveTimerLabel.Size = UDim2.new(0, 250, 0, 30)
waveTimerLabel.Position = UDim2.new(0, 0, 0, 0)
waveTimerLabel.BackgroundTransparency = 1
waveTimerLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
waveTimerLabel.TextSize = 24
waveTimerLabel.Font = Enum.Font.FredokaOne
waveTimerLabel.Text = "Wave in: 180s"
waveTimerLabel.Parent = topConfigRight

local rebirthButton = Instance.new("TextButton")
rebirthButton.Name = "RebirthButton"
rebirthButton.Size = UDim2.new(0, 200, 0, 45)
rebirthButton.Position = UDim2.new(0.2, 0, 0.35, 0)
rebirthButton.BackgroundColor3 = Color3.fromRGB(160, 50, 220)
rebirthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthButton.TextSize = 24
rebirthButton.Font = Enum.Font.FredokaOne
rebirthButton.Text = "Rebirth ($25k)"
rebirthButton.Parent = topConfigRight

local rebirthCorner = Instance.new("UICorner")
rebirthCorner.CornerRadius = UDim.new(0, 8)
rebirthCorner.Parent = rebirthButton

-- Bottom-Centre Collection Strip
local collectionStrip = Instance.new("ScrollingFrame")
collectionStrip.Name = "CollectionStrip"
collectionStrip.Size = UDim2.new(0, 700, 0, 110)
collectionStrip.AnchorPoint = Vector2.new(0.5, 1)
collectionStrip.Position = UDim2.new(0.5, 0, 0.98, 0)
collectionStrip.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
collectionStrip.BackgroundTransparency = 0.3
collectionStrip.CanvasSize = UDim2.new(2, 0, 0, 0)
collectionStrip.ScrollBarThickness = 6
collectionStrip.Parent = hud

local stripCorner = Instance.new("UICorner")
stripCorner.CornerRadius = UDim.new(0, 10)
stripCorner.Parent = collectionStrip

local stripLayout = Instance.new("UIListLayout")
stripLayout.FillDirection = Enum.FillDirection.Horizontal
stripLayout.SortOrder = Enum.SortOrder.LayoutOrder
stripLayout.Padding = UDim.new(0, 10)
stripLayout.Parent = collectionStrip

-- Banners container
local bannerContainer = Instance.new("Frame")
bannerContainer.Size = UDim2.new(0, 600, 0, 80)
bannerContainer.AnchorPoint = Vector2.new(0.5, 0)
bannerContainer.Position = UDim2.new(0.5, 0, 0.12, 0)
bannerContainer.BackgroundTransparency = 1
bannerContainer.Parent = hud

local alertLabel = Instance.new("TextLabel")
alertLabel.Size = UDim2.fromScale(1, 1)
alertLabel.BackgroundTransparency = 0.2
alertLabel.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
alertLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
alertLabel.TextSize = 26
alertLabel.Font = Enum.Font.FredokaOne
alertLabel.Text = ""
alertLabel.Visible = false
alertLabel.Parent = bannerContainer

local alertCorner = Instance.new("UICorner")
alertCorner.CornerRadius = UDim.new(0, 8)
alertCorner.Parent = alertLabel

-- Play button click handler
playButton.MouseButton1Click:Connect(function()
	startScreen.Visible = false
	hud.Visible = true
end)

-- Rebirth button click handler
rebirthButton.MouseButton1Click:Connect(function()
	if rebirthRequestEvent then
		rebirthRequestEvent:FireServer()
	end
end)

-- Remote Event Listeners
if dataSyncEvent then
	dataSyncEvent.OnClientEvent:Connect(function(data)
		moneyLabel.Text = "$" .. tostring(data.Money) .. " (+" .. tostring(data.IncomeRate) .. "/s)"
		
		-- Rebuild collection strip
		for _, child in ipairs(collectionStrip:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end

		for _, item in ipairs(data.Collection) do
			local card = Instance.new("Frame")
			card.Size = UDim2.new(0, 120, 0, 90)
			card.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
			card.Parent = collectionStrip

			local cardCorner = Instance.new("UICorner")
			cardCorner.CornerRadius = UDim.new(0, 6)
			cardCorner.Parent = card

			local nameL = Instance.new("TextLabel")
			nameL.Size = UDim2.new(1, 0, 0, 35)
			nameL.BackgroundTransparency = 1
			nameL.Text = item.Name
			nameL.TextColor3 = Color3.fromRGB(255, 255, 255)
			nameL.TextSize = 16
			nameL.Font = Enum.Font.SourceSansBold
			nameL.TextWrapped = true
			nameL.Parent = card

			local infoL = Instance.new("TextLabel")
			infoL.Size = UDim2.new(1, 0, 0, 45)
			infoL.Position = UDim2.new(0, 0, 0, 35)
			infoL.BackgroundTransparency = 1
			infoL.Text = item.Rarity .. "\n[" .. item.Mutation .. "]\n+$" .. tostring(item.Income) .. "/s"
			infoL.TextColor3 = Color3.fromRGB(200, 200, 200)
			infoL.TextSize = 14
			infoL.Font = Enum.Font.SourceSans
			infoL.Parent = card
		end
	end)
end

if waveWarningEvent then
	waveWarningEvent.OnClientEvent:Connect(function(secondsLeft)
		if secondsLeft > 0 then
			waveTimerLabel.Text = "Wave in: " .. tostring(secondsLeft) .. "s"
			if secondsLeft <= 10 then
				waveTimerLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
			end
		else
			waveTimerLabel.Text = "TSUNAMI WAVE!"
		end
	end)
end

if waveHitEvent then
	waveHitEvent.OnClientEvent:Connect(function(isHit)
		if isHit then
			alertLabel.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
			alertLabel.Text = "🌊 Noodle Tsunami sweeping the island! Sprint to your base!"
			alertLabel.Visible = true
		else
			task.delay(3, function()
				alertLabel.Visible = false
			end)
		end
	end)
end

if stealAlertEvent then
	stealAlertEvent.OnClientEvent:Connect(function(stealerName, charName)
		alertLabel.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
		alertLabel.Text = "⚠️ " .. stealerName .. " is stealing your " .. charName .. "!"
		alertLabel.Visible = true
		task.delay(4, function()
			alertLabel.Visible = false
		end)
	end)
end

if rebirthDoneEvent then
	rebirthDoneEvent.OnClientEvent:Connect(function(rebirthCount)
		alertLabel.BackgroundColor3 = Color3.fromRGB(150, 50, 220)
		alertLabel.Text = "✨ Rebirth #" .. tostring(rebirthCount) .. "! Income multiplier increased!"
		alertLabel.Visible = true
		task.delay(5, function()
			alertLabel.Visible = false
		end)
	end)
end

gui.Parent = player:WaitForChild("PlayerGui")
print("Game client UI initialized successfully.")
