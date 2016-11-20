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
local function checkNregister()
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

		if(ret == conf.ok) then
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
			if(rval.skey == nil) then
				rval.skey = gsh.create()
				boolret = gsh.set(rval.proto, rval.skey, rval.ip, rval.port)
				if(boolret == false) then
					print("could not set socktable of queue service \""..rkey.."\"")
					os.exit()
				end
			end
			table.insert(tret, rval.skey)
		end
	end

	return tret
end

local function FindServiceBySock(sock)
--[[
	parameters:
	return:
]]
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
		conf.print("accept request identified")
		for key, value in pairs(taux) do
			gsh.accept(value)
			worked = true
		end
		opensockets()
	end

	taux = gsh.is_readable(keyt)
	if(taux ~= nil) then
		conf.print("identified msg waiting")
		for key, value in pairs(taux) do
			local ignore
			ignore, scmd = qsrh.recv(value, false, conf.proto, taux.ip, taux.port)
			--[[ BUG NOTE
				Note that when the QS receives a msg, it'll do so by the csock socket within skey "value"
				it's a ruge problem once whe whant to keep a long data exchange, 'cause each new client
				will rewrite the socket of the last one. A way to around this is manteining a table of client,
				but mechanisms gotta be craeted to deal with it.
				For now, my guess is the the software will still work with this bug, but in a constate state of failure ^^"
			]]
			--call invoker and return it's answere
print("ignore, scmd", ignore, scmd)
			if(scmd ~= nil) then
				scmd = qsinvok.invoker(scmd)
				print("server will answer: "..scmd)
				ignore, bytes = qsrh.send(scmd, value)
				worked = true
			end
			-- if client wants to end connection
			if(scmd == conf.close) then
				gsh.deactivate(ignore) --deactive for revoke only
			end
			worked = true
		end
	end

	--qsinvok.QS_update()

	if(worked == false) then
		lsok.sleep(STP)
	end
end

gsh.closeAll()
