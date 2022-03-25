local ServerStorage = game:GetService('ServerStorage')
local RepliactedStorage = game:GetService('ReplicatedStorage')
local Remotes = RepliactedStorage.Remotes
local PointsFolder = workspace.Points
local PlayerStats = ServerStorage.PlayerData

local checkIfPrime = require(ServerStorage.Scripts.Libraries.CheckIfPrime)

local GridSpecs = require(ServerStorage.Scripts.Specs.GridSpecs.GridSpecs)
local DisasterSpecs = require(ServerStorage.Scripts.Specs.DisasterSpecs.DisasterSpecs)
local DamageScalar = ServerStorage.DamageScalar

local POINTS_AWARD_PER_DAMAGE_AMOUNT = 10
local BASE_FADEOUT_TIME = 5

--// The ratio of points to damage is based on the value of Fire disaster. There is 

local Point = {List = {}} --// A way to hold all the points so they can actually be indexed 
Point.__index = Point

function Point.new(pointValue, args, newPointClusterContainer)
	local newPoint = {
		['ID'] = #Point['List'] + 1,
		['Player'] = args['player'],
		['Color'] = args['color'],
		['Points'] = pointValue,
		['Clickable'] = true,
		['AssociatedPart'] = nil
	}
	
	local metaTable = setmetatable(newPoint, Point)
	Point.List[newPoint['ID']] = newPoint
	
	local base = Instance.new("Part")
	base.Name = newPoint['ID']
	base.Size = Vector3.new(0.05, 0.05, 0.05)
	base.Transparency = 1
	base.CanCollide = false
	base.Anchored = true
	base.CFrame = CFrame.new(args['x'], args['y'], args['z'])
	base.Parent = PointsFolder
	
	--// You may have to use remote something to get it over the server client boundary
	
	local newBillboardGui = Instance.new("BillboardGui")
	newBillboardGui.Name = "Point"
	newBillboardGui.MaxDistance = 300
	newBillboardGui.AlwaysOnTop = true
	newBillboardGui.Enabled = false
	newBillboardGui.Active = true
	newBillboardGui.Size = UDim2.new(0, 100,0, 100)
	newBillboardGui.StudsOffset = Vector3.new(0,3,0)
	newBillboardGui.ZIndexBehavior = "Global"	
	
	local newImageButton = Instance.new("ImageButton")
	newImageButton.AnchorPoint = Vector2.new(0.5, 0.5)
	newImageButton.Position = UDim2.new(0.5,0,0.75,0)
	newImageButton.Name = "Image"
	newImageButton.ImageColor3 = args['color']
	newImageButton.Selectable = true
	newImageButton.BackgroundTransparency = 1
	newImageButton.Size = UDim2.new(0,50,0,50)
	newImageButton.Image = "rbxassetid://1651687069"
	newImageButton.Parent = newBillboardGui
	
	local newTextLabel = Instance.new("TextLabel")
	newTextLabel.Size = UDim2.new(1,0,1,0)
	newTextLabel.BackgroundTransparency = 1
	newTextLabel.Font = "SourceSansBold"
	newTextLabel.TextColor3 = Color3.new(255, 255, 255)
	newTextLabel.TextStrokeColor3 = Color3.new(0,0,0)
	newTextLabel.TextStrokeTransparency = 0.8
	newTextLabel.TextSize = 32
	newTextLabel.TextXAlignment = "Center"
	newTextLabel.TextYAlignment = "Center"
	newTextLabel.Text = pointValue
	newTextLabel.Visible = true
	newTextLabel.Parent = newImageButton

	local newTextButton = Instance.new("TextButton")
	newTextButton.Size = UDim2.new(1,0,1,0)
	newTextButton.Transparency = 1
	newTextButton.Text = ""
	newTextButton.ZIndex = 10
	newTextButton.Visible = true
	newTextButton.Name = "Button"
	newTextButton.Parent = newImageButton
	
	local newIntValue = Instance.new("IntValue")
	newIntValue.Name = "ID"
	newIntValue.Value = newPoint['ID']
	
	newIntValue.Parent = newBillboardGui
	newBillboardGui.Adornee = base
	newBillboardGui.Enabled = true
	newBillboardGui.Parent = newPointClusterContainer
	
	newPoint:startCountingDown()
	
	return newPoint 
end

function Point:startCountingDown()
	coroutine.wrap(function()
		wait(BASE_FADEOUT_TIME)
		self['Clickable'] = false
		print("Poop")
		Remotes['PointFadedOutToClient']:FireAllClients(self['ID'])

		--// Send remote to all clients, which in there will find the associated point and end it.
		--// Might be possible to pass the associated billboard as arguement
	end)()
end

function Point.calculatePointsValue(totalDamageDealt)
	--// Pivot based off of fire damage to be the base
	local damageRatioValue = DisasterSpecs['Fire']['BaseDamage'] * DamageScalar.Value 
	local unitRateOfDamagePerPoint = damageRatioValue / POINTS_AWARD_PER_DAMAGE_AMOUNT
	local finalPointAward = totalDamageDealt / unitRateOfDamagePerPoint
	return ((finalPointAward + 0.5) - (finalPointAward + 0.5) % 1) --// Round final award up to nearest integer
end

function Point.divvyUpPoints(player, pointAward, posX, posZ, color)
	local argsCreateNewPoint = {
		player = player, 
		color = color,
		pointAward = pointAward, 
		x = posX, 
		y = GridSpecs['Y_MAP_LEVEL'], 
		z = posZ
	}
	
	local playersChildren = game.Players:GetChildren()
	for _, plr in pairs(playersChildren) do
		print(plr.Name)
		local clientPointsFolder = player.PlayerGui:FindFirstChild("Points")
		if clientPointsFolder then
			
			local newPointClusterContainer = Instance.new("Folder")
			newPointClusterContainer.Name = plr.Name
			
			if checkIfPrime(pointAward) == true then
				Point.new(pointAward, argsCreateNewPoint, newPointClusterContainer)
				newPointClusterContainer.Parent = clientPointsFolder
			elseif checkIfPrime(pointAward) == false then
				if 2 % pointAward == 0 
					or 2 % pointAward == 2 
				then -- Divide the point award in two
					for _ = 1,2 do
						Point.new(pointAward / 2, argsCreateNewPoint, newPointClusterContainer)
					end
					newPointClusterContainer.Parent = clientPointsFolder
				end
			end
		end
	end
end

function Point.validateClick(player, pointID)
	for i, point in pairs(Point.List) do
		if point['Clickable'] == true 
			and point['ID'] == pointID
			and point['Player'] == player 
		then
			local playerStats = PlayerStats:findFirstChild(player.Name)
			point['Clickable'] = false
			if playerStats then
				playerStats.Stats.Points.Value = playerStats.Stats.Points.Value + point['Points']
				--print("Awarded: " .. point['Points'])
			end
			Remotes['PointFadedOutToClient']:FireAllClients(point['ID'])
			break
		end
	end
	--// make sure animate has time to go, then Remove the point part. make clickable false, send message to all clients that makes the one fade out
end

return Point