--[[	INVOKER	]]
require "srh"
require "server"

invok = {}

function invok.invoker(command)
--[[
	parameters:
		command - the command that the client sent to the server
	return:
		the return of the asked application, or nil if the invoker fails
]]
	local ret

	if(type(command) ~= "string") then
		print("LUA: 1st argument of invok.invoker spected to be string but it's " .. type(strmsg))
		ret = nil
	end

	return ret
end