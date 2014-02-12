-- XO:
function bxor (a,b)
	local r = 0
	for i = 0, 31 do
		local x = a / 2 + b / 2
		if x ~= math.floor (x) then
			r = r + 2^i
		end
		a = math.floor (a / 2)
		b = math.floor (b / 2)
	end
	return r
end
