--[[	SERVER	]]
qservices = {} --all services my server can provide
qservices.SERVER_IP = "127.0.0.1"

--	SERVICES REGISTRATION	--
qregS = {} --registrated Services
--[[
qregS[service] = {}
qregS[service].ip = the ip where the service shall be registrated
qregS[service].port = the port where the service shall be registrated
qregS[service].reged = false --if this service already was registered
qregS[service].doPar(str) - call this functions to return the correct paremetres in "str" to "service"
]]


-- SERVICES TO BE REGISTRATED TABLE CREATION --
qregS.echo = {}
qregS.echo.ip = qservices.SERVER_IP
qregS.echo.port = 2323
qregS.echo.reged = false
function qregS.echo.doPar(str)
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
