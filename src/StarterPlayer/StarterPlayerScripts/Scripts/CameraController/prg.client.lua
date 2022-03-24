repeat wait() until script.Parent.Parent.Parent.ClientMainLoaded.Value == true

local UserInputService = game:GetService('UserInputService')

local Player = game:GetService('Players').LocalPlayer
local Camera = workspace.CurrentCamera
local mouse = Player:GetMouse()
repeat wait() until _G.CurrentCameraController
local currentCameraController = _G.CurrentCameraController
local PlayerGui = Player.PlayerGui
local ZoomGui = PlayerGui.Zoom
local DevTouchZoomScale = ZoomGui.DevTouchZoomScale
local DevTouchZoomVelocity = ZoomGui.DevTouchZoomVelocity
local DevTouchZoomScaleChange = ZoomGui.DevTouchZoomScaleChange

function pcWheelForward ()
	currentCameraController:updateParametersForZoomIn()
end

function pcWheelBackward()
	currentCameraController:updateParametersForZoomOut()
end

local lastTouchScale = nil

local function touchZoom(touchPositions, scale, velocity, state)
	if state == Enum.UserInputState.Change or state == Enum.UserInputState.End then
		local difference = scale - lastTouchScale
		if difference > 0 and math.abs(difference) > 0.01 then
			currentCameraController:updateParametersForZoomIn()
		elseif difference < 0 and math.abs(difference) > 0.01 then
			currentCameraController:updateParametersForZoomOut()
		end
				
		DevTouchZoomScale.Text = "Scale: " .. scale
		DevTouchZoomVelocity.Text = "Velocity: " .. velocity
		DevTouchZoomScaleChange.Text = "Scale Delta: " .. difference
	end
	lastTouchScale = scale
end

if UserInputService.TouchEnabled then	
	UserInputService.TouchPinch:Connect(touchZoom)
else
	mouse.WheelForward:Connect(pcWheelForward)
	mouse.WheelBackward:Connect(pcWheelBackward)
end


--local function onKeyPress(actionName, userInputState, inputObject)
--	if actionName == "moveCamForward" then
--		if userInputState == Enum.UserInputState.Begin then
--			moveDir = Vector3.new(moveDir.X, moveDir.Y, -moveSpeed)
--		elseif userInputState == Enum.UserInputState.End then
--			moveDir = Vector3.new(moveDir.X, moveDir.Y, 0)
--		end
--	elseif actionName == "moveCamLeft" then
--		if userInputState == Enum.UserInputState.Begin then
--			moveDir = Vector3.new(-moveSpeed, moveDir.Y, moveDir.Z)
--		elseif userInputState == Enum.UserInputState.End then
--			moveDir = Vector3.new(0, moveDir.Y, moveDir.Z)
--		end
--	elseif actionName == "moveCamBackward" then
--		if userInputState == Enum.UserInputState.Begin then
--			moveDir = Vector3.new(moveDir.X, moveDir.Y, moveSpeed)
--		elseif userInputState == Enum.UserInputState.End then
--			moveDir = Vector3.new(moveDir.X, moveDir.Y, 0)
--		end
--	elseif actionName == "moveCamRight" then
--		if userInputState == Enum.UserInputState.Begin then
--			moveDir = Vector3.new(moveSpeed, moveDir.Y, moveDir.Z)
--		elseif userInputState == Enum.UserInputState.End then
--			moveDir = Vector3.new(0, moveDir.Y, moveDir.Z)
--		end
--	end
--end

--game.ContextActionService:BindAction("moveCamForward",  onKeyPress, false, Enum.PlayerActions.CharacterForward)
--game.ContextActionService:BindAction("moveCamLeft",     onKeyPress, false, Enum.PlayerActions.CharacterLeft)
--game.ContextActionService:BindAction("moveCamBackward", onKeyPress, false, Enum.PlayerActions.CharacterBackward)
--game.ContextActionService:BindAction("moveCamRight",    onKeyPress, false, Enum.PlayerActions.CharacterRight)
