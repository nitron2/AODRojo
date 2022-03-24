return function (table1, table2)
	local compareTwoTables = require(script)
	for i, v in pairs(table1) do
		if (typeof(v) == "table") then
			if (compareTwoTables(table2[i], v) == false) then
				return false
			end
		else
			if (v ~= table2[i]) then
				return false
			end
		end
	end
	return true
end
