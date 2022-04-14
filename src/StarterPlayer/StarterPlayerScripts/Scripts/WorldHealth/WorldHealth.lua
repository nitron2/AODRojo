local WorldHealth = {}
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Remotes = ReplicatedStorage.Remotes
local PlayerGui = game.Players.LocalPlayer.PlayerGui
local WorldHealthGui = PlayerGui.WorldHealth.WorldHealth
local MainBar = WorldHealthGui.MainBar
local TemplateBar = WorldHealthGui.Template.TemplateBar

local function  getTotalSizeOfPreviousBars(currentPlayerData, currentPlayerPositionInArray)
	local totalSizeOfPreviousBars = 0
	for _, frame in pairs(MainBar:GetChildren()) do
		if frame.ArrayPosition.Value < currentPlayerPositionInArray
			and frame.Player.Value ~= currentPlayerData.Player then
			totalSizeOfPreviousBars = totalSizeOfPreviousBars + frame.Size.X.Scale
		end
	end
	return totalSizeOfPreviousBars
end

local function setupNewBar(currentPlayerData, currentPlayerPositionInArray)
	local currentPlayerBar = TemplateBar:Clone()
	currentPlayerBar.Name = currentPlayerData.Player.Name
	currentPlayerBar.Player.Value = currentPlayerData.Player
	currentPlayerBar.BackgroundColor3 = Color3.fromHSV(unpack(currentPlayerData.Color))
	currentPlayerBar.Parent = MainBar
	currentPlayerBar.Visible = true
	return currentPlayerBar
end

local function getCurrentPlayerBar(currentPlayerData)
	for _, bar in pairs(MainBar:GetChildren()) do
		if bar.Player.Value == currentPlayerData.Player then
			return bar
		end
	end
	return setupNewBar(currentPlayerData)
end

local function removeOldBars()
	for _, frame in pairs(MainBar:GetChildren()) do
		if not table.find(game.Players:GetChildren(), frame.Player.Value) then
			frame:Destroy()
		end
	end
end

local function playerDamageComparator(thisTable, thatTable)
	 return thisTable.Stats.Damage > thatTable.Stats.Damage
end

function WorldHealth.updateGui()
	wait()
	local playerData, worldStats = Remotes.SerializeStats:InvokeServer()
	if worldStats then
		local totalSizeOfPreviousBars
		local currentPlayerBar
		table.sort(playerData, playerDamageComparator)
		MainBar.Size = UDim2.new(worldStats.Defecit / worldStats.Max,0,1,0)
		for i, currentPlayerData in pairs(playerData) do
			currentPlayerBar = getCurrentPlayerBar(currentPlayerData)
			currentPlayerBar.ArrayPosition.Value = i
			totalSizeOfPreviousBars = getTotalSizeOfPreviousBars(currentPlayerData, i) --put current bar at position end of last (sum of all current bars' size) save for this own
			currentPlayerBar.Position = UDim2.new(totalSizeOfPreviousBars,0,0,0)
			currentPlayerBar.Size = UDim2.new(currentPlayerData.Damage / worldStats.Defecit,0,1,0) 
		end
		removeOldBars()
	end
end

return WorldHealth
