--[[	QUEUE SERVER TO REQUEST HANDLER		]]
require "qsinvoker"
require "socket"

qsrh = {}
local STP = 100000 --STP (Sleep Time Pattern) --100000μs = 0,1s

function qsrh.send(strmsg, key, ip, port, socktable)
--[[
	parameters:
		strmsg - string to be sent over the net.
		key - the key to the socket to be used. Or nil if the sock was never created
		ip - the ip where to send the msg. (it's only obligatory if key is nil or protocol is udp)
		port - the port where to send the msg. (it's only obligatory if key is nil or protocol is udp)
		socktable - a table with: (it's only obligatory if key is nil)
			socktable.proto - the protocol to be used.
			socktable.ip - the ip of this socket.
			socktable.port - the port of this socket.

	return:
		on success a key (string) that uniquely identify who is asking this send, an empty string otherwise.
		a numer with the amount of bytes sent
]]
	local bytes

	--do not check all the parameters because the functions in socket.lua already do it

	if(key == nil and type(socktable) ~= "table") then
		error("LUA: 1st argument of qsrh.send spected to be table but it's " .. type(socktable))
	elseif(key == nil and type(socktable.proto) ~= "number") then
		error("LUA: in 1st argument of qsrh.send, socktable.proto spected to be number but it's " .. type(socktable.proto))
	elseif(key == nil and socktable.proto == lsok.proto.tcp and type(socktable.ip) ~= "string") then
		error("LUA: in 1st argument of qsrh.send, socktable.ip spected to be string but it's " .. type(socktable.ip))
	elseif(key == nil and socktable.proto == lsok.proto.tcp and type(socktable.port) ~= "number") then
		error("LUA: in 1st argument of qsrh.send, socktable.port spected to be number but it's " .. type(socktable.port))
	else
		if(key == nil) then
			key = gsh.create()
			gsh.set(socktable.proto, key, socktable.ip, socktable.port, true)
		elseif(gsh.isSetted(key) == false) then
			gsh.set(socktable.proto, key, socktable.ip, socktable.port, true)
		end

		if(gsh.isActive(key) == false and gsh.getProto(key) == lsok.proto.tcp) then
			gsh.connect(key, ip, port)
		end

		bytes = gsh.send(strmsg, key, false, ip, port)
		if(bytes <= 0) then
			print("LUA: bytes not sent")
		end
	end

	return key, bytes
end

function qsrh.recv(key, flag, proto, ip, port)
--[[
	parameters:
		key - the key to he socket to be used. Or nil if the sock was never created
		flag - pas true to delete this socket after use if the service wont the socket anymore.
		proto - the protocol to be used. (if key isn't nil, forget about this parameter)
		ip - the ip of this socket. (if key isn't nil, forget about this parameter)
		port - the port of this socket. (if key isn't nil, forget about this parameter)
	return:
		on success a key (string) that uniquely identify who is asking this send, an empty string otherwise.
		on success the returned string, an empty string otherwise.
]]
	local sret
	local bytes

	--do not check all the parameters because the functions in socket.lua already do it
	--sret = lsok.recv(socktable.sock, lsok.proto.tcp)

	if(key == nil) then
		key = gsh.create()
		gsh.set(proto, key, ip, port)
	elseif(gsh.isSetted(key) == false) then
		gsh.set(proto, key, ip, port)
	end
	
	if(gsh.isActive(key) == false and gsh.getProto(key) == lsok.proto.tcp) then
		gsh.accept(key)
	end

	sret = gsh.recv(key, flag)

	return key, sret
end

-- CHECK AND REGISTER SERVICES --
function checkNregister()
--[[
	Functionality:
		call this funtion to check if all the services in this server are registrated.
		if they dont, this function will register it.
	Return:
		true in success, false otherwise
]]
	local dnsSock
	local bytes
	local ret
	local ok = true

	print("services registration...")
	for key,value in pairs(qregS) do
		print("\tADD("..key..","..value.ip..","..value.port..")")
		dnsSock, bytes = qsrh.send("ADD("..key..","..value.ip..","..value.port..")", nil, conf.dnsIP, conf.dnsPort, {proto = conf.dnsProto})
		dnsSock, ret = qsrh.recv(dnsSock, false)
		print("\t\t"..ret)

		if(ret == conf.dnsOk) then
			value.reged = true
		else
			ok = false
			print("LUA: in checkNregister, could not register \""..key.."\" service")
			break
		end
	end
	print("all services registrated")

	gsh.close(dnsSock)

	return ok
end

local function opensockets()
--[[
	parameters:
		just open the socket of all services in the server
	return:
		a table with all keys
]]
	local boolret
	local tret = {}

	for rkey,rval in pairs(qregS) do
		if(rval.reged == true) then
			--only open socket to those services who are registrated in the queue server
			rval.skey = gsh.create()
			boolret = gsh.set(rval.proto, rval.skey, rval.ip, rval.port)
			if(boolret == false) then
				print("could not set socktable of queue service \""..rkey.."\"")
				os.exit()
			end
			table.insert(tret, rval.skey)
		end
	end

	return tret
end

--[[	RUNNING SERVER	]]
local bytes
local scmd
local worked
local keyt
local taux


--request registration on the DNS
checkNregister()
keyt = opensockets()

while(true) do
	worked = false

	--receive the request from a new conection
	taux = gsh.is_acceptable(keyt)
	if(taux ~= nil) then
		for key, value in pairs(taux) do
			gsh.accept(taux.skey)
			worked = true
		end
	end

	taux = gsh.is_readable(keyt)
	if(taux ~= nil) then
		for key, value in pairs(taux) do
			taux.skey, scmd = srh.recv(taux.skey, false, conf.proto, taux.ip, taux.port)
			--call invoker and return it's answere
			scmd = qsinvok.invoker(scmd)
			print("server will answer: "..scmd)
			taux.skey, bytes = srh.send(scmd, taux.skey)
			
			gsh.deactivate(taux.skey)
			worked = true
		end
	end

	if(worked == false) then
		lsok.sleep(STP)
	end
end

gsh.closeAll()
