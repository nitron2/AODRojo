local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

local AreasTable = require(ReplicatedStorage.Scripts.AreasTable.AreasTable)
local footprintsTable = require(ReplicatedStorage.Scripts.FootprintCheck.FootprintsTable)
local Stamina = require(ServerStorage.Scripts.Stamina.Classes.Stamina)
local DisastersSpecs = require(ServerStorage.Scripts.Specs.DisasterSpecs.DisasterSpecs)

local Fire = require(ServerStorage.Scripts.Disasters.Classes.Fire)
local Lightning = require(ServerStorage.Scripts.Disasters.Classes.Lightning)
local Tsunami = require(ServerStorage.Scripts.Disasters.Classes.Tsunami)
local AcidRain = require(ServerStorage.Scripts.Disasters.Classes.AcidRain)
local TropicalStorm = require(ServerStorage.Scripts.Disasters.Classes.TropicalStorm)

local Validations = require(ReplicatedStorage.Scripts.Validations.Validations)

local newAreasTable = AreasTable.new()
local PlayerData = ServerStorage.PlayerData

--[[**
	This module is a single function which, upon being called by
	the user pressing the button to place their desired disaster,
	will be called through RemoteHandler and make sure that the user 
	can place their disaster. If so, call the appropriate module 
	and method which will initiate the disaster. The validation uses 
	AreasTable, Stamina DisasterSpecs, and compareTwoTables modules, 
	and some validations to work. 

	**For now, the module receives clientActivatedAreas list and
	takes the time to iterate and compare with serverActivatedAreas. Ihis 
	will change and is unessesary but I thought I was doing for security 
	reasons.**

	Footprints
		-Only invalidate disaster if every footprint is activated.

	@param [t:intance] player
	@param [t:tuple] mouseHit
	@param [t:table] clientActivatedAreas
	@usage Hotbar LocalScript
**--]]

return function(player, mouseHit)	
	local playerData = PlayerData:FindFirstChild(player.Name)
	local currentDisaster = playerData.WorldModelInteraction.CurrentDisaster.Value --// String
	local currentDisasterSpecs = DisastersSpecs[currentDisaster]
	local playerStamina = Stamina.getPlayerStamina(player)
	
	local targetTile
	local areasToSearchFor
	local activatedAreas
	local activatedAndTouchedFootPrints
	
	targetTile = newAreasTable:getTargetTile(mouseHit.X, mouseHit.Z)
	if targetTile then
		areasToSearchFor = newAreasTable:getAreasToSearchForFromTargetTile(targetTile)
		activatedAreas = newAreasTable:checkAreaQuery(mouseHit.X, math.abs(mouseHit.Z), areasToSearchFor)
	end
	
	local function isStaminaStatusMet()
		if not playerStamina then
			playerStamina = Stamina.new(player)
		end
		if currentDisasterSpecs.FatiguePercentToll <= (100 - playerStamina.Fatigue) 
			and playerStamina['Using'] == false 
		then
			return true
		else 
			return false
		end
	end
	
	local function getTouchedFootprints(targetTile)
		local footprintsToSearchFor = footprintsTable:getFootprintsToSearchForFromTargetTile(targetTile)
		if footprintsToSearchFor and #footprintsToSearchFor > 0 then
			return footprintsTable:checkFootprintQuery(mouseHit.X, mouseHit.Z, footprintsToSearchFor)
		end
	end
	
	--print("isAreasSatusMet(): " .. tostring(isAreasSatusMet()))
	--print("isStaminaStatusMet(): " .. tostring(isStaminaStatusMet()))
	--print("isFootprintStatusMet(): " .. tostring(isFootprintStatusMet()))
	
	activatedAndTouchedFootPrints = getTouchedFootprints(targetTile)
	
	if Validations.isAreas(activatedAreas) 
		and isStaminaStatusMet() 
		and not Validations.isMouseInActivatedFootprint(activatedAndTouchedFootPrints)
		and ServerStorage.GameStages.InProg.Value == true
	then
		if Validations.isCountry(activatedAreas) then
			local newDisaster
			if currentDisaster == "Fire" then
				newDisaster = Fire.new(player, playerData, currentDisasterSpecs, activatedAreas, mouseHit)
			elseif currentDisaster == "Lightning" then
				newDisaster = Lightning.new(player, playerData, currentDisasterSpecs, activatedAreas, mouseHit)
			elseif currentDisaster == "AcidRain" then
				newDisaster = AcidRain.new(player, playerData, currentDisasterSpecs, activatedAreas, mouseHit)
			elseif currentDisaster == "Tsunami" then
				if Validations.isCoast(activatedAreas) then
					newDisaster = Tsunami.new(player, playerData, currentDisasterSpecs, activatedAreas, mouseHit)
				end
			elseif currentDisaster == "TropicalStorm" then
				newDisaster = TropicalStorm.new(player, playerData, currentDisasterSpecs, activatedAreas, mouseHit)
			end
			if newDisaster then
				newDisaster:run(playerStamina)
			end
		end
	end
end
