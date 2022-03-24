--[[**
This module houses all the methods used to create and 
manipulate footprints. 

@usage: ServerStorage.Systems.Disasters.Classes modules
**--]]--Description

local ServerStorage = game:GetService('ServerStorage')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Remotes = ReplicatedStorage.Remotes
local FootprintsTable = require(ReplicatedStorage.Scripts.FootprintCheck.FootprintsTable)
local GridSpecs = require(ServerStorage.Scripts.Specs.GridSpecs.GridSpecs)

local Footprint = {}
Footprint.__index = Footprint

--[[**
	This function is called locally only, whenever something changes
	within any part of the footprints table.
**--]]

local function triggerSendFootprintsTableToClients()
	Remotes['FootprintsTableToAllClients']:FireAllClients(FootprintsTable)
end

--[[**
	Create new footprint with initial data, then call the method
	to set the size data correctly based on expected damage. 
	(the actual sizing of the physical instance will be done in
	a jiffy). Create an indicator part and visuals for the footprint.
	Set the model data to this part, put it in the workspace after
	calling an in-house method to resize it. Activate the footprint, 
	and call a method to add the footprint to the footprints container
	which is a table. Finally, since a lot had been changed with the
	footprints table, send the server-sided table to all clients to 
	inform them.
	
	Activated
		-We need this boolean to exist, because we cannot really remove items from the table 
		because that would desync index values in the tile parts, etc.
	
	@param [t:table] table representing specific disaster
	@returns [t:table] newFootprint
**--]]

function Footprint.new(disaster)
	local newFootprint = {
		['ID'] = nil,
		['Activated'] = true,
		['ExpectedDamage'] = disaster['CurrentDamage'],
		['Latitude'] = nil,
		['Model'] = nil,
		['Color'] = disaster['Color'],
		['Duration'] = nil, --maybe
		['Radius'] = 0,
		['PositionInWorld'] = {
			['X'] = disaster['PositionInWorld']['X'],
			['Z'] = disaster['PositionInWorld']['Z']
		},
		['Extents'] = { --// Used only for the detection of the footprints
			['XStart'] =  nil,
			['XEnd'] = nil,
			['ZStart'] = nil,
			['ZEnd'] = nil
		},
	}
	setmetatable(newFootprint, Footprint)
	
	newFootprint:setGeometry(newFootprint['ExpectedDamage'], false)

	local newFootprintIndicatorPart = Instance.new("Part")
	newFootprintIndicatorPart.Name = "Footprint"
	newFootprintIndicatorPart.Anchored = true
	newFootprintIndicatorPart.CanCollide = false
	newFootprintIndicatorPart.Transparency = 1
	
	local newFootprintSurfaceGui = Instance.new("SurfaceGui")
	newFootprintSurfaceGui.Face = "Top"
	newFootprintSurfaceGui.Active = true
	newFootprintSurfaceGui.Adornee = newFootprintIndicatorPart
	newFootprintSurfaceGui.ResetOnSpawn = false
	newFootprintSurfaceGui.AlwaysOnTop = false
	newFootprintSurfaceGui.Parent = newFootprintIndicatorPart
	
	local newFootprintGraphic = Instance.new("ImageLabel")
	newFootprintGraphic.Visible = false
	newFootprintGraphic.BackgroundTransparency = 1
	newFootprintGraphic.ImageTransparency = 0.75
	newFootprintGraphic.Position = UDim2.new(0, 0, 0, 0)
	newFootprintGraphic.Size = UDim2.new(1, 0, 1, 0)
	newFootprintGraphic.Image = "http://www.roblox.com/asset/?id=5439186382"
	newFootprintGraphic.ImageColor3 = newFootprint['Color']
	newFootprintGraphic.Parent = newFootprintSurfaceGui
	
	newFootprint['Model'] = newFootprintIndicatorPart
	newFootprint:applyGeometry()
	newFootprint['Model'].Parent = workspace
	
	--newFootprint['Activated'] = true
	
	FootprintsTable:addNewFootprint(newFootprint)
	triggerSendFootprintsTableToClients()
	return newFootprint
end

--[[** 
	This function uses AVG_KM_CUBED_PER_STUDS_CUBED from GridSpecs and a given amount
	of damage to calculate the radius of the footprint's circle. It also calculates
	the physcial extents and sets them to the data. It does this because this is needed
	for effieicent checking if the mouse if near a footprint.
	
	The reason why this function exists on its own is because footprints are
	quite dynamic, as disasters change damage output due to plays people make.
	
	@param [t:string] damageParameter
	@param [t:boolean] doSendFootprintsTableToClients
**--]]

function Footprint:setGeometry(damageParameter, doSendFootprintsTableToClients)	
	local areaInStudsCubed = damageParameter / GridSpecs.AVG_KM_CUBED_PER_STUDS_CUBED
	self['Radius'] = math.sqrt(areaInStudsCubed / math.pi)
	
	self.Extents.XStart = self['PositionInWorld']['X'] - self['Radius'] --// Left
	self['Extents']['XEnd'] = self['PositionInWorld']['X'] + self['Radius'] --// Right
	self['Extents']['ZStart'] = self['PositionInWorld']['Z'] + self['Radius'] --// Lower on map
	self['Extents']['ZEnd'] = self['PositionInWorld']['Z'] - self['Radius'] --// Higher up on map
	if doSendFootprintsTableToClients == true then
		triggerSendFootprintsTableToClients()
	end
end

--[[**
	This function serves to change the physical size based on radius.

	The reason why this function exists on its own is because footprints are
	quite dynamic, as disasters change damage output due to plays people make.
**--]]

function Footprint:applyGeometry()
	self['Model'].Size = Vector3.new(self['Radius'] * 2, 0.05, self['Radius'] * 2)
	self['Model'].Position = Vector3.new(self['PositionInWorld']['X'], 16.50, self['PositionInWorld']['Z'])
end

--[[**
	Physically shows footprint
**--]]

function Footprint:show()
	--// Can have slow fade or some fancy anim
	self['Model'].SurfaceGui.ImageLabel.Visible = true
end

--[[**
	Physically hide footprint
**--]]

function Footprint:hide()
	self['Model'].SurfaceGui.ImageLabel.Visible = false
	--// Can have slow fade or some fancy anim
end

--[[**
	Activate a footprint. Necessary for use outside of this module, as whenever something changes 
	about any footprint, we need to send that info to all clients.
**--]]

function Footprint:activate()
	self['Activated'] = true
	triggerSendFootprintsTableToClients()
end

--[[**
	Deactivate a footprint. Necessary for use outside of this module, as whenever something changes 
	about any footprint, we need to send that info to all clients.
**--]]

function Footprint:deactivate()
	self['Activated'] = false
	triggerSendFootprintsTableToClients()
end


return Footprint
