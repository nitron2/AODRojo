--!strict

--[[**
	This local script displays the stamina information to the user. Before any functions,
	we need to declare a table that holds all the tickValues, that is based on the already made 
 	image labels which are arranged in a circle. This table is sorted from least to greatest.
	They are in multiples of five for easy visibility.
 
 	@usage:	While the game is in progress. Relies only on the SendFatigueToClient remote to trigger, and also mouse movement.
	@returns: nil
**--]]--Description

repeat wait() until script.Parent.Parent.Parent.ClientMainLoaded.Value == true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes

local ReticleFolder = script.Parent.Parent.Parent.ReticleStatus
local IsStaminaFull  = ReticleFolder.IsStaminaFull
local ReticleModel = workspace:WaitForChild("ReticleModel", 30) 

local ticksValues = {}

--[[**
	This function uses the fatigue amount from the server in order to decide what bars to
	hide and show in the Gui. Declare a variable called targetTickNumber that will be a the 
	highest tick number to show. First, it is worth checking if the fatigue happens to lie on
	a multiple of 5. If so, set the target tick integer right there. Otherwise we need to
	decide what the next lowest tick is, and target that one. We do this by starting at tick
	0, and iterating through the ticks table intil the previous index is less than the actual 
	fatigue amount. The final step is to remove all bars above the current one, then add all
	bars below the current bar and add the current bar

	@param [t:number] fatigueAmount gotten originally from server, the fatigue amount stored 
	within the Fatigue server module for the current player
**--]]

local function updateIsStaminaFullBoolValue(fatigueAmount)
	if fatigueAmount == 100 then
		if IsStaminaFull.Value ~= true then
			IsStaminaFull.Value = true
		end
	else
		if IsStaminaFull.Value ~= false then
			IsStaminaFull.Value = false
		end
	end
end

local function isNumberMultipleOf5(n: number)
	if n % 5 == 0 then
		return true
	end
	return false
end

local function isFatigueLineUpWithTick(fatigueAmount: number)
	if (isNumberMultipleOf5(fatigueAmount)) and 
		(fatigueAmount > 0 and fatigueAmount <= 100) 
	then
		return true
	end
	return false
end

local function getClosestTickNumber(fatigueAmount) 
	local target
	local lastTick = 0
	for i, thisTick in pairs(ticksValues) do
		if lastTick < fatigueAmount and 
			fatigueAmount < thisTick 
		then
			return lastTick
		end
		lastTick = thisTick
	end
	return 0
end

local function addOrRemoveTicks(closestTickNumber: number)
	for i, tickValue in pairs(ticksValues) do
		if tickValue > closestTickNumber then 
			ReticleModel.Stamina:FindFirstChild(tostring(tickValue)).Transparency = 1
		elseif tickValue <= closestTickNumber then
			ReticleModel.Stamina:FindFirstChild(tostring(tickValue)).Transparency = 0
		end
	end
end

local function displayBars(fatigueAmount: number)
	local closestTickNumber
	if isFatigueLineUpWithTick(fatigueAmount) then
		closestTickNumber = fatigueAmount
		updateIsStaminaFullBoolValue(fatigueAmount)
	else
		closestTickNumber = getClosestTickNumber(fatigueAmount) 
	end
	if fatigueAmount ~= 0 then
		addOrRemoveTicks(closestTickNumber)
	end
end

--[[**
	This function is called every time user fatigue changes. It called displaybars with parameters.

	@param [t:number] fatigue gotten originally from server, the fatigue amount stored 
	within the Fatigue server module for the current player 
**--]]

local function setUpTicksTable()
	local tickInstances = ReticleModel.Stamina:GetChildren()
	for i, v in pairs(tickInstances) do
		if v:IsA("Part") then
			table.insert(ticksValues, tonumber(v.Name))
		end
	end
	table.sort(ticksValues)
	tickInstances = nil
end

setUpTicksTable()

local function main(fatigue)
	if fatigue <= 0 then
		displayBars(0)
	elseif fatigue > 0 then
		displayBars(fatigue)
	end
end

Remotes["SendFatigueToClient"].OnClientEvent:Connect(main)