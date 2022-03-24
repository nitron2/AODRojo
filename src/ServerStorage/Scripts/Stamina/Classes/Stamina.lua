--[[**
	This mouse houses all Server-level Stamina methods, as well as 
	Stamina.List, which is an easy container for all player stamina.
**--]]
local RepliactedStorage = game:GetService('ReplicatedStorage')
local Remotes = RepliactedStorage.Remotes

local Stamina = {List = {}} --// A way to hold all the player's staminas in an array with each aray
Stamina.__index = Stamina

local USING_TIME_INTERVAL = 0.15

--[[**
	Create new table to represent a player's Stamina for disasters.
	Inster it into Stamina.List for easier access.

	@param [t:instance] player
	@returns [t:table] newStamina
**--]]

function Stamina.new(player)
	local newStamina = {
		['Player'] = player,
		['Fatigue'] = 0,
		['Time'] = 0,
		['Countdown'] = 0,
		['FatigueResetRate'] = 0,
		
		['Using'] = false,
		
		['StateCountingDown'] = false,
		['StateReducing'] = false
	}
	local metaTable = setmetatable(newStamina, Stamina)
	Stamina.List[player] = newStamina
	return newStamina 
end

--[[**
	Just to save syntax space

	@param [t:instance] player
	@returns Stamina.List[player] The stamina of a certain player. Located in Stamina.List
**--]]

function Stamina.getPlayerStamina(player)
	return Stamina.List[player]
end

--[[**
	Exists because fatigue needs to be sent to releveant client every time there is a change.
	
	@param [t:instance] player
	@param [t:instance] playerStamina
**--]]

function Stamina.sendFatigueToClient(player, playerStamina)
	Remotes["SendFatigueToClient"]:FireClient(player, playerStamina['Fatigue'])
	--print("Fatigue: " .. playerStamina['Fatigue'])
end
 
--[[**
	@param [t:table] playerStamina
	@param [t:table] currentDisasterSpecs
**--]]

function Stamina.onDisasterInitialized(playerStamina, currentDisasterSpecs)
	playerStamina:update("Fatigue", currentDisasterSpecs['FatiguePercentToll'])
	playerStamina:update("Time", currentDisasterSpecs['FatigueTimeToReset'])
	playerStamina:update("FatigueResetRate", currentDisasterSpecs['FatigueResetRate'])
	playerStamina:update("StateReducing", false)
	playerStamina:update("StateCountingDown", true)
	playerStamina:update("Using", true)
	--Here, also send information returned from here every time, showing the current stamina level (To the client)
	--use remote event
--PROBLEM IS THAT WHEN REDUCTION OCCURS WE NEED TO SHOW STAMINA TO USER AS WELL
end

--[[**
	Honestly don't even want to explain all this.
**--]]

function Stamina:update(key, value)
	local function countdown()
		repeat
			--print("Counting down")
			--print("Time:" .. self.Time)
			wait(0.05)
			self['Time'] = self['Time'] - 0.05
		until self['Time'] <= 0
		
		self:update("StateCountingDown", false)
		self['Time'] = 0
		self:update("StateReducing", true)
	end
	
	local function reduce()
		repeat 
			wait() 
			self['Fatigue'] = self['Fatigue'] - self['FatigueResetRate']
			Stamina.sendFatigueToClient(self['Player'], self)
		until self['Fatigue'] <= 0 or self['StateReducing'] == false
		self:update("StateReducing", false)
		self['Fatigue'] = 0
	end
	
	--// Do we need something to be asycnronous?
	if type(key) == 'string' 
		and (type(value) == 'boolean' 
		or type(value) == 'number') 
	then
		--// Only change theaw values if they are not already what they 
		--// are inteneded to be changed to
		if self[key] ~= value then
			if key == "StateCountingDown" then
				self['StateCountingDown'] = value
				if self['StateCountingDown'] == true 
					and self['Time'] ~= 0 
				then
					countdown()
				end
			elseif key == "StateReducing" then
				--print("Did")
				self['StateReducing'] = value
				if self['StateReducing'] == true
					and self['Fatigue'] ~= 0 
				then
					reduce()
		 		end
			elseif key == "FatigueResetRate" then
				self['FatigueResetRate'] = value
			elseif key == "Using" then
				wait(USING_TIME_INTERVAL)
				self['Using'] = false
			end		
		end
		--// Always update these values when promted
		if key == "Time" then
			self['Time'] = self['Time'] + value
			--print("Time:" .. self['Time'])
		elseif key == "Fatigue" and self['Fatigue'] < 100 then
			self['Fatigue'] = self['Fatigue'] + value
			Stamina.sendFatigueToClient(self['Player'], self)
			--print("Fatigue: " .. self['Fatigue'])
		end
	end
end

return Stamina