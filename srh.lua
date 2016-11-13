--[[	SERVER TO REQUEST HANDLER	]]
require "invoker"
require "socket"

srh = {}
local STP = 100000 --STP (Sleep Time Pattern) --100000μs = 0,1s

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
		key - the key to the socket to be used. Or nil if the sock was never created
		flag - pas true to delete this socket after use if the service wont use the socket anymore.
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

-- FIND SERVICE --
local function findS()
--[[
	parameters:
		none
	return:
		none
]]
	local skey
	local si, sf
	local sret --string returned
	local bytes

	print("searching services on Queue Server...")
	for rkey,rval in pairs(regS) do
		skey, bytes = srh.send("SEARCH("..rkey..")", skey, conf.dnsIP, conf.dnsPort, {proto = conf.dnsProto})
		skey, sret = srh.recv(skey, false)
		if(sret == conf.dnsNotFound) then
			print("DNS returned error: "..sret)
			print("service \"" ..rkey.."\" not registrated at the DNS")
		else
			print("service \"" ..rkey.."\" on server: "..sret) --testline

			si = string.find(sret, "%(")
			sf = string.find(sret, ",")
			rval.QS_IP = string.sub(sret, si+1, sf-1)
			si = string.find(sret, ")")
			rval.QS_PORT = tonumber(string.sub(sret, sf+1, si-1))
			rval.reged = true
		end
	end

	gsh.close(skey)
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

	for rkey,rval in pairs(regS) do
		if(rval.reged == true) then
			--only open socket to those services who are registrated in the queue server
			rval.skey = gsh.create()
			boolret = gsh.set(rval.proto, rval.skey, rval.ip, rval.port)
			if(boolret == false) then
				print("could not set socktable of service \""..rkey.."\"")
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

findS()
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
			scmd = invok.invoker(scmd)
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
