--[[	SERVER TO REQUEST HANDLER	]]
require "invoker"
require "socket"

srh = {}

function srh.send(strmsg, key, ip, port, socktable)
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
		error("LUA: 1st argument of srh.send spected to be table but it's " .. type(socktable))
	elseif(key == nil and type(socktable.proto) ~= "number") then
		error("LUA: in 1st argument of srh.send, socktable.proto spected to be number but it's " .. type(socktable.proto))
	elseif(key == nil and socktable.proto == lsok.proto.tcp and type(socktable.ip) ~= "string") then
		error("LUA: in 1st argument of srh.send, socktable.ip spected to be string but it's " .. type(socktable.ip))
	elseif(key == nil and socktable.proto == lsok.proto.tcp and type(socktable.port) ~= "number") then
		error("LUA: in 1st argument of srh.send, socktable.port spected to be number but it's " .. type(socktable.port))
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

function srh.recv(key, flag, proto, ip, port)
--[[
	parameters:
		flag - pas true to delete this socket after use if the service wont the socket anymore.
		key - the key to the socket to be used. Or nil if the sock was never created
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
		call this funtion to check if all the services in this server are registrated
		if they dont, this function will register it.
	Return:
		true in success, false otherwise
]]
	local dnsSock
	local bytes
	local ret
	local ok = true

	print("services registration...")
	for key,value in pairs(regS) do
		print("\tADD("..key..","..value.ip..","..value.port..")")
		dnsSock, bytes = srh.send("ADD("..key..","..value.ip..","..value.port..")", nil, conf.dnsIP, conf.dnsPort, {proto = conf.dnsProto})
		dnsSock, ret = srh.recv(dnsSock, true)
		print("\t\t"..ret)

		if(ret == conf.dnsOk) then
			dnsSock = nil
		else
			ok = false
			print("LUA: in checkNregister, could not register \""..key.."\" service")
			break
		end
	end
	print("all services registrated")

	return ok
end

-- FIND SERVICE --
function findS(service)
--[[
	parameters:
		service - the service's name you want know about.
	return:
		the service's ip and port in success, conf.dnsNotFoun otherwise
]]
	local ip
	local port
	local skey
print("searching....")
	if(type(service) ~= "string") then
		error("LUA: findS 1st argument spected to be string but it's " .. type(service))
	else
		local si, sf
		local sret --string returned
		local bytes

		skey, bytes = srh.send("SEARCH("..service..")", nil, conf.dnsIP, conf.dnsPort, {proto = conf.dnsProto})
		skey, sret = srh.recv(skey, true)
		print("\t\t"..sret)
		if(sret == conf.dnsNotFound) then
			print("service \"" ..service.."\" not registrated at the DNS")
			ip = sret
		else
			print("service \"" ..service.."\" on server: "..sret) --testline

			si = string.find(sret, "%(")
			sf = string.find(sret, ",")
			ip = string.sub(sret, si+1, sf-1)
			si = string.find(sret, ")")
			port = tonumber(string.sub(sret, sf+1, si-1))
		end
	end

	gsh.close(skey)

	return ip, port
end

--[[	RUNNING SERVER	]]
local clientSock
local bytes
local scmd

--request registration on the DNS
--checkNregister()
ip, port = findS("qpos")
print("echo ip: "..ip.." port: "..port)

while(true) do
	--receive the request from a new conection
	clientSock, scmd = srh.recv(clientSock, false, conf.proto, "127.0.0.1", 2323) --ip'n'port of the echo service, for testing proposes only

	--call invoker and return it's answere
	scmd = invok.invoker(scmd)
print("server vai retornar: "..scmd)
	clientSock, bytes = srh.send(scmd, clientSock)

	gsh.deactivate(clientSock)
end

gsh.close(clientSock)
clientSock = nil