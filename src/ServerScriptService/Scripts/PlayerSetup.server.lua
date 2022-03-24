--[[**
	This script is meant to set up players as they enter. On enter, copy and
	paste the template for each player. Various data is set here also.
	
**--]]--Description

local ServerStorage = game:GetService("ServerStorage")
local PlayerDataTemplate = ServerStorage:WaitForChild("PlayerDataTemplate")
local PlayerDataContainer = ServerStorage.PlayerData

--repeat 
--	wait() 
--until (ReplicatedFirst.AssetLoading.Ready.Value == true)

--[[** 
Instan, tiate new player data, disable jumping

@param player Player that's entering the game
**--]]

function onPlayerAdded(player)
	local colors = ServerStorage.Colors:GetChildren()
	local colorValues = {}
	for _, color in pairs(colors) do
		table.insert(colorValues, color.Value)
	end
	for _, player in pairs(game.Players:GetChildren()) do
		local plrData = PlayerDataContainer:FindFirstChild(player.Name)
		if plrData then
			if plrData.Color.Value then
				table.remove(colorValues, table.find(colorValues, plrData.Color.Value))
			end
		end
	end
	local colorValue = colorValues[math.random(1, #colorValues)]
	local newPlayerData = PlayerDataTemplate:Clone()
	local userId = player.UserId
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size420x420
	--// Feel like you are going to need to handle this error somehow if it throws
	local content, isReady = game.Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
	
	newPlayerData.AvatarIcon.Value = content
	newPlayerData.Name = player.Name
	newPlayerData.Player.Value = player
	newPlayerData.Color.Value = colorValue
	newPlayerData.Parent = PlayerDataContainer

	player.CharacterAdded:Connect(function(character)	
		character.Humanoid.JumpPower = 0	
	end)	
	
	player:SetAttribute("IsInfoPaneOpen", true)
end

--[[** 
@param player Player that's leaving the game
**--]]

local function onPlayerRemoving(player)
	if PlayerDataContainer and #PlayerDataContainer:GetChildren() > 0 then
		for i , v in pairs(PlayerDataContainer:GetChildren()) do
			if v.Player then
				if v.Player.Value == player then
					v:Destroy()
				end
			end
		end
	end
end

game.Players.PlayerAdded:Connect(onPlayerAdded)
game.Players.PlayerRemoving:Connect(onPlayerRemoving)

