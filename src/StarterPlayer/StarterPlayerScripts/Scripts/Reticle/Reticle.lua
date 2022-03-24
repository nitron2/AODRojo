local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReticleStatus = script.Parent.Parent.Parent.ReticleStatus
local IsInsideActivatedFootprint = ReticleStatus.IsInsideActivatedFootprint
local IsStaminaFull = ReticleStatus.IsStaminaFull
local IsCoast = ReticleStatus.IsCoast
local IsCountry  = ReticleStatus.IsCountry
local ReticleModel = ReplicatedStorage.Systems.Reticle.ReticleModel

local CurrentDisaster = ReticleStatus.CurrentDisaster

local newReticleModel

local Reticle = {} 
Reticle.__index = Reticle


local COLOR_ENABLED = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 0))
})
	
local COLOR_DISABLED = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
})

local BRICK_COLOR_ENABLED = BrickColor.new("Lime green")
local BRICK_COLOR_DISABLED = BrickColor.new("Really red")

local INNER_DATA = {
	PART_NAME = "Inner",
	TURN_SPEED = 6,
	TURN_DIRECTION = -1
}

local OUTER_DATA = {
	PART_NAME = "Outer",
	TURN_SPEED = 6,
	TURN_DIRECTION = 1
}

function Reticle:updatePosition(mouse)
	local newPosition = CFrame.new(mouse.hit.X, self.BestZPos, mouse.hit.Z) * CFrame.Angles(0, 0, math.rad(90))
	self['Model']:SetPrimaryPartCFrame(newPosition)
end

function Reticle:changeColorToEnbled()
	self['Model'].Center.BrickColor = BRICK_COLOR_ENABLED
	self['Model'].Inner.BrickColor = BRICK_COLOR_ENABLED
	self['Model'].Outer.BrickColor = BRICK_COLOR_ENABLED
	self['Model'].Beam.Color = COLOR_ENABLED
end

function Reticle:changeColorToDisabled()
	self['Model'].Center.BrickColor = BRICK_COLOR_DISABLED
	self['Model'].Inner.BrickColor = BRICK_COLOR_DISABLED
	self['Model'].Outer.BrickColor = BRICK_COLOR_DISABLED
	self['Model'].Beam.Color = COLOR_DISABLED
end

function Reticle:updateColor()
	if (IsStaminaFull.Value == false and IsInsideActivatedFootprint.Value == false and IsCountry.Value == true)
		and not 
		(CurrentDisaster.Value == "Tsunami" and IsCoast.Value == false)
	then
		if newReticleModel.Center.BrickColor ~= BRICK_COLOR_ENABLED then
			self:changeColorToEnbled()
		end
	else
		if newReticleModel.Center.BrickColor ~= BRICK_COLOR_DISABLED then
			self:changeColorToDisabled()
		end
	end
end

function Reticle:rotatePart(DATA)
	local part = self['Model']:FindFirstChild(DATA.PART_NAME)
	local yChange = part.Orientation.y + (DATA.TURN_SPEED * DATA.TURN_DIRECTION)
	part.Orientation = Vector3.new(0, yChange, 90)
end

function Reticle:rotate()
	while true do
		coroutine.wrap(function() self:rotatePart(INNER_DATA) end)()
		coroutine.wrap(function() self:rotatePart(OUTER_DATA) end)()
		wait()
	end
end

function Reticle.new(mouse)
	local newReticle
	local initialPosition = CFrame.new(mouse.hit.X, 16.905, mouse.hit.Z) 
		* CFrame.Angles(0, 0, math.rad(90))
	newReticle = {
		['Model'] = nil,
		['BestZPos'] = 16.905
	}
	newReticleModel = ReticleModel:Clone()
	newReticleModel:SetPrimaryPartCFrame(initialPosition)
	newReticleModel.Parent = workspace
	newReticle['Model'] = newReticleModel
	_G.currentReticle = newReticle
	setmetatable(newReticle, Reticle)
	return newReticle
end

return Reticle
