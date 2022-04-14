--[[**
	This module contains disaster-specific methods. It's important that you call 
	this the exact same name as the name of the disaster you are trying to run.
	The reason why each disaster has its own module is because disasters have different
	ways of animating etc.

 	@usage:	ValidateDisaster
	@returns self
**--]]--Description

local ServerStorage = game:GetService('ServerStorage')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Disaster = require(ServerStorage.Scripts.Disasters.Classes.Disaster)
local Footprint = require(ServerStorage.Scripts.Footprints.Classes.Footprint)
local scaleModel = require(ServerStorage.Scripts.Libraries.ScaleModel)
local GridSpecs = require(ServerStorage.Scripts.Specs.GridSpecs.GridSpecs)

local Validations = require(ReplicatedStorage.Scripts.Validations.Validations)

local AcidRainAssets = ServerStorage.DisasterAssets.AcidRain

AcidRain = {}
AcidRain.__index = AcidRain
setmetatable(AcidRain, Disaster)

--[[**
	Create a new disaster of the specific type. This type inherits all
	the normal disaster methods, and methods that are Fire-specific are
	described in this Module, including the specific code to run the fire.
	
	@param [t:instance] player Player which placed disaster
	@param [t:table] initialData Data from the module 'DisasterSpecs'
	@param [t:table] activatedAreas Data from the client after it was corssed-referenced inside ValidateDisaster
	@returns [t:table] newFire Object which holds all initial important data for the game interaction
**--]]

function AcidRain.new(player, initialData, currentDisasterSpecs, activatedAreas, mouseHit)
	local newAcidRain = Disaster.new(player, initialData, currentDisasterSpecs, activatedAreas, mouseHit)
	setmetatable(newAcidRain, AcidRain)
	return newAcidRain
end

--[[**
	This is where the disaster-specific acquiring of the model occurs, as well
	as specific damage multiplier determinations that affect gameplay.
	it is always the case because many disasters have different ways of 
	choosing their specific models based on varying conditions.
	
	@returns [t:instance] model Model cloned and to be given to run to place model at initial placement
**--]]


function AcidRain:setCurrentDamageBasedOnMultiplier()
	if Validations.isCity(self['AreasPresent']) then
		self['CurrentDamage'] = self['BaseDamage'] * 1.5
		self['CurrentDamageMultiplier'] = 1.5
		return
	end
	self['CurrentDamage'] = self['BaseDamage'] * 1
	self['CurrentDamageMultiplier'] = 1
	return
end

function AcidRain:getModel()
	if Validations.isCity(self['AreasPresent']) then
		local cityModels = {"AcidRain_City_1", "AcidRain_City_2"}
		local cityModelChosen = AcidRainAssets[cityModels[math.random(1, #cityModels)]]
		return cityModelChosen:Clone()
	end
	return AcidRainAssets.AcidRain_Normal:Clone()
end

	--// Could also include math.random stuff here to get variety of models
	--// Also on water, fure should be small

--[[**
	This is called whever the current damage of the disaster changes.
	This is done here and not in the Disaster module becuase different disasters have
	different ways of accomplishing a resize.
**--]]

function AcidRain:resizeModel()
	local scalar = self['CurrentDamage'] / self['BaseDamage']
	scaleModel(self['Model'], scalar) 
end

function AcidRain:positionModel(modelToPlace)
	local randomAngle = CFrame.Angles(0, math.random(-360, 360), 0)
	local X = self['PositionInWorld']['X']
	local Z = self['PositionInWorld']['Z']
	modelToPlace:SetPrimaryPartCFrame(CFrame.new(X, GridSpecs.Y_MAP_LEVEL, Z) * randomAngle)
end

--function soundHandler()
--end

function AcidRain:removeModel()
	self['Model']:Destroy()
end

--Other fire-specific functions using coroutines and such

function AcidRain:run(playerStamina)
	local newFootprint
	coroutine.wrap(function() self:tollStamina(playerStamina, self['CurrentDisasterSpecsLocation']) end)()
	self:setCurrentDamageBasedOnMultiplier()
	self:setCurrentDamagePerPass()
	self['Model'] = self:getModel()
	self:positionModel(self['Model'])
	self:resizeModel()
	self:placeModel()
	newFootprint = Footprint.new(self)
	self:performPasses()
	--// Resize Footprint if the currentDamage changes; 
	--// resize it to that current damage size!!! 
	--// It's done with the model so it should be done with the 
	--// footprint.
	self:removeModel()
	newFootprint:setGeometry(self['TotalDamageDealt'])
	newFootprint:show()
end

return AcidRain