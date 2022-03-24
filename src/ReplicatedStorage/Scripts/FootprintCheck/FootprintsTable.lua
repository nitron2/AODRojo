--[[**
	This module houses the methods necessary to add a footprint to the activated
	footprints table and to check if mouse is in range of any of the activated 
	footprint nodes. 

	@usage: ValidateDisaster, AreaCheck
**--]]--Description

local WorldModel = workspace.WorldModel
local Areas = WorldModel.Areas
local Grid = WorldModel.Grid
local FootprintsTable = {}
local footprintsContainer = {}

--[[**
	This function is called from Footprint within Footprint.new() once the data
	is set for the newly created footprint, it is insterted into the main server
	footprints table. Then, in order to set up for mouse checking if in range of a 
	footprint, we need to check which tile parts are touching any part of each footprint.
	To accomplish this, every grid has its own folder for its extents and every footprint
	has self-data defining the extents. Set this int value in the tile part to the ID, 
	or index of the footprint/order in the table.
 
	@param [t:table] newFootprint Table representing a footprint
	@usage Footprint
**--]]

function FootprintsTable:addNewFootprint(newFootprint)
	table.insert(footprintsContainer, newFootprint)	
		
	local gridParts = Grid:GetChildren()
	if gridParts then
		for i, tilePart in pairs(gridParts) do
			if tilePart.Extents and tilePart.Footprints then
				local tilePartExtents = tilePart.Extents
				if tilePartExtents.XEnd 
					and tilePartExtents.XStart 
					and tilePartExtents.ZEnd 
					and tilePartExtents.ZStart 
				then					
					if (tilePartExtents.XStart.Value < newFootprint['Extents']['XStart']
						and newFootprint['Extents']['XStart'] < tilePartExtents.XEnd.Value
						and tilePartExtents.ZStart.Value > newFootprint['Extents']['ZStart']
						and newFootprint['Extents']['ZStart'] > tilePartExtents.ZEnd.Value)
						or
						(tilePartExtents.XStart.Value < newFootprint['Extents']['XEnd']
						and newFootprint['Extents']['XEnd'] < tilePartExtents.XEnd.Value
						and tilePartExtents.ZStart.Value > newFootprint['Extents']['ZStart']
						and newFootprint['Extents']['ZStart'] > tilePartExtents.ZEnd.Value)
						or
						(tilePartExtents.XStart.Value < newFootprint['Extents']['XStart']
						and newFootprint['Extents']['XStart'] < tilePartExtents.XEnd.Value
						and tilePartExtents.ZStart.Value > newFootprint['Extents']['ZEnd']
						and newFootprint['Extents']['ZEnd'] > tilePartExtents.ZEnd.Value)
						or
						(tilePartExtents.XStart.Value < newFootprint['Extents']['XEnd']
						and newFootprint['Extents']['XEnd'] < tilePartExtents.XEnd.Value
						and tilePartExtents.ZStart.Value > newFootprint['Extents']['ZEnd']
						and newFootprint['Extents']['ZEnd'] > tilePartExtents.ZEnd.Value)
					then
						newFootprint['ID'] = #footprintsContainer
						if not tilePart.Areas:FindFirstChild(tostring(newFootprint['ID'])) then
							local newFootprintIndexValueTable = Instance.new("IntValue")
							newFootprintIndexValueTable.Name = #footprintsContainer
							newFootprintIndexValueTable.Value = #footprintsContainer
							newFootprintIndexValueTable.Parent = tilePart.Footprints
						end
					end
				end
			end
		end
	end
end

--[[**
	Given targetTile instance, create a list of footprints to search for in the form of indices.
	Look for each footprintIndexValueTable in the tile part, and instert that into the table.

  @param [t:instance] targetTile The tile mouse is hovering over. This is "inherited" from AreasTable module.
	@returns [t:table] footprintsToSearchFor The table which holds the footprints query. Always returns.
**--]]

function FootprintsTable:getFootprintsToSearchForFromTargetTile(targetTile)
	if targetTile then
		local footprintsToSearchFor = {}
		local footprintsInTargetTile = targetTile.Footprints:GetChildren()
		if targetTile.Areas and #footprintsInTargetTile > 0 then
			for i, footprintIndexValueTable in pairs(footprintsInTargetTile) do
				table.insert(footprintsToSearchFor, footprintIndexValueTable.Value)
			end
		end
		return footprintsToSearchFor
	end
	return nil
end

--[[**
	This function, when it gets the footprints to search for from the previous function,
	will iterate though the query and decide if the mouse is within the radius of the
	footprint. If so, it adds it to a new table which houses activatedFootprints. 
	Radius of footprint is stored within the footprints of footprintsToSearchFor. 
	
	@param [t:number] mouseX Mouse X position in world
	@param [t:number] mouseZ Mouse Z position in world
	@param [t:table] footprintsToSearchFor Obtained from return of :getFootprintsToSearchForFromTargetTile()
 
	@returns [t:table] activatedFootprints To be sent back to the client or server script that is
	originally calling all of these methods. 
**--]]

function FootprintsTable:checkFootprintQuery(mouseX, mouseZ, footprintsToSearchFor)
	if footprintsToSearchFor then
		local activatedFootprints = {}
		for i, footprintQueryIndex in pairs(footprintsToSearchFor) do		
			local footprintQueryItem = footprintsContainer[footprintQueryIndex]
			local radius = footprintQueryItem['Radius']
			local distanceBetweenConterOfFootprintAndMouse = math.sqrt(math.pow((mouseX - footprintQueryItem['PositionInWorld']['X']), 2) + math.pow((mouseZ-footprintQueryItem['PositionInWorld']['Z']),2))
			if distanceBetweenConterOfFootprintAndMouse <= radius then
				table.insert(activatedFootprints, footprintQueryItem)
			end
		end
		return activatedFootprints
	end
	return nil
end
	
return FootprintsTable