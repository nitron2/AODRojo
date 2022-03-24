--[[
	-TweenService needs to be referenced and obtained by the game
	-TweensService objects are puasable, can be cancelled
	-TweenService:Create(object to tween, tween info, goal info)
	-tween.Completed:Wait() -- wait for a tween to end
	-You can tween:
		number
		bool
		CFrame
		Rect
		Color3
		UDim
		UDim2
		Vector2
		Vector2int16
		Vector3
	-Tweening is really interpolation
	-You can tween multiple things about an object at once
]]--

local TweenService = game:GetService("TweenService")

local part = Instance.new("Part")
part.Position = Vector3.new(0, 10, 0)
part.Anchored = true
part.Parent = game.Workspace

local tweenInfo = TweenInfo.new(
	2, -- Time
	Enum.EasingStyle.Linear, -- EasingStyle
	Enum.EasingDirection.Out, -- EasingDirection
	-1, -- RepeatCount (when less than zero the tween will loop indefinitely)
	true, -- Reverses (tween will reverse once reaching it's goal)
	0 -- DelayTime
)

local goal = {
	Position = Vector3.new(0, 30, 0)
}

local tween = TweenService:Create(part, tweenInfo, goal)

tween:Play()
wait(10)
tween:Cancel() -- cancel the animation after 10 seconds

