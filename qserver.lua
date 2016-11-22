--[[	SERVER	]]
io.write("password: ")
local QSpassword = io.read()
print("stored")

qservices = {} --all services my server can provide
qservices.SERVER_IP = "127.0.0.1"
--[[
qservices[service] = {}
qservices[service].sign()
qservices[service].revoke()
qservices[service].update()
qservices[service].dellist = {} --list of client revoked still not informed to the server
qservices[service].dellist.quantity = 2 --the quantity of client to inform about the revoke to the server
qservices[service].dellist[1] = "client1"
qservices[service].dellist[2] = "client2" -- so on...
qservices[service].queue = {} --put here anydata you quant to store
qservices[service].queue.s_update = false --set true to update information to server as soon as possible
qservices[service].queue.c_update = false --set true to update information to the clients
qservices[service].queue.quantity = 0 --the quantity of clients
qservices[service].queue[client] = {} --a new table to store each client information
qservices[service].queue[client].___ --any data needed to the service
qservices[service].queue[client].s_update = false --set true to update information of this specific client to server as soon as possible
qservices[service].queue[client].c_update = false --set true only if this information already was processed by the server and is ready to be set to the client
]]

--	PASSWORD FUNCTION	--
function qservices.comparePass(password)
	return password == QSpassword
end

--	SERVICES REGISTRATION	--
qregS = {} --registrated Services
--[[
qregS[service] = {}
qregS[service].ip = the ip where the service shall be registrated
qregS[service].port = the port where the service shall be registrated
qregS[service].reged = false --if this service already was registered
qregS[service].proto = protocol to be used (usualy conf.proto)
qregS[service].skey = the socket of this service
qregS[service].serverIP = nil --the ip of the server who is gonna process the this queue's information
qregS[service].serverPORT = nil --the port of the server who is gonna process the this queue's information
--the ip and port of the server that will process the information of this queue will be
-- automatically filled after the queue server and server start
qregS[service].doPar(str) - call this functions to return the correct paremetres in "str" to "service"

--after all, call services[service](regS[service].doPar(str)) to finally perfor the work on this service's queue
]]


-- SERVICES TO BE REGISTRATED TABLE CREATION --

--[[CHAT]]
qregS.chat = {}
qregS.chat.ip = qservices.SERVER_IP
qregS.chat.port = math.random(conf.minPort, conf.maxPort)
qregS.chat.proto = conf.proto
qregS.chat.reged = false
function qregS.chat.doPar(str)
--[[
	parameters:
		str - string received from client
	return:
		on success, the pareters needed to execute "chat" function.
		on failure, conf.SPE (Server Parameter Error)
]]
	return str
end
qservices.chat = {}
qservices.chat.dellist = {}
qservices.chat.dellist.quantity = 0
qservices.chat.queue = {}
qservices.chat.queue.quantity = 0
qservices.chat.queue.s_update = false
qservices.chat.queue.c_update = false
function qservices.chat.sign(cname, password)
-- SERVICE IMPLEMENTATIONS --
--[[
	parameters:
		cname - the name of the client who want to sign on this queue
		password - the password of this client (if needed)
	return:
		return true on success, false otherwise (that only occurs if the client is already signed)
	PS.: currently, the password is only used to check the altentidy of the server
]]
	local boolret

	if(type(cname) ~= "string") then
		error("qservices.chat.sign 1st argument spected to be string but it's "..type(cname))
	end

	--ordinary client contact
	if(qservices.chat.queue[cname] == nil) then
		qservices.chat.queue.quantity = qservices.chat.queue.quantity + 1
		qservices.chat.queue[cname] = {}
		qservices.chat.queue[cname].s_update = false
		qservices.chat.queue[cname].c_update = false
		boolret = true
		conf.print("QS: client \""..cname.."\" got in the queue")
	else
		boolret = false
		conf.print("QS: client \""..cname.."\" is already in the queue")
	end

	return boolret
end

function qservices.chat.revoke(cname)
-- SERVICE IMPLEMENTATIONS --
--[[
	parameters:
		cname - the name of the client who want to sign on this queue
	return:
		return true on success, false otherwise (that only occurs if the client already isn't signed)
]]
	local boolret

	if(type(cname) ~= "string") then
		error("qservices.chat.revoke 1st argument spected to be string but it's "..type(cname))
	end

	if(qservices.chat.queue[cname] == nil) then
		qservices.chat.queue.quantity = qservices.chat.queue.quantity - 1
		qservices.chat.queue[cname] = nil
		table.insert(qservices.chat.dellist, cname)
		qservices.chat.dellist.quantity = qservices.chat.dellist.quantity + 1
		boolret = true
		print("QS: client \""..cname.."\" got out of the queue")
	else
		boolret = false
		print("QS: client \""..cname.."\" already is not in the queue")
	end

	return boolret
end

function qservices.chat.update(cname, str)
-- SERVICE IMPLEMENTATIONS --
--[[
	parameters:
		cname - the name of the client who already signnd on this queue
		str - string that the client whats to say
	return:
		return true on success, false if the previous msg of this client still wasn't processed,
		or nil if the client isn't signed
]]
	local boolret
	--local str = "str"
	local count = 1

	if(type(cname) ~= "string") then
		error("qservices.chat.sign 1st argument spected to be string but it's "..type(cname))
	elseif(type(str) ~= "string") then
		error("qservices.chat.sign 2ns argument spected to be string but it's "..type(str))
	end

	if(qservices.chat.queue[cname] ~= nil) then
		if(qservices.chat.queue[cname].s_update == false and qservices.chat.queue[cname].c_update == false) then
			qservices.chat.queue.s_update = true
			qservices.chat.queue[cname].str = str
			qservices.chat.queue[cname].s_update = true
			print("QS: client \""..cname.."\" updated chat with msg:  " .. str)
			boolret = true
		else
			print("QS: the previous msg of " .. cname .. " still wasn't processed.")
			boolret = false --troquei aqui de nil pra false
		end
	else
		print("QS: client" .. cname .. " not registered.")
		boolret = nil -- troquei aqui de false pra nill 
	end

	return boolret
end


--[[POSITION]]
qregS.qpos = {} --queue position
qregS.qpos.ip = qservices.SERVER_IP
qregS.qpos.port = math.random(conf.minPort, conf.maxPort)
qregS.qpos.proto = conf.proto
qregS.qpos.reged = false
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
qservices.qpos = {}
qservices.qpos.dellist = {}
qservices.qpos.dellist.quantity = 0
qservices.qpos.queue = {}
qservices.qpos.queue.quantity = 0
qservices.qpos.queue.s_update = false
qservices.qpos.queue.c_update = false
function qservices.qpos.sign(cname, password)
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
function qservices.qpos.revoke(cname)
-- SERVICE IMPLEMENTATIONS --
--[[
	parameters:
		cname - the name of the client who want to sign on this queue
	return:
		return true on success, false otherwise (that only occurs if the client already isn't signed)
]]
end
function qservices.qpos.update(command, cname, x, y)
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
