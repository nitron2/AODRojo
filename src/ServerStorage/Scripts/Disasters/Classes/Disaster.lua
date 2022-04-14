--[[
ModuleScript Disaster 

This module script contains methods that all disasters have in common and will
be used as a library for the disasters. 

When the Disaster remote in replicated 
storage is called by the client, code on the remote handler will trigger the defualt
executioner used for 90% of the disasters.
]]--

local ServerStorage = game:GetService('ServerStorage')
local Stamina = require(ServerStorage.Scripts.Stamina.Classes.Stamina)
local DisasterSpecs = require(ServerStorage.Scripts.Specs.DisasterSpecs.DisasterSpecs)

local DamageScalar = ServerStorage.DamageScalar
local WorldStats = ServerStorage.WorldStats

local Disaster = {}
Disaster.__index = Disaster

function Disaster.new(player, playerData, currentDisasterSpecs, activatedAreas, mouseHit)
	local newDisaster = {
		['Player'] = player,
		['PlayerData'] = playerData,
		
		['Model'] = nil,
		['PositionInWorld'] = {
			['X'] = mouseHit.X,
			['Y'] = mouseHit.Y,
			['Z'] = mouseHit.Z,
		},
		
		['Color'] = playerData.Color.Value,
			
		['AreasPresent'] = activatedAreas, --// table of obj values pointing to folders in workspace.
		
		['CurrentDisasterSpecsLocation'] = currentDisasterSpecs,
		
		['CurrentDamage'] = nil,
		['CurrentDamagePerPass'] = nil,
		['CurrentDamageMultiplier'] = nil,
		['TotalDamageDealt'] = 0, 

		['Type'] = currentDisasterSpecs['Type'], --// string
		['BaseDamage'] = currentDisasterSpecs['BaseDamage'] * DamageScalar.Value, --// number
		['NumberOfPasses'] = currentDisasterSpecs['NumberOfPasses'], --// int
		['TimeBetweenPasses'] = currentDisasterSpecs['TimeBetweenPasses'], --// number
		['BaseDuration'] = currentDisasterSpecs['BaseDuraction'], --// number
		['TimeToStartRegening'] = currentDisasterSpecs['TimeToStartRegening'], --// number
		['ResetRate'] = currentDisasterSpecs['ResetRate'], --// number
		['PercentTollOnStamina'] = currentDisasterSpecs['PercentTollOnStamina'], --// number
		--['MultiDisasteRPenaltyMultiplier'] = currentDisasterSpecs['MultiDisasteRPenaltyMultiplier'], --// number		
		--['Combos'] = currentDisasterSpecs['Combos'] --// table
	}	
	--print(tostring(newDisaster['AreasPresent']))
	setmetatable(newDisaster, Disaster)
	return newDisaster
end

function Disaster:getPlayerColor()
	return self['PlayerData'].Color.Value
end

function Disaster:tollStamina(playerStamina,currentDisasterSpecs)
	Stamina.onDisasterInitialized(playerStamina, currentDisasterSpecs)
end

function Disaster:setCurrentDamageBasedOnMultiplier()
end

function Disaster:getModel()
end

function Disaster:resizeModel()
end

function Disaster:placeModel()
	self['Model'].Parent = workspace
end

function Disaster:setCurrentDamagePerPass()
	self['CurrentDamagePerPass'] = self['CurrentDamage'] / self['NumberOfPasses']
end

function Disaster:dealDamage()
	local damage = self['CurrentDamagePerPass']
	WorldStats.Health.Value = WorldStats.Health.Value - damage
	WorldStats.Defecit.Value = WorldStats.Defecit.Value + damage
	self['PlayerData'].Damage.Value += damage
	self['TotalDamageDealt'] = self['TotalDamageDealt'] + damage
	return damage
end

function Disaster:displayDamage(damageDealt)	
	local newBillboardGui = Instance.new("BillboardGui", self['Model'].MainPart)
	newBillboardGui.Name = "NewBill"
	newBillboardGui.Adornee = self['Model'].MainPart
	newBillboardGui.Size = UDim2.new(0, 200,0, 50)
	newBillboardGui.MaxDistance = 150
	newBillboardGui.AlwaysOnTop = true
	newBillboardGui.StudsOffset = Vector3.new(0, 3, 0)
	
	local newFrame = Instance.new("Frame", newBillboardGui)
	newFrame.Size = UDim2.new(1, 0, 1, 0)
	newFrame.Transparency = 1
	newFrame.Position = UDim2.new(0, 0, 0, 0)	
	
	local Triangle = Instance.new("ImageLabel", newFrame)
	Triangle.Name = "PlrColor"
	Triangle.Size = UDim2.new(0,20,0,20)
	Triangle.Position = UDim2.new(0.5, -10, 0, 30)
	Triangle.BackgroundTransparency = 1
	Triangle.ImageTransparency = 0
	Triangle.Image = "rbxassetid://252644715"
	Triangle.ImageColor3 = self:getPlayerColor()
	
	local newDamageText = Instance.new("TextLabel", newFrame)	
	newDamageText.BackgroundTransparency = 1
	newDamageText.Text = "-" .. damageDealt
	
	newDamageText.Font = "Highway"
	newDamageText.Size = UDim2.new(1, 0, 1, 0)
	newDamageText.TextSize = 19
	newDamageText.TextColor3 = DisasterSpecs.DamagePercColors.DAMAGE_PERC_WHITE
	newDamageText.Name = "Damage"				
	newDamageText.TextStrokeColor3 = DisasterSpecs.DamagePercColors.DAMAGE_PERC_GREY
	newDamageText.TextStrokeTransparency = 0
	newDamageText.TextTransparency = 0
	
	local newDamagePercText = Instance.new("TextLabel", newFrame)	
	newDamagePercText.Name = "Multiplier"
	newDamagePercText.BackgroundTransparency = 1
	newDamagePercText.TextStrokeTransparency = 0
	newDamagePercText.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	newDamagePercText.Font = "Highway"
	newDamagePercText.Size = UDim2.new(1, 0, .5, 0)
	newDamagePercText.TextSize = 12
	newDamagePercText.TextStrokeColor3 = DisasterSpecs.DamagePercColors.DAMAGE_PERC_GREY
	newDamagePercText.TextStrokeTransparency = 0.5
	newDamagePercText.TextTransparency = 0
	
	if self['CurrentDamageMultiplier'] > 1 then
		newDamagePercText.TextColor3 = DisasterSpecs.DamagePercColors.DAMAGE_PERC_RED
	elseif (self['CurrentDamageMultiplier'] <= 1 
		and self['CurrentDamageMultiplier'] >= 0.75)
		or self['CurrentDamageMultiplier'] == nil 
	then
		newDamagePercText.TextColor3 = DisasterSpecs.DamagePercColors.DAMAGE_PERC_ORANGE
	elseif self['CurrentDamageMultiplier'] < 0.75 then
		newDamagePercText.TextColor3 = DisasterSpecs.DamagePercColors.DAMAGE_PERC_YELLOW
	end
	
	newDamagePercText.Text = self['CurrentDamageMultiplier'] .. "%"
	newFrame:TweenPosition(UDim2.new(0, 0 ,-0.6 ,0))
	wait(0.75)
	newFrame.Visible = false
	newBillboardGui:Destroy()
end

function Disaster:performPasses()
	for i = 1, self['NumberOfPasses'] do
		local damageDealt = self:dealDamage()
		coroutine.wrap(function() self:displayDamage(damageDealt) end)()
		wait(self['TimeBetweenPasses'])
	end
end

return Disaster
