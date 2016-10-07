--[[	INVOKER	]]
require "server"

invok = {}

function invok.invoker(command)
--[[
	parameters:
		command - the command that the client sent to the server
	return:
		return the msg to be sent back to the client, or nil if the invoker fails
]]
	local answere
	local rs --rs = resquested service
	local load

	if(type(command) ~= "string") then
		print("LUA: 1st argument of invok.invoker spected to be string but it's " .. type(strmsg))
		answere = nil
	else
		local si, sf
		si = string.find(command, "%(")
		rs = string.lower(string.sub(command, 1, si-1))
		sf = string.find(command, ")")
		load = string.sub(command, si+1, sf-1)
		--invoking the correct service with the correct parameters
		if(rs == "echo") then
			answere = services.echo(load)
		else
			answere = nil
			print("LUA: the requested service do not exist!")
		end
	end

	return answere
end