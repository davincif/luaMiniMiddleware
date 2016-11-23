--[[	SERVER	]]
io.write("QS password: ")
local QSpassword = io.read()
print("stored")

services = {} --all services my server can provide

--	PASSWORD FUNCTION	--
function services.getPassword()
	return QSpassword
end

--	SERVICES REGISTRATION	--
regS = {} --registrated Services
--[[
regS[service] = {}
regS[service].ip = the ip where the service shall be registrated on QS
regS[service].port = the port where the service shall be registrated on QS
regS[service].proto = protocol to be used (usualy conf.proto)
regS[service].reged = false --if this service already was registered
regS[service].socket = the socket of this service
regS[service].QS_IP = nil
regS[service].QS_PORT = nil
--the ip and port of the server that will process the information of this queue will be
-- automatically filled after the queue server and server start
regS[service].doPar(str) - call this functions to return the correct paremetres in "str" to "service"

--after all, call services[service](regS[service].doPar(str)) to finally perfor the service
]]

-- SERVICES TO BE REGISTRATED TABLE CREATION --

--[[CHAT]]
regS.chat = {}
regS.chat.proto = conf.proto
regS.chat.reged = false
function regS.chat.doPar(str)
--[[
	parameters:
		str - string received from client
	return:
		on success, the pareters needed to execute "chat" function.
		on failure, conf.SPE (Server Parameter Error)
]]
	return str
end
function services.chat(cname, str)
-- SERVICE IMPLEMENTATIONS --
--[[
	parameters:
		cname - the name of the client who already signnd on this queue
		str - string you want to hear the acho
	return:
		return str in success, or false otherwise
]]
	local sret

	if(type(str) ~= "string") then
		print("SERVER: CHAT's argument spected to be string but it's " .. type(strmsg))
		sret = false
	else
		print("SERVER: chat invoked for "..str) --testline
		sret = ">"..str
	end

	return sret
end


--[[POSITION]]
regS.qpos = {}
regS.qpos.proto = conf.proto
regS.qpos.reged = false
function regS.qpos.doPar(str)
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

	print("regS.qpos.doPar: "..command.."("..cname..", "..x..", "..y..")")
	return command, cname, x, y
end
services.qpos = {}
services.qpos.dellist = {}
services.qpos.dellist.quantity = 0
services.qpos.queue = {}
services.qpos.queue.quantity = 0
services.qpos.queue.s_update = false
services.qpos.queue.c_update = false
function services.qpos.sign(cname, password)
-- SERVICE IMPLEMENTATIONS --
--[[
	parameters:
		cname - the name of the client who want to sign on this queue
		password - the password of this client (if needed)
	return:
		return true on success, false otherwise (that only occurs if the client is already signed)
	PS.: currently, the password is only used to check the altentidy of the server
]]
end
function services.qpos.revoke(cname)
-- SERVICE IMPLEMENTATIONS --
--[[
	parameters:
		cname - the name of the client who want to sign on this queue
	return:
		return true on success, false otherwise (that only occurs if the client already isn't signed)
]]
end
function services.qpos.update(command, cname, x, y)
-- SERVICE IMPLEMENTATIONS --
--[[
	parameters:
		str - string you want to hear the qpos
	return:
		return str in success, or false otherwise
]]
	if(regS.qpos.positions == nil) then
		regS.qpos.positions = {}
	end

	local positions = regS.qpos.positions

	if(command == "update") then
		local collides = false

		if(positions[cname] ~= nil) then
			positions[cname] = {}
		end
		for key,value in pairs(positions) do
			if(value.x == x and value.y == y) then
				collides = true
				break
			end
		end
		if(collides == false) then
			positions[cname].x = x
			positions[cname].y = y
		end
		positions[cname].needUpdate = true
	elseif(command == "remove") then
		positions[cname].x = nil
		positions[cname].y = nil
		positions[cname].needUpdate = true
	else
		--error: command not recognized
	end
end
