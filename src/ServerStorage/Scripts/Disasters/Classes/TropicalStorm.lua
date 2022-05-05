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

local TropicalStormAssets = ServerStorage.DisasterAssets.TropicalStorm

TropicalStorm = {}
TropicalStorm.__index = TropicalStorm
setmetatable(TropicalStorm, Disaster)

--[[**
	Create a new disaster of the specific type. This type inherits all
	the normal disaster methods, and methods that are Fire-specific are
	described in this Module, including the specific code to run the fire.
	
	@param [t:instance] player Player which placed disaster
	@param [t:table] initialData Data from the module 'DisasterSpecs'
	@param [t:table] activatedAreas Data from the client after it was corssed-referenced inside ValidateDisaster
	@returns [t:table] newFire Object which holds all initial important data for the game interaction
**--]]

function TropicalStorm.new(player, initialData, currentDisasterSpecs, activatedAreas, mouseHit)
	local newTropicalStorm = Disaster.new(player, initialData, currentDisasterSpecs, activatedAreas, mouseHit)
	setmetatable(newTropicalStorm, TropicalStorm)
	return newTropicalStorm
end

--[[**
	This is where the disaster-specific acquiring of the model occurs, as well
	as specific damage multiplier determinations that affect gameplay.
	it is always the case because many disasters have different ways of 
	choosing their specific models based on varying conditions.
	
	@returns [t:instance] model Model cloned and to be given to run to place model at initial placement
**--]]


function TropicalStorm:setCurrentDamageBasedOnMultiplier()
	if Validations.isCoast(self.AreasPresent) then
		self['CurrentDamage'] = self['BaseDamage'] * 1.5
		self['CurrentDamageMultiplier'] = 1.5
		return
	end
	if Validations.isCoast(self.AreasPresent) and Validations.isDesert(self.AreasPresent) then
		self['CurrentDamage'] = self['BaseDamage'] * 1
		self['CurrentDamageMultiplier'] = 1
	end
	if Validations.isDesert(self.AreasPresent) then
		self['CurrentDamage'] = self['BaseDamage'] * 0.5
		self['CurrentDamageMultiplier'] = 0.5
		return
	end
	self['CurrentDamage'] = self['BaseDamage'] * 1
	self['CurrentDamageMultiplier'] = 1
	return
end

function TropicalStorm:getModel() --MAYBE WANT TO CHANGE STORM HEIGHT BASED OFF OF MODEL TO GET THAT EYE OF THE STROM  MAKING SENSE
	if Validations.isCoast(self.AreasPresent) then
		return TropicalStormAssets.TropicalStorm_Big:Clone()
	end
	if Validations.isCoast(self.AreasPresent) and Validations.isDesert(self.AreasPresent) then
		return TropicalStormAssets.TropicalStorm_Medium:Clone()
	end
	if Validations.isDesert(self.AreasPresent) then
		return TropicalStormAssets.TropicalStorm_Tiny:Clone()
	end
	return TropicalStormAssets.TropicalStorm_Medium:Clone()
end

	--// Could also include math.random stuff here to get variety of models
	--// Also on water, fure should be small

--[[**
	This is called whever the current damage of the disaster changes.
	This is done here and not in the Disaster module becuase different disasters have
	different ways of accomplishing a resize.
**--]]

function TropicalStorm:positionModel(modelToPlace)
	local randomAngle = CFrame.Angles(0, 0, math.random(-360, 360))
	local rotation = CFrame.Angles(math.rad(90), 0, 0)
	local X = self['PositionInWorld']['X']
	local Z = self['PositionInWorld']['Z']
	modelToPlace:PivotTo(CFrame.new(X, GridSpecs.Y_MAP_LEVEL, Z) * rotation)
	--modelToPlace:SetPrimaryPartCFrame(CFrame.new(0,0,0))--(CFrame.new(X, GridSpecs.Y_MAP_LEVEL, Z)) --* randomAngle)
end

--function soundHandler()
--end

function TropicalStorm:removeModel()
	self['Model']:Destroy()
end

function TropicalStorm:animate()

	local TweenService = game:GetService("TweenService")
	local spininfo = TweenInfo.new(15,Enum.EasingStyle.Linear)
	local model = self.Model
	
	local function turnPart(part : BasePart)
		local Spin1 = TweenService:Create(part,spininfo,{CFrame = part.CFrame * CFrame.Angles(0,0,math.rad(-120))})
		local Spin2 = TweenService:Create(part,spininfo,{CFrame = part.CFrame * CFrame.Angles(0,0,math.rad(-240))})
		local Spin3 = TweenService:Create(part,spininfo,{CFrame = part.CFrame * CFrame.Angles(0,0,math.rad(-360))})
		
		Spin1:Play()
		print("playing")
		Spin1.Completed:Connect(
			function()
				Spin2:Play() 
			end
		)
		Spin2.Completed:Connect(
			function()
				Spin3:Play()
			end
		)
		Spin3.Completed:Connect(
			function()
				Spin1:Play() 
			end
		)
	end

	coroutine.wrap(function() turnPart(model.MainPart) end)()
	for _,part in pairs(model.MainPart:GetChildren()) do
		if part:IsA("BasePart") then
			coroutine.wrap(function() turnPart(part) end)()
		end
	end

end

--Other fire-specific functions using coroutines and such

function TropicalStorm:run(playerStamina)
	local newFootprint
	coroutine.wrap(function() self:tollStamina(playerStamina, self['CurrentDisasterSpecsLocation']) end)()
	self:setCurrentDamageBasedOnMultiplier()
	self:setCurrentDamagePerPass()
	self['Model'] = self:getModel()
	self:positionModel(self['Model'])
	self:placeModel()
	coroutine.wrap(function() self:animate() end)()
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

return TropicalStorm