--[[	SERVER TO REQUEST HANDLER	]]
require "dns"
require "socket"

drh = {}

--	GLOBAL FUNCTIONS	--
function drh.send(strmsg, key, proto, ip, port)
--[[
	parameters:
		strmsg - string to be sent over the net.
		key - the key to he socket to be used. Or nil if the sock was never created
		proto - the protocol to be used. (if key isn't nil, forget about this parameter)
		ip - the ip of this socket. (if key isn't nil, forget about this parameter)
		port - the port of this socket. (if key isn't nil, forget about this parameter)
	return:
		on success a key (string) that uniquely identify who is asking this send, an empty string otherwise.
		a numer with the amount of bytes sent
]]
	local bytes

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

	bytes = gsh.send(strmsg, key)
	if(bytes <= 0) then
		print("LUA: bytes not sent")
	end

	return key, bytes
end

function drh.recv(key, flag, proto, ip, port)
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


--[[	RUNNING SERVER	]]

local sockgate
local scmd --scmd = string command

while(true) do
	local si
	local sf
	local cmd --command
	local service
	local ip
	local port

	--receive the request from a new conection
	if(sockgate == nil) then
		sockgate, scmd = drh.recv(nil, false, conf.dnsProto, conf.dnsIP, conf.dnsPort)
	else
		sockgate, scmd = drh.recv(sockgate, false)
	end
	print("command recreived: "..scmd)

	--process the request
	si = string.find(scmd, "%(")
	cmd = string.lower(string.sub(scmd, 1, si-1))
	if(cmd == "add") then
		local asnwere

		sf = string.find(scmd, ",")
		service = string.lower(string.sub(scmd, si+1, sf-1))
		si = string.find(scmd, ",", sf+1)
		ip =string.sub(scmd, sf+1, si-1)
		sf = string.find(scmd, ")", si+1)
		port = tonumber(string.sub(scmd, si+1, sf-1))
		print("processed as: (service, ip, port) ".."-> ("..service..","..ip..","..port..")")

		--call the corrent function
		asnwere = dns.add(service, ip, port)

		--send back the correct asnwere
		drh.send(asnwere, sockgate)
	elseif(cmd == "search") then
		sf = string.find(scmd, ")")
		service = string.lower(string.sub(scmd, si+1, sf-1))
		print("processed as: (service)", "("..service..")")

		--call the corrent function
		ip, port = dns.search(service)

		--send back the correct asnwere
		drh.send("("..ip..","..tostring(port)..")", sockgate)
	end
end

--close the current conection
gsh.close(sockgate)
sockgate = nil
