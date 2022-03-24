--!strict
local CameraController = {}

local RunService = game:GetService('RunService')
local ContextActionService = game:GetService('ContextActionService')
local TweenService = game:GetService('TweenService')
local Camera = workspace.CurrentCamera
local WorldModel = workspace.WorldModel
local CameraRigging = WorldModel.CameraRigging
local PositionLimits = CameraRigging.PositionLimits
local ZoomLevels = CameraRigging.ZoomLevels
local Player = game.Players.LocalPlayer
local Character = Player.Character

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CameraController = {}
CameraController.__index = CameraController

local ZOOM_Y_POSITIONS = {
	ZoomLevels.Position1.Position.Y,
	ZoomLevels.Position2.Position.Y,
	ZoomLevels.Position3.Position.Y,
	ZoomLevels.Position4.Position.Y,
	ZoomLevels.Position5.Position.Y,
	ZoomLevels.Position6.Position.Y,
	ZoomLevels.Position8.Position.Y,
	ZoomLevels.Position9.Position.Y,
	ZoomLevels.Position10.Position.Y,
	ZoomLevels.Position11.Position.Y,
	ZoomLevels.Position12.Position.Y,
	ZoomLevels.Position13.Position.Y,
	ZoomLevels.Position14.Position.Y
}

local SPEED_MULTIPLIERS = {
	6,
	5,
	4.75,
	4.5,
	4.25,
	4,
	3.75,
	3.5,
	3.25,
	3,
	2.5,
	2,
	1.5,
	1,
}

local DOWNWARD_LOOK_ANGLES = {
	CFrame.Angles(-math.rad(90), 0, 0),
	CFrame.Angles(-math.rad(90), 0, 0),
	CFrame.Angles(-math.rad(90), 0, 0),
	CFrame.Angles(-math.rad(90), 0, 0),
	CFrame.Angles(-math.rad(90), 0, 0),
	CFrame.Angles(-math.rad(90), 0, 0),
	CFrame.Angles(-math.rad(90), 0, 0),
	CFrame.Angles(-math.rad(90), 0, 0),
	CFrame.Angles(-math.rad(90), 0, 0),
	CFrame.Angles(-math.rad(90), 0, 0),
	CFrame.Angles(-math.rad(90), 0, 0),
	CFrame.Angles(-math.rad(80), 0, 0),
	CFrame.Angles(-math.rad(70), 0, 0),
	CFrame.Angles(-math.rad(60), 0, 0)
}

local RETICLE_MODELS = {
	--References to different models
	--Each will have their own correct z value
	--
}

local CAM_POSITION_BOUNDS = {
	['XLeft'] = PositionLimits.BL.Position.X,
	['XRight'] = PositionLimits.TR.Position.X,
	['ZTop'] = PositionLimits.TR.Position.Z,
	['ZBottom'] = PositionLimits.BL.Position.Z
}

local MOVE_DRIECTION_DIAGONAL = 0.707106829

local MOVE_DIRECTIONS = {
	['None'] = Vector3.new(0,0,0),
	['Up'] = Vector3.new(0,0,-1),
	['Down'] = Vector3.new(0,0,1),
	['Right'] = Vector3.new(1,0,0),
	['Left'] = Vector3.new(-1,0,0),
		
	['TopRight'] = Vector3.new(MOVE_DRIECTION_DIAGONAL,0,-MOVE_DRIECTION_DIAGONAL),
	['BottomLeft'] = Vector3.new(-MOVE_DRIECTION_DIAGONAL,0,MOVE_DRIECTION_DIAGONAL),
	['BottomRight'] = Vector3.new(MOVE_DRIECTION_DIAGONAL,0,MOVE_DRIECTION_DIAGONAL),
	['TopLeft'] = Vector3.new(-MOVE_DRIECTION_DIAGONAL,0,-MOVE_DRIECTION_DIAGONAL)	
}

local function isVector3Equal(vectorA : Vector3, vectorB : Vector3)
	if vectorA.X == vectorB.X and vectorA.Y == vectorB.Y and vectorA.Z == vectorB.Z then
		return true
	end
	return false
end

local function isGoingTooFarDown(cameraPosition: Vector3)
	if cameraPosition.Z >= CAM_POSITION_BOUNDS['ZBottom'] then
		return true
	end 
	return false
end

