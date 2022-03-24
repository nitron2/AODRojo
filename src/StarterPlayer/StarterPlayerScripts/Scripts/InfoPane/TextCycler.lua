local TextCycler = {}
TextCycler.__index = TextCycler

function TextCycler.new(disaster)
	local newTextCycler = {
		disasterName = disaster,
		continueToRun = true
	}
	setmetatable(newTextCycler, TextCycler)
	return newTextCycler
end

local function updateText(Frame, newText)
	Frame.InfoHolder.FunFact.Text = newText
end

function TextCycler:run()
	local disasterInfoData = require(script.Parent.DisasterInfoData)
	--coroutine.wrap(function()
	local currentDisaster = disasterInfoData[self.disasterName]
	local currentDisasterFrame = currentDisaster.frame
	repeat 
		--print(self.disasterName .. "Cnt to run: " .. tostring(self.continueToRun))
		--if self.continueToRun == false then break end
		updateText(currentDisasterFrame, currentDisaster.messages[currentDisaster.index].message)
		wait(currentDisaster.messages[currentDisaster.index].duration) 
		--print(self.disasterName .. "Cnt to run: " .. tostring(self.continueToRun))
		--if self.continueToRun == false then break	end
		if currentDisaster.index == #currentDisaster.messages then
			currentDisaster.index = 1
		else
			currentDisaster.index = currentDisaster.index + 1
		end
		--print(self.disasterName .. "Cnt to run: " .. tostring(self.continueToRun))
	until self.continueToRun == false
	self = nil
end

return TextCycler
