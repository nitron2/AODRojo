--[[**
	This module contains disaster-specific methods. It's important that you call 
	this the exact same name as the name of the disaster you are trying to run.
	The reason why each disaster has its own module is because disasters have different
	ways of animating etc.

 	@usage:	ValidateDisaster
	@returns self
**--]]--Description

local ServerStorage = game:GetService('ServerStorage')
local Disaster = require(ServerStorage.Scripts.Disasters.Classes.Disaster)
local Footprint = require(ServerStorage.Scripts.Footprints.Classes.Footprint)
local scaleModel = require(ServerStorage.Scripts.Libraries.ScaleModel)
local GridSpecs = require(ServerStorage.Scripts.Specs.GridSpecs.GridSpecs)

local LightningAssets = ServerStorage.DisasterAssets.Lightning

Lightning = {}
Lightning.__index = Lightning
setmetatable(Lightning, Disaster)

--[[**
	Create a new disaster of the specific type. This type inherits all
	the normal disaster methods, and methods that are Lightning-specific are
	described in this Module, including the specific code to run the Lightning.
	
	@param [t:instance] player Player which placed disaster
	@param [t:table] initialData Data from the module 'DisasterSpecs'
	@param [t:table] activatedAreas Data from the client after it was corssed-referenced inside ValidateDisaster
	@returns [t:table] newLightning Object which holds all initial important data for the game interaction
**--]]

function Lightning.new(player, initialData, currentDisasterSpecs, activatedAreas, mouseHit)
	local newLightning = Disaster.new(player, initialData, currentDisasterSpecs, activatedAreas, mouseHit)
	setmetatable(newLightning, Lightning)
	return newLightning
end

--[[**
	This is where the disaster-specific acquiring of the model occurs, as well
	as specific damage multiplier determinations that affect gameplay.
	it is always the case because many disasters have different ways of 
	choosing their specific models based on varying conditions.
	
	@returns [t:instance] model Model cloned and to be given to run to place model at initial placement
**--]]
function Lightning:setCurrentDamageBasedOnMultiplier()
	self['CurrentDamage'] = self['BaseDamage']
	self['CurrentDamageMultiplier'] = 1
end

function Lightning:getModel()
	return LightningAssets.Lightning_Normal:Clone()
end

function Lightning:resizeModel()
	local scalar = self['CurrentDamage'] / self['BaseDamage']
	scaleModel(self['Model'], scalar) 
end
	--// Could also include math.random stuff here to get variety of models
	--// Also on water, fure should be small


--[[**
	This is called whever the current damage of the disaster changes.
	This is done here and not in the Disaster module becuase different disasters have
	different ways of accomplishing a resize.
**--]]

function Lightning:positionModel(modelToPlace)
	local randomAngle = CFrame.Angles(0, math.random(-360, 360), 0)
	local X = self['PositionInWorld']['X']
	local Z = self['PositionInWorld']['Z']
	modelToPlace:SetPrimaryPartCFrame(CFrame.new(X, GridSpecs.Y_MAP_LEVEL, Z) * randomAngle)
end

--function soundHandler()
--end

function Lightning:removeModel()
	self['Model']:Destroy()
end

function Lightning:getRandomEffectModel()
	local Models = {
		self['Model'].Model3:GetChildren(),
		self['Model'].Model2:GetChildren(),
		self['Model'].Model1:GetChildren()
	}
	return Models[math.random(1,#Models)]
end

function Lightning:flashOn(modelChoice)
	for i,v in pairs(modelChoice) do
		v.Transparency = 0
	end
	self['Model'].MainPart.PointLight.Enabled = true
end

function Lightning:flashOff(effectModelChoice)
	for i,v in pairs(effectModelChoice) do
		v.Transparency = 1
	end
	self['Model'].MainPart.PointLight.Enabled = false
end

function Lightning:performPasses()
	local RNG = Random.new(tick())
	for i = 1, self['NumberOfPasses'] do
		local damageDealt
		local effectModelChoice 
		effectModelChoice = self:getRandomEffectModel()
		self:flashOn(effectModelChoice)
		damageDealt = self:dealDamage()
		coroutine.wrap(function() self:displayDamage(damageDealt) end)()
		wait(0.125)
		self:flashOff(effectModelChoice)
		wait(RNG:NextNumber(table.unpack(self['TimeBetweenPasses'])))
	end
end

--Other Lightning-specific functions using coroutines and such

function Lightning:run(playerStamina)
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

return Lightning