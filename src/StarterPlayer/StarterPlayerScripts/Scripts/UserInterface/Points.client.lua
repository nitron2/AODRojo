local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local pointsFolderClient = playerGui:WaitForChild("Points", 20)
local Remotes = game:GetService('ReplicatedStorage').Remotes
script.Parent.PointClicker.Disabled = true

local pointParams = {
	onePointParams = {
		size40 = {
			Point1 = UDim2.new(0.5, 0, 0.5, 0)
		},
		size50 = {
			Point1 = UDim2.new(0.5, 0, 0.5, 0)
		},
		size60 = {
			Point1 = UDim2.new(0.5, 0, 0.5, 0)
		}
	},
	
	twoPointParams = { --// Point1 is to the left of point2
		size40 = {
			Point1 = UDim2.new(0.35, 0, 0.5, 0),
			Point2 = UDim2.new(0.65, 0, 0.5, 0)
		},
		size50 = {
			Point1 = UDim2.new(0.3, 0, 0.5, 0),
			Point2 = UDim2.new(0.7, 0, 0.5, 0)
		},
		size60 = {
			Point1 = UDim2.new(0.275, 0, 0.5, 0),
			Point2 = UDim2.new(0.725, 0, 0.5, 0)
		}
	},
	
	threePointParams = { --// Point1 (left), Point2 (lower mid), Point3 (right)
		size40 = {
			Point1 = UDim2.new(0.35, 0, 0.25, 0),
			Point2 = UDim2.new(0.5, 0, 0.5, 0),
			Point3 = UDim2.new(0.65, 0, 0.25, 0)
		},
		size50 = {
			Point1 = UDim2.new(0.3, 0, 0.25, 0),
			Point2 = UDim2.new(0.5, 0, 0.55, 0),
			Point3 = UDim2.new(0.7, 0, 0.25, 0)
		},
		size60 = {
			Point1 = UDim2.new(0.225, 0, 0.2, 0),
			Point2 = UDim2.new(0.5, 0, 0.525, 0),
			Point3 = UDim2.new(0.775, 0, 0.2, 0)
		}
	}
}

local tweenParams = {
	initialEaseDir = 1,
	initialStyle = 4, --Linear	0--Sine	1--Back	2--Quad	3--Quart	4--Quint 5--Bounce 6--Elastic	7
	initialAnimTime = 0.5
}

