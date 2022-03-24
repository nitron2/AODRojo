local RollingDisasterFact = {}
RollingDisasterFact.__index = RollingDisasterFact

function RollingDisasterFact.new(d, m)
	local newRollingDisasterFact = {
		message = m,
		duration = d
	}
	setmetatable(RollingDisasterFact, newRollingDisasterFact)
	return newRollingDisasterFact
end

return RollingDisasterFact
