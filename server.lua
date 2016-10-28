--[[	SERVER	]]
services = {} --all services my server can provide
services.SERVER_IP = "127.0.0.1"

--	SERVICES REGISTRATION	--
regS = {} --registrated Services
--[[
regS[service] = {}
regS[service].ip = the ip where the service shall be registrated
regS[service].port = the port where the service shall be registrated
regS[service].reged = false --if this service already was registered
regS[service].doPar(str) - call this functions to return the correct paremetres in "str" to "service"
]]

-- SERVICES TO BE REGISTRATED TABLE CREATION --
regS.echo = {}
regS.echo.ip = services.SERVER_IP
regS.echo.port = 2323
regS.echo.reged = false
function regS.echo.doPar(str)
--[[
	parameters:
		str - string received from client
	return:
		on success, the pareters needed to execute "echo" function.
		on failure, conf.SPE (Server Parameter Error)
]]
	return str
end


-- SERVICES IMPLEMENTATIONS --
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
