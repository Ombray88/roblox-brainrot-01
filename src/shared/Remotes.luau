--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}

function Remotes.GetRemote(name: string): RemoteEvent
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		if RunService:IsServer() then
			folder = Instance.new("Folder")
			folder.Name = "Remotes"
			folder.Parent = ReplicatedStorage
		else
			folder = ReplicatedStorage:WaitForChild("Remotes", 5)
		end
	end
	
	local remote = folder and folder:FindFirstChild(name)
	if not remote and RunService:IsServer() and folder then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
	return remote :: RemoteEvent
end

return Remotes
