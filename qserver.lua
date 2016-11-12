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
-- SERVICE IMPLEMENTATIONS --
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
-- SERVICE IMPLEMENTATIONS --
--[[
	parameters:
		str - string you want to hear the qpos
	return:
		return str in success, or false otherwise
]]
	if(qregS.qpos.positions == nil) then
		qregS.qpos.positions = {}
	end

	local positions = qregS.qpos.positions

	if(command == "update") then
		if(positions[cname] ~= nil) then
			positions[cname] = {}
		end
		positions[cname].x = x
		positions[cname].y = y
		positions[cname].needUpdate = true
	elseif(command == "remove") then
		positions[cname].x = nil
		positions[cname].y = nil
		positions[cname].needUpdate = true
	else
		--error: command not recognized
	end
end
