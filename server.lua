--[[	SERVER	]]
services = {} --all services my server can provide

function services.echo(str)
--[[
	parameters:
		str - string you want to hear the acho
	return:
		return str in success, or false otherwise
]]
	local sret

	if(type(str) ~= "string") then
		print("SERVER: ECHO's argument spected to be string but it's " .. type(strmsg))
		sret = false
	else
		print("SERVER: echo invoked for "..str) --testline
		sret = str
	end

	return sret
end