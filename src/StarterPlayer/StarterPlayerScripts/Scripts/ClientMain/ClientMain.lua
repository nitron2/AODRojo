local ClientMain = {}

--!strict

--[[**
	This local script is where the methods for checking in mouse is in areas and footprints is called, and for running
	the tabstats display
	The visualization to the user 

 	@usage While the game is in progress. Uses AreasTable module, footprintsTable module (non-OOP)
	@returns nil
**--]]--Description
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedFirst = game:GetService('ReplicatedFirst')
repeat 
	wait() 
until ReplicatedFirst.AssetLoading.Ready.Value == true

local Remotes = ReplicatedStorage.Remotes
local players = game:GetService('Players')
local player = players.LocalPlayer
local mouse = player:GetMouse()

local mouseHitPrevious
local mouseHitCurrent

local footprintsTable = require(ReplicatedStorage.Scripts.FootprintCheck.FootprintsTable)
local AreasTable = require(ReplicatedStorage.Scripts.AreasTable.AreasTable)
local newAreasTable = AreasTable.new()

local Validations = require(ReplicatedStorage.Scripts.Validations.Validations)

local Status_IsInsideActivatedFootprint = script.Parent.Parent.Parent.ReticleStatus.IsInsideActivatedFootprint
local Status_IsCoast = script.Parent.Parent.Parent.ReticleStatus.IsCoast
local Status_IsCountry = script.Parent.Parent.Parent.ReticleStatus.IsCountry

local frame = 0
local FREQUENCY_OF_CHECKS = 2 -- Run program every __ frames

--[[**
	Process:
		-First the player's target tile is found
		
		-Passing the tile to the relevant methods, we obtain both a list of areas
		 and footprints that are touching 
		 the user's target tile 
		 (newAreasTable:getAreasToSearchForFromTargetTile(targetTile)) or 
		 (footprintsTable:getFootprintsToSearchForFromTargetTile(targetTile). 
		 That info is store in Areas folder or Footprints
		 folder inside the grid parts themselves, and there are server-sided 
		 methods to get these set up when they are needed.
		 
		-Using that search query, pass the qeury to both the :checkAreaQuery() 
		 or :checkFootprintsQuery() methods.  Note that
	   since footprints table is managed by the server, in order to access the
		 :checkFootprintsQuery() method and get a return to
		 the client, we need to utilize a RemoteEvent. It's listener is 
		 found in remote handler.
		 
		-Now for both areas and footprints we can display relevant info to 
		 the user in real time
		 
		-Footprints: only display to user as invalid if the footprint is activated.

	Frequency and performance:
		-You can choose the frequency of the script utilized by RunService
		
		-Becuase a RemoteFunction is used to get the activated footprints, 
		 the result could be slow 
		 and adversly affect area check. This is why I separted the main 
		 function into two coroutines.

	Areas
		-_G is used to house ActivatedAreas, becuase ActivatedAreas needs to be 
		 sent to and used by ValidateDisaster by means of 
		 the Hotbar local script, which is here in the same folder as this 
		 LocalScript. That's probably the easiest way to 
		 share tables between LocalScripts. (_G is the global module, used 
		 for storing LUA items across scripts.

	@returns: nil

**--]]

local function setClientG_ActivatedAreas(targetTile)
	local areasToSearchFor = newAreasTable:getAreasToSearchForFromTargetTile(targetTile)
	if areasToSearchFor and #areasToSearchFor > 0 then
		local ActivatedAreas = newAreasTable:checkAreaQuery(mouse.hit.X, math.abs(mouse.hit.Z), areasToSearchFor)
		_G.ActivatedAreas = ActivatedAreas
		--// Purely Visual
		--for i,areaInstance in pairs(ActivatedAreas) do
		--	print(areaInstance)
		--	if areaInstance.Parent.Parent.Name == "Country" then
		--		local segments = areaInstance.Segments:GetChildren()
		--		for i, segment in pairs(segments) do
		--			segment.Enabled = true
		--		end
		--	end
		--end
		--// 
	end
end

local function getActivatedFootprints(targetTile)
	if footprintsTable then
		local footprintsToSearchFor = footprintsTable:getFootprintsToSearchForFromTargetTile(targetTile)
		if footprintsToSearchFor and #footprintsToSearchFor > 0 then
			return Remotes["CheckFootprintQuery"]:InvokeServer(mouse.hit.X, mouse.hit.Z, footprintsToSearchFor)
		end
	end
end

local function updateStatus_IsInsideActivatedFootprint(activatedFootprints)
	if Validations.isMouseInActivatedFootprint(activatedFootprints) then
		if Status_IsInsideActivatedFootprint.Value ~= true then
			Status_IsInsideActivatedFootprint.Value = true
		end
	else
		if Status_IsInsideActivatedFootprint.Value ~= false then
			Status_IsInsideActivatedFootprint.Value = false
		end
	end
end

local function updateStatus_IsCoast()
	if Validations.isCoast(_G.ActivatedAreas) then
		if Status_IsCoast.Value ~= true then
			Status_IsCoast.Value = true
		end
	else
		if Status_IsCoast.Value ~= false then
			Status_IsCoast.Value = false
		end
	end
end

local function updateStatus_IsCountry()
	if Validations.isCountry(_G.ActivatedAreas) then
		if Status_IsCountry.Value ~= true then
			Status_IsCountry.Value = true
		end
	else
		if Status_IsCountry.Value ~= false then
			Status_IsCountry.Value = false
		end
	end
end

function ClientMain.run()
	--print("ran main")
	mouseHitCurrent = mouse.hit
	if mouseHitCurrent ~= mouseHitPrevious or not mouseHitPrevious then
		local targetTile = newAreasTable:getTargetTile(mouse.hit.X, mouse.hit.Z)
		if targetTile then
			local activatedFootprints
			_G.currentReticle:updateColor()
			setClientG_ActivatedAreas(targetTile)
			activatedFootprints = getActivatedFootprints(targetTile) 
			if activatedFootprints then
				updateStatus_IsInsideActivatedFootprint(activatedFootprints)
			end
			if Validations.isAreas(_G.ActivatedAreas) then
				updateStatus_IsCoast()
				updateStatus_IsCountry()
			end
			mouseHitPrevious = mouseHitCurrent
		end
	end
end

return ClientMain