local function animatePointUpAndDown(pointImage)	
	local main = coroutine.wrap(function()
		local floatVariations = {0.01, 0.05, 0.025}
		local waitToStartTimes = {0, 0.1, 0.2, 0.3}
		wait(waitToStartTimes[math.random(1, #waitToStartTimes)])
		while true do
			if pointImage.Parent ~= nil then
				--// Go up
				local floatDistance = floatVariations[math.random(1, #floatVariations)]
				pointImage:TweenPosition(UDim2.new(pointImage.Position.X.Scale, 0, pointImage.Position.Y.Scale + floatDistance, 0), 1, 7, .5)
				wait(1)
				if pointImage.Parent ~= nil then
					--// Go down
					pointImage:TweenPosition(UDim2.new(pointImage.Position.X.Scale, 0, pointImage.Position.Y.Scale - floatDistance, 0),
						1, 7, .5)
					wait(1)
				else
					coroutine.yield()				
					--pointImage.Parent:Destroy()
					break
				end
			else 
				coroutine.yield()
				--pointImage.Parent:Destroy()
				break
			end
		end
	end)
	main()
end

local function setImageSize(pointImage)
	local pointAmount = tonumber(pointImage.TextLabel.Text)
	local pointSize
	if pointAmount <= 3 then
		pointSize = 40
		pointImage.Size = UDim2.new(0, pointSize, 0, pointSize)
		pointImage.TextLabel.TextSize = 24
	elseif pointAmount > 3 and pointAmount < 5 then
		pointSize = 50
		pointImage.Size = UDim2.new(0, pointSize, 0, pointSize)
		pointImage.TextLabel.TextSize = 32
	elseif pointAmount >= 5 then
		pointSize = 60
		pointImage.Size = UDim2.new(0, pointSize, 0, pointSize)
		pointImage.TextLabel.TextSize = 40
	end
	return pointSize
end

local function onPointAdded(pointClusterFolder: Folder)
	local points = pointClusterFolder:GetChildren()
	local pointSize
	local pointsPositionDataContainer 
	
	if #points == 1 then
		
		pointSize = setImageSize(points[1].Image)
		if pointSize == 40 then
			pointsPositionDataContainer = pointParams.onePointParams.size40
		elseif pointSize == 50 then
			pointsPositionDataContainer = pointParams.onePointParams.size50		
		elseif pointSize == 60 then
			pointsPositionDataContainer = pointParams.onePointParams.size60
		end

		points[1].Image:TweenPosition(pointsPositionDataContainer.Point1, 
			tweenParams.initialEaseDir,
			tweenParams.initialStyle,
			tweenParams.initialAnimTime)
		
		animatePointUpAndDown(points[1].Image)
		
		local newClicker = script.Parent.PointClicker:Clone()
		newClicker.Parent = points[1].Image
		newClicker.Disabled = false

	elseif #points == 2 then
		pointSize = setImageSize(points[1].Image)
		if pointSize == 40 then
			pointsPositionDataContainer = pointParams.twoPointParams.size40
		elseif pointSize == 50 then
			pointsPositionDataContainer = pointParams.twoPointParams.size50		
		elseif pointSize == 60 then
			pointsPositionDataContainer = pointParams.twoPointParams.size60
		end
		setImageSize(points[2].Image)
	
		points[1].Image:TweenPosition(pointsPositionDataContainer.Point1, 
			tweenParams.initialEaseDir,
			tweenParams.initialStyle,
			tweenParams.initialAnimTime)
		
		points[2].Image:TweenPosition(pointsPositionDataContainer.Point2, 
			tweenParams.initialEaseDir,
			tweenParams.initialStyle,
			tweenParams.initialAnimTime)
		
		animatePointUpAndDown(points[1].Image)
		animatePointUpAndDown(points[2].Image)

		local newClicker1 = script.Parent.PointClicker:Clone()
		local newClicker2 = script.Parent.PointClicker:Clone()
		newClicker1.Parent = points[1].Image
		newClicker2.Parent = points[2].Image
		newClicker1.Disabled = false
		newClicker2.Disabled = false
		
	elseif #points == 3 then
		pointSize = setImageSize(points[1].Image)
		if pointSize == 40 then
			pointsPositionDataContainer = pointParams.threePointParams.size40
		elseif pointSize == 50 then
			pointsPositionDataContainer = pointParams.threePointParams.size50		
		elseif pointSize == 60 then
			pointsPositionDataContainer = pointParams.threePointParams.size60
		end
		setImageSize(points[2].Image)
		setImageSize(points[3].Image)
		
		points[1].Image:TweenPosition(pointsPositionDataContainer.Point1, 
			tweenParams.initialEaseDir,
			tweenParams.initialStyle,
			tweenParams.initialAnimTime)
		
		points[2].Image:TweenPosition(pointsPositionDataContainer.Point2, 
			tweenParams.initialEaseDir,
			tweenParams.initialStyle,
			tweenParams.initialAnimTime)
		
		points[3].Image:TweenPosition(pointsPositionDataContainer.Point3, 
			tweenParams.initialEaseDir,
			tweenParams.initialStyle,
			tweenParams.initialAnimTime)
		
		animatePointUpAndDown(points[1].Image)
		animatePointUpAndDown(points[2].Image)
		animatePointUpAndDown(points[3].Image)
		
		local newClicker1 = script.Parent.PointClicker:Clone()
		local newClicker2 = script.Parent.PointClicker:Clone()
		local newClicker3 = script.Parent.PointClicker:Clone()
		newClicker1.Parent = points[1].Image
		newClicker2.Parent = points[2].Image
		newClicker3.Parent = points[3].Image
		newClicker1.Disabled = false
		newClicker2.Disabled = false
		newClicker3.Disabled = false
	end
end

local function onReceivePointFadedOutToClientFromServer(pointID)
	local pointID = pointsFolderClient:FindFirstChild(tostring(pointID), true)
	if pointID then
		if pointID.Parent then
			if pointID.Parent.Image then
				local targetImage = pointID.Parent.Image
				for _ = 1, 20 do
					wait(.025)
					if targetImage.TextLabel then
						targetImage.ImageTransparency = targetImage.ImageTransparency + 0.05
						targetImage.TextLabel.TextTransparency = targetImage.TextLabel.TextTransparency + 0.05
					else 
						break
					end
				end
				if targetImage.TextLabel then
					targetImage.ImageTransparency = 1
					targetImage.TextLabel.TextTransparency = 1
				end
				targetImage.Parent:Destroy()
			end
		end
	end
end

Remotes["PointFadedOutToClient"].OnClientEvent:Connect(onReceivePointFadedOutToClientFromServer)
pointsFolderClient.ChildAdded:Connect(onPointAdded)
	
