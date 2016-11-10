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
qregS.qpos = {} --queue position
qregS.qpos.ip = qservices.SERVER_IP
qregS.qpos.port = 8353
qregS.qpos.reged = false
--the ip and port of the server that will process the information of this queue will be
-- automatically filled after the queue server and server start
qregS.qpos.serverIP = nil
qregS.qpos.serverPORT = nil
function qregS.qpos.doPar(str)
--[[
	parameters:
		str - string received from client with the format "update(clientName,x,y)"
	return:
		on success, the pareters needed to execute "position" function.
		on failure, conf.SPE (Server Parameter Error)
]]
	local command,cname, x, y
	local si, sf
	si = string.find(str, "%(")
	command = string.lower(string.sub(str, 1, si-1))
	sf = string.find(str, ",", si+1)
	cname = string.sub(str, si+1, sf-1)
	si = string.find(str, ",", sf+1)
	x = tonumber(string.sub(str, sf+1, si-1))
	sf = string.find(str, ")", si+1)
	y = tonumber(string.sub(str, si+1, sf-1))

print("qregS.qpos.doPar: "..command.."("..cname..", "..x..", "..y..")")
	return command, cname, x, y
end

function qservices.qpos(command, cname, x, y)
--[[
	parameters:
		str - string you want to hear the acho
	return:
		return str in success, or false otherwise
]]
	if(services.qpos.positions == nil) then
		services.qpos.positions = {}
	end

	local positions = services.qpos.positions

	if(command == "update") then
		if(positions[cname] ~= nil) then
			positions[cname] = {}
		end
		--falta checar se já existe outro jogador nesse lugar
		positions[cname].x = x
		positions[cname].y = y
		positions[cname].needUpdate = true
	elseif(command == "remove") then
	else
		if(positions[cname] == nil) then
			--error: this client is not on the list
		else
			positions[cname] = nil
		end
		--error: command not recognized
	end
end


-- SERVICES IMPLEMENTATIONS --