local function isGoingTooFarUp(cameraPosition: Vector3)
	if cameraPosition.Z <= CAM_POSITION_BOUNDS['ZTop'] then
		return true
	end 
	return false
end

local function isGoingTooFarLeft(cameraPosition: Vector3)
	if cameraPosition.X <= CAM_POSITION_BOUNDS['XLeft'] then
		return true
	end
	return false
end

local function isGoingTooFarRight(cameraPosition: Vector3)
	if cameraPosition.X >= CAM_POSITION_BOUNDS['XRight'] then
		return true
	end
	return false
end

local function isGoingOutOfBounds(moveVector: Vector3, cameraPosition : Vector3)
	if isVector3Equal(moveVector, MOVE_DIRECTIONS['Up']) then
		if isGoingTooFarUp(cameraPosition) then
			return true 
		end
	elseif isVector3Equal(moveVector, MOVE_DIRECTIONS['Down']) then
		if isGoingTooFarDown(cameraPosition) then
			return true 
		end
	elseif isVector3Equal(moveVector, MOVE_DIRECTIONS['Right']) then
		if isGoingTooFarRight(cameraPosition) then
			return true 
		end
	elseif isVector3Equal(moveVector, MOVE_DIRECTIONS['Left']) then
		if isGoingTooFarLeft(cameraPosition) then
			return true 
		end
	elseif isVector3Equal(moveVector, MOVE_DIRECTIONS['TopRight']) then
		if isGoingTooFarUp(cameraPosition) or isGoingTooFarRight(cameraPosition) then
			return true
		end
	elseif isVector3Equal(moveVector, MOVE_DIRECTIONS['BottomLeft']) then
		if isGoingTooFarDown(cameraPosition) or isGoingTooFarLeft(cameraPosition) then
			return true
		end
	elseif isVector3Equal(moveVector, MOVE_DIRECTIONS['BottomRight']) then
		if isGoingTooFarDown(cameraPosition) or isGoingTooFarRight(cameraPosition) then
			return true
		end
	elseif isVector3Equal(moveVector, MOVE_DIRECTIONS['TopLeft']) then
		if isGoingTooFarUp(cameraPosition) or isGoingTooFarLeft(cameraPosition) then
			return true
		end
	end
	return false
end

function CameraController:updatePosition()
	local moveVector = Character.Humanoid.MoveDirection
	local cameraPosition =  Camera.CFrame.Position
	
	if isGoingOutOfBounds(moveVector, cameraPosition) then
		moveVector = MOVE_DIRECTIONS['None']
	end
	
	Camera.CFrame = 
		CFrame.new(Camera.CFrame.Position.X, self.currentY.Value, Camera.CFrame.Position.Z) * 
		CFrame.new(self.speedMultiplier * moveVector) * 
		self.downwardLookAngle
end

function CameraController:updateParametersForZoomIn()
	if self.zoomLevel < 14 then
		self.zoomLevel = self.zoomLevel + 1
		self:updateParameters()
	end
end

function CameraController:updateParametersForZoomOut()
	if self.zoomLevel > 1 then
		self.zoomLevel =  self.zoomLevel - 1
		self:updateParameters()
	end
end

function CameraController:updateParameters()
	self.speedMultiplier = SPEED_MULTIPLIERS[self.zoomLevel]
	self.downwardLookAngle = DOWNWARD_LOOK_ANGLES[self.zoomLevel]
	self.zoomPositionY = ZOOM_Y_POSITIONS[self.zoomLevel]
	local tween
	local tweenInfo = TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
	local goal = {Value = self.zoomPositionY}
	tween = TweenService:Create(self.currentY, tweenInfo, goal)
	tween:Play()
end

function CameraController.new()
	local newCameraController = {
		startingPosition = ZoomLevels.Position1.Position,
		zoomLevel = 1,
		speedMultiplier = SPEED_MULTIPLIERS[1],
		zoomPositionY = ZOOM_Y_POSITIONS[1],
		downwardLookAngle = DOWNWARD_LOOK_ANGLES[1],
		currentY = script.Parent.Parent.Parent.currentCameraY
	}
	newCameraController.currentY.Value = newCameraController.zoomPositionY
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.FieldOfView = 60
	Camera.CFrame = CFrame.new(newCameraController.startingPosition) * newCameraController.downwardLookAngle
	
	setmetatable(newCameraController, CameraController)
	return newCameraController
end

return CameraController
