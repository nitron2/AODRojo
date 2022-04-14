--[[**
	This script is intended to receive all remotes fired from clients,
	and then use many server-side only modules to execute the required code. This is to 
	make the game more modular and resuable and flexible and readible? Maybe
	Files in this game should follow the the DOTANDIW: 
	"Do one thing an do it well"

	Each function within this file will be as short as possible, with the big code being outsourced
	to module scripts.
**--]]--Description

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PlayerData = ServerStorage.PlayerData
local FootprintsTable = require(ReplicatedStorage.Scripts.FootprintCheck.FootprintsTable)

local updateCurrentDisaster = require(ServerStorage.Scripts.Disasters["UpdateCurrentDisaster"])
local validateDisaster = require(ServerStorage.Scripts.Disasters["ValidateDisaster"])
local packageStats = require(ServerStorage.Scripts.Stats["PackageStats"])
local serializeStats = require(ServerStorage.Scripts.Stats["SerializeStats"])

local Remotes = ReplicatedStorage.Remotes

Remotes["UpdateCurrentDisaster"].OnServerEvent:Connect(function(player, disaster)
	updateCurrentDisaster(player, disaster)
end)

Remotes["ValidateDisaster"].OnServerEvent:Connect(function(player, mouseHit, clientActivatedAreas)
	validateDisaster(player, mouseHit, clientActivatedAreas)
end) 

Remotes["CheckFootprintQuery"].OnServerInvoke = function(player, mouseX, mouseZActual, footprintsToSearchFor)
	return FootprintsTable:checkFootprintQuery(mouseX, mouseZActual, footprintsToSearchFor)
end

Remotes["GetStats"].OnServerInvoke = function(player)
	return packageStats(player)
end

Remotes["SerializeStats"].OnServerInvoke = function(player)
	return serializeStats(player)
end











