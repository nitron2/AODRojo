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
local TweenService = game:GetService('TweenService')
local Disaster = require(ServerStorage.Scripts.Disasters.Classes.Disaster)
local Footprint = require(ServerStorage.Scripts.Footprints.Classes.Footprint)
local scaleModel = require(ServerStorage.Scripts.Libraries.ScaleModel)

local Validations = require(ReplicatedStorage.Scripts.Validations.Validations)

local TsunamiAssets = ServerStorage.DisasterAssets.Tsunami

Tsunami = {}
Tsunami.__index = Tsunami
setmetatable(Tsunami, Disaster)

--[[**
	Create a new disaster of the specific type. This type inherits all
	the normal disaster methods, and methods that are Tsunami-specific are
	described in this Module, including the specific code to run the Tsunami.
	
	@param [t:instance] player Player which placed disaster
	@param [t:table] initialData Data from the module 'DisasterSpecs'
	@param [t:table] activatedAreas Data from the client after it was corssed-referenced inside ValidateDisaster
	@returns [t:table] newTsunami Object which holds all initial important data for the game interaction
**--]]

function Tsunami.new(player, initialData, currentDisasterSpecs, activatedAreas, mouseHit)
	local newTsunami = Disaster.new(player, initialData, currentDisasterSpecs, activatedAreas, mouseHit)
	setmetatable(newTsunami, Tsunami)
	return newTsunami
end

--[[**
	This is where the disaster-specific acquiring of the model occurs, as well
	as specific damage multiplier determinations that affect gameplay.
	it is always the case because many disasters have different ways of 
	choosing their specific models based on varying conditions.
	
	@returns [t:instance] model Model cloned and to be given to run to place model at initial placement
**--]]

function Tsunami:setCurrentDamageBasedOnMultiplier()
	if Validations.isTsunamiHZ(self['AreasPresent']) then
		self['CurrentDamage'] = self['BaseDamage'] * 1.5
		self['CurrentDamageMultiplier'] = 1.5
		return
	end
	self['CurrentDamage'] = self['BaseDamage'] * 1
	self['CurrentDamageMultiplier'] = 1
	return
end

function Tsunami:getModel()
	return TsunamiAssets.Tsunami_Normal:Clone()
end

	--// Could also include math.random stuff here to get variety of models
	--// Also on water, fure should be small

--[[**
	This is called whever the current damage of the disaster changes.
	This is done here and not in the Disaster module becuase different disasters have
	different ways of accomplishing a resize.
**--]]

function Tsunami:resizeModel()
	local scalar = self['CurrentDamage'] / self['BaseDamage']
	scaleModel(self['Model'], scalar) 
	--self['Model']
end

local function getOrientationBasedOnDirection(self)
	if Validations.isCoastEast(self['AreasPresent']) then		
		return CFrame.Angles(0,math.rad(180),0)
	elseif Validations.isCoastWest(self['AreasPresent']) then
		return CFrame.Angles(0,0,0)
	elseif Validations.isCoastNorth(self['AreasPresent']) then
		return CFrame.Angles(0,math.rad(270),0)
	elseif Validations.isCoastSouth(self['AreasPresent']) then
		return CFrame.Angles(0,math.rad(90),0)
	end
end

function Tsunami:positionModel(modelToPlace)
	local X = self['PositionInWorld']['X']
	local Z = self['PositionInWorld']['Z']
	local orientation = getOrientationBasedOnDirection(self)
	modelToPlace:SetPrimaryPartCFrame(CFrame.new(X, 16.973, Z) * orientation)
end

local function getTween1(self, wave, currentWaveRot)
	local point1 = self['Model'].Rigging.Point1
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	local goal = {
		CFrame = CFrame.new(point1.Position) * currentWaveRot
	}
	return TweenService:Create(wave, tweenInfo, goal)
end

local function getTween2(self, wave, currentWaveRot)
	local point2 = self['Model'].Rigging.Point2
	local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	local goal = {
		CFrame = CFrame.new(point2.Position) * currentWaveRot
	}
	return TweenService:Create(wave, tweenInfo, goal)
end

local function getWaterEffectTween(self, wave, END_WAVE_SIZE_INCR_PERC)
	local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0.25)
	local goal = {
		Size = Vector3.new(wave.Size.X + (END_WAVE_SIZE_INCR_PERC / 100 * wave.Size.X), wave.Size.Y, wave.Size.Z)
	}
	return TweenService:Create(wave, tweenInfo, goal)
end

function Tsunami:animate()
	local END_WAVE_SIZE_INCR_PERC = 50
	local wave = self['Model'].Wave
	local currentWaveRot = CFrame.fromEulerAnglesXYZ(wave.CFrame:ToEulerAnglesXYZ())
	local tween1 = getTween1(self, wave, currentWaveRot)
	local tween2 = getTween2(self, wave, currentWaveRot)
	local waterEffect = getWaterEffectTween(self, wave, END_WAVE_SIZE_INCR_PERC)
	
	waterEffect:Play()
	tween1:Play()
	tween1.Completed:wait()
	tween2:Play()
end

--function soundHandler()
--end

function Tsunami:removeModel()
	self['Model']:Destroy()
end

--Other Tsunami-specific functions using coroutines and such

function Tsunami:run(playerStamina)
	local newFootprint
	coroutine.wrap(function() self:tollStamina(playerStamina, self['CurrentDisasterSpecsLocation']) end)()
	self:setCurrentDamageBasedOnMultiplier()
	self:setCurrentDamagePerPass()
	self['Model'] = self:getModel()
	self:positionModel(self['Model'])
	self:resizeModel()
	self:placeModel()
	coroutine.wrap(function() self:animate() end)()
	--coroutine.wrap(function() self:animateWater() end)()
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

return Tsunami