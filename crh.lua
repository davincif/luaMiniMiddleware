--[[	CLIENT TO REQUEST HANDLER	]]
require "socket"

crh = {}


--	GLOBAL FUNCTIONS	--
function crh.send(strmsg, key, ip, port, socktable)
--[[
	parameters:
		strmsg - string to be sent over the net.
		key - the key to he socket to be used. Or nil if the sock was never created
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

function crh.recv(key, flag, proto, ip, port)
--[[
	parameters:
		flag - pas true to delete this socket after use if the service wont the socket anymore.
		key - the key to he socket to be used. Or nil if the sock was never created
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