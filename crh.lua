--[[	CLIENT TO REQUEST HANDLER	]]
require "socket"

crh = {}

math.randomseed(os.time())

--	GLOBAL FUNCTIONS	--
function crh.send(strmsg, key, proto, ip, port)
--[[
	parameters:
		strmsg - string to be sent over the net.
		key - the key to he socket to be used. Or nil if the sock was never created
		proto - the protocol to be used. (if key isn't nil, forget about this parameter)
		ip - the ip of this socket. (if key isn't nil, forget about this parameter)
		port - the port of this socket. (if key isn't nil, forget about this parameter)
	return:
		on success a key (string) that uniquely identify who is asking this send, an empty string otherwise.
]]
	local bytes
	local key

	--do not check all the parameters because the functions in socket.lua already do it

	if(key == nil) then
		key = gsh.create()
		gsh.set(proto, key, ip, port)
	elseif(gsh.isSetted(key) == false) then
		gsh.set(proto, key, ip, port)
	end

	if(gsh.isActive(key) == false and gsh.getProto(key) == lsok.proto.tcp) then
		gsh.connect(key, ip, port)
	end

	bytes = gsh.send(clientsocket, strmsg, ip, port)
	if(bytes <= 0) then
		print("LUA: bytes not sent")
	end

	return key
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

	return sret
end