--[[	GENERIC SOCKET HANDLER	]]
gsh = {}
local socks = {}
--[[
socks[key] = {}
socks[key].mysock = socket created when lsok.open() is called
if(proto == lsok.proto.tcp) then
	--socks[key].csock = future client sock, or mysock if you're the client
	socks[key].active = false --says if this socket already was accept, ou connecto to another one.
end
socks[key].ip = ip of the client who sent the last msg to this socket
socks[key].port = port of the client who sent the last msg to this socket
socks[key].proto = tcp ou udp ~up to now~
socks[key].openedAt = os.time()
socks[key].lastUse = socks[key].openedAt
]]

math.randomseed(os.time())


--	GLOBAL FUNCTIONS	--
function gsh.set(proto, key, ip, port, onlyOpen)
--[[
	parameters:
		proto - the protocol to be used.
		key - the key to an valid already created socket
		ip - the ip to bind the socket if needed. (typically on server), nil otherwise
		port - the port to bind the socket if needed. (typically on server), nil otherwise
		onlyOpen - true if you want only open the socket, without binding ou listening (typically in client).false ou just forget for the main behavior
	return:
		true on success, false otherwise
]]
	local mysocket
	local bool
	local bytes
	local ok = false

	if(type(proto) ~= "number") then
		error("gsh.set 1st argument spected to be number but it's " .. type(proto))
	elseif(lsok.is_proto_valid(proto) == false) then
		error("in gsh.set, protocol \"" .. proto .. "\" not recognized")
	elseif(onlyOpen ~= true and type(ip) ~= "string") then
		error("LUA: gsh.set 4st argument spected to be string but it's " .. type(ip))
	elseif(onlyOpen ~= true and type(port) ~= "number") then
		error("LUA: gsh.set 5st argument spected to be number but it's " .. type(port))
	elseif(type(key) ~= "string") then
		error("LUA: gsh.set 2st argument spected to be string but it's " .. type(key))
	elseif(socks[key] == nil or type(socks[key]) ~= "table") then
		error("LUA: gsh.set the given key is not valid, key is "..type(socks[key]))
	else
		ok = true
		if(proto == lsok.proto.tcp) then
			--[[	TCP		]]
			mysocket = lsok.open(lsok.proto.tcp)
			if(mysocket == 0) then
				error("LUA: Could not open socket")
			end

			if(onlyOpen ~= true) then
				bool = lsok.bind(mysocket, ip, port)
				if(bool == false) then
					error("LUA: Could not bind")
				end

				bool = lsok.listen(mysocket)
				if(bool == false) then
					error("LUA: Could not listen")
				end
			end
		elseif(proto == lsok.proto.udp) then
			--[[	UDP		]]
			mysocket = lsok.open(lsok.proto.udp)
			if(mysocket == 0) then
				error("LUA: Could not open socket")
			end

			if(onlyOpen ~= true) then
				bool = lsok.bind(mysocket, ip, port)
				if(bool == false) then
					error("LUA: Could not bind")
				end
			end
		end

		socks[key] = {}
		local taux = socks[key]
		taux.mysock = mysocket
		if(proto == lsok.proto.tcp) then
			taux.active = false --says if this socket already was accept, ou connecto to another one.
		end
		taux.proto = proto
		taux.openedAt = os.time()
		taux.lastUse = taux.openedAt
	end

	return ok	
end

function gsh.accept(key)
--[[
	parameters:
		key - the key to an valid already created socket
	return:
		on success: true and the ip and port of who hand connected, false nil nil otherwise
]]
	local ok
	local ip
	local port

	if(type(key) ~= "string") then
		error("LUA: gsh.accept 1st argument spected to be string but it's " .. type(key))
	elseif(socks[key] == nil or type(socks[key]) ~= "table") then
		error("LUA: gsh.accept the given key is not valid, \"key\" is "..type(socks[key]))
	elseif(socks[key].mysock == nil) then
		error("LUA: the socket needs to be set first")
	else
		ok = true
		socks[key].csock, ip, port = lsok.accept(socks[key].mysock)
		if(socks[key].csock == -1) then
			error("LUA: gsh.accept, could not accept connection")
		end
		socks[key].active = true
	end

	return ok, ip, port
end

function gsh.connect(key, ip, port)
--[[
	parameters:
		key - the key to an valid already created socket
		ip - the ip to connected
		port the port to be connected
	return:
		true on success, false otherwise
]]
	local ok

	if(type(key) ~= "string") then
		error("LUA: gsh.connect 1st argument spected to be string but it's " .. type(key))
	elseif(socks[key] == nil or type(socks[key]) ~= "table") then
		error("LUA: gsh.connect the given key is not valid, \"key\" is "..type(socks[key]))
	elseif(socks[key].proto ~= lsok.proto.tcp) then
		print("LUA: only tcp protocol needs to connect")
		ok = false
	elseif(type(ip) ~= "string") then
		error("LUA: gsh.connect, 2nd argument should be string, but it's "..type(ip))
	elseif(type(port) ~= "number") then
		error("LUA: gsh.connect, 3rd argument should be number, but it's "..type(port))
	else
		ok = true
		if(lsok.connect(socks[key].mysock, ip, port) == false) then
			error("LAU: Could not connect socket")
		end
		socks[key].csock = socks[key].mysock
		socks[key].active = true
	end

	return ok
end

function gsh.recv(key, flag)
--[[
	parameters:
		key - the key to an valid already created, setted and accepted/connect socket
		flag - pas true to delete this socket after use, false other while (or leave it nil!!)
	return:
		msg - the msg (string) sent by the client, or an empty string if there is any error
		changed - in case your socket is udp, changed will be true if ip or port of the cliend has changed

	PS.: to save time, this function will not check if the socket is correctly setted, so, be sure of if before trying to send
]]
	local sret
	local ip
	local port
	local changed

	if(type(key) ~= "string") then
		error("LUA: gsh.recv 1st argument spected to be string but it's " .. type(key))
	elseif(socks[key] == nil or type(socks[key]) ~= "table") then
		error("LUA: gsh.recv the given key is not valid, \"key\" is "..type(socks[key]))
	else
		if(socks[key].proto == lsok.proto.tcp) then
			--[[	TCP		]]
			sret = lsok.recv(socks[key].csock, socks[key].proto)
		elseif(socks[key].proto == lsok.proto.udp) then
			--[[	UDP		]]
			sret, ip, port = lsok.recv(socks[key].mysock, socks[key].proto)
			if(ip ~= socks[key].ip or port ~= socks[key].port) then
				socks[key].ip = ip
				socks[key].port = port
				changed = true
			else
				changed = false
			end
		end

		if(flag ~= nil and flag == true) then
			gsh.close(key)
		else
			socks[key].lastUse = os.time()
		end
	end

	return sret, changed
end

function gsh.send(strmsg, key, flag, ip, port)
--[[
	parameters:
		service - who had already requested a send? and now whant to receive the return msg.
		key - the key to an valid already created, setted and accepted/connect socket
		flag - pas true to delete this socket after use, false other while (or leave it nil!!)
		ip - if you're using a udp, you must pass the ip to send the msg just in the frist time. ignore it if you're use tcp
		port - if you're using a udp, you must pass the port to send the msg just in the frist time. ignore it if you're use tcp
		PS.: when using udp, never ignore the "flag", put it false, if you do not want to use it.
	return:
		on success returns the number of bytes sent, -1 ou 0 otherwise.

	PS.: to save time, this function will not check if the socket is correctly setted, so, be sure of if before trying to send
]]
	local bool
	local bytes

	if(type(strmsg) ~= "string") then
		error("LUA: in gsh.send 1st argument must be string, but it's "..type(strmsg))
	elseif(key == nil or type(key) ~= "string") then
		error("LUA: in gsh.send 2nd argument must be a key string, but it's "..type(key))
	elseif(socks[key] == nil) then
		error("LUA: gsh.send the given key does not exist")
	elseif((os.time() - socks[key].lastUse > conf.sockCautionTime) and (lsok.is_socket_open() == false)) then
		bytes = -1
		print("LUA: socket \""..socks[key].sock.."\" was closed by the OS")
		socks[key] = nil
		--one day we will implement an automatically reopen of the socket
	elseif(flag ~= nil and type(flag) ~= "boolean") then
		error("LUA: in gsh.send ignore the 3nd argument, or is must be boolean, got "..type(flag))
	elseif(ip ~= nil and type(ip) ~= "string") then
		error("LUA: in gsh.send ignore the 4th argument, or is must be string, got "..type(ip))
	elseif(port ~= nil and type(port) ~= "number") then
		error("LUA: in gsh.send ignore the 5th argument, or is must be number, got "..type(port))
	else
		if(socks[key].proto == lsok.proto.tcp) then
			bytes = lsok.send(socks[key].csock, strmsg)
		elseif(socks[key].proto == lsok.proto.udp) then
			if(ip == nil and port == nil) then
				ip = socks[key].ip
				port = socks[key].port
			else
				socks[key].ip = ip
				socks[key].port = port
			end
			bytes = lsok.send(socks[key].mysock, strmsg, ip, port)
		end

		if(flag ~= nil and flag == true) then
			gsh.close(key)
		else
			socks[key].lastUse = os.time()
		end
	end

	return bytes
end

function gsh.create()
--[[
	parameters:
		none
	return:
		on success a key (string) that uniquely identify who is asking this send, an empty string otherwise.
]]
	local key
	local count = 0

	key = math.random(conf.sockMax)
	while(socks[tostring(key)] ~= nil and count <= conf.sockMax) do
		key = key + 1
		if(key > conf.sockMax) then
			key = 1
		end
		count = count + 1
	end

	if(count > conf.sockMax) then
		--to many sockets opened
		key = ""
		print("LUA: cant open a new socket. There's already too many")
	else
		key = tostring(key)
	end

	socks[key] = {}

	return key
end

function gsh.close(key)
--[[
	parameters:
		key - the key to an valid already created socket
	return:
		true on success, false otherwise.
]]
	local bool

	if(type(key) ~= "string") then
		error("LUA: gsh.close 1st argument spected to be string but it's " .. type(key))
	elseif(socks[key] == nil or type(socks[key]) ~= "table") then
		error("LUA: gsh.close the given key is not valid, \"key\" is "..type(socks[key]))
	else
		bool = lsok.close(socks[key].mysock)
		if(bool == false) then
			print("LUA: Could not close socket: "..socks[key].mysock.." on key: "..key)
		end
		if(socks[key].csock ~= nil and socks[key].csock ~= socks[key].mysock) then
			bool = lsok.close(socks[key].csock)
			if(bool == false) then
				print("LUA: Could not close socket: "..socks[key].csock.." on key: "..key)
			end
		end
		socks[key] = nil
	end

	return bool
end

function gsh.closeAll()
--[[
	parameters:
		none
	return:
		true on success, false otherwise.
]]
	local bool

	for key,value in pairs(socks) do
		if(type(value) == "table") then
			bool = lsok.close(value.mysock)
			if(bool == false) then
				print("LUA: Could not close socket: "..value.mysock.." on key: "..key)
				break
			end
			if(value.csock ~= nil and value.csock ~= value.mysock) then
				bool = lsok.close(value.csock)
				if(bool == false) then
					print("LUA: Could not close socket: "..value.csock.." on key: "..key)
					break
				end
			end
			socks[key] = nil
		end
	end

	return bool
end

function gsh.is_readable(socketTable)
--[[
	parameters:
		keys like this: gsh.is_readable({[1] = key1, [2] = key2, ...})
	return:
		table with the socks who are receiving data like {[1] = socket2, [2] = socket4};
		nil if none of them are is_readable to be read;
		or a integer if any error has ocurred
]]
	local targ = {}
	local wr
	local ret

	for _, stv in pairs(socketTable) do
		if(socks[stv].proto == lsok.proto.tcp) then
			table.insert(targ, socks[stv].csock)
		else
			table.insert(targ, socks[stv].mysock)
		end
	end

	wr = lsok.select(#targ, targ)

	if(wr ~= nil) then
		ret = {}
		for _, stv in pairs(socketTable) do
			for _, wrvalue in pairs(wr) do
				if(socks[stv].proto == lsok.proto.udp) then
					if(wrvalue == socks[stv].mysock) then
						table.insert(ret, stv)
					end
				else
					if(wrvalue == socks[stv].csock) then
						table.insert(ret, stv)
					end
				end
			end
		end
	end

	return ret
end

function gsh.is_acceptable(socketTable)
--[[
	parameters:
		keys like this: gsh.is_readable({[1] = key1, [2] = key2, ...})
	return:
		table with the socks who are receiving data like {[1] = socket2, [2] = socket4};
		nil if none of them are is_readable to be read;
		or a integer if any error has ocurred
	PS.: if the given socket is upd, this function only waste process time!
]]
	local targ = {}
	local wr
	local ret

	for _, stv in pairs(socketTable) do
		if(socks[stv].proto == lsok.proto.tcp) then
			table.insert(targ, socks[stv].mysock)
		end
	end

	wr = lsok.select(#targ, targ)

	if(wr ~= nil) then
		ret = {}
		for _, stv in pairs(socketTable) do
			for _, wrvalue in pairs(wr) do
				if(socks[stv].proto == lsok.proto.tcp and wrvalue == socks[stv].mysock) then
					table.insert(ret, stv)
				end
			end
		end
	end

	return ret
end



--	GET FUNCTIONS	--
function gsh.getProto(key)
--[[
	parameters:
		key - the key to an valid already created socket
	return:
		the proto of the given socket[key] on success, nil otherwise
]]
	local ret

	if(type(key) ~= "string") then
		error("LUA: gsh.getProto 1st argument spected to be string but it's " .. type(key))
	end

	if(socks[key] == nil or type(socks[key]) ~= "table") then
		ret = nil
	else
		ret = socks[key].proto
	end

	return ret
end

function gsh.getIpPort(key)
--[[
	parameters:
		key - the key to an valid already created socket
	return:
		the ip and port of the last communication made with this socket on success, nil if socks[key] does not exist or if the socket had never been connected
]]
	local ip
	local port

	if(type(key) ~= "string") then
		error("LUA: gsh.getIpPort 1st argument spected to be string but it's " .. type(key))
	end

	if(socks[key] == nil or type(socks[key]) ~= "table") then
		ip = nil
		port = nil
	else
		ip = socks[key].ip
		port = socks[key].port
	end

	return ip, port
end

function gsh.isActive(key)
--[[
	parameters:
		key - the key to an valid already created socket
	return:
		true if the socket was already binded or accepted, false if not
		nil if the socket isn't working on tcp
]]
	local ret

	if(type(key) ~= "string") then
		error("LUA: gsh.isActive 1st argument spected to be string but it's " .. type(key))
	end

	if(socks[key] == nil or type(socks[key]) ~= "table") then
		ret = false
	else
		ret = socks[key].active
	end

	return ret
end

function gsh.isSetted(key)
--[[
	parameters:
		key - the key to an valid already created socket
	return:
		true if the socket was already setted, false otherwise
		OBS.: once active is a characteristic related to tcp sockets, if the socket is udp, this functions returns nil!
]]
	local ret

	if(type(key) ~= "string") then
		error("LUA: gsh.isActive 1st argument spected to be string but it's " .. type(key))
	end

	if(socks[key].proto == lsok.proto.udp) then
		ret = nil
	elseif(socks[key] == nil or type(socks[key]) ~= "table") then
		ret = false
	else
		if(socks[key].mysock == nil) then
			ret = false
		else
			ret = true
		end
	end

	return ret
end

function gsh.deactivate(key)
--[[
	parameters:
		key - the key to an valid already created socket
	return:
		true in success, false if the socket is alredy not activated
		nil if it does not exist or if the socket isn't working on tcp
]]
	local ret

	if(type(key) ~= "string") then
		error("LUA: gsh.isActive 1st argument spected to be string but it's " .. type(key))
	end

	if(socks[key] == nil or type(socks[key]) ~= "table" or socks[key].proto ~= lsok.proto.tcp) then
		ret = nil
	elseif(socks[key].active == false) then
		ret = false
	else
		ret = true
		socks[key].active = false
	end

	return ret
end


function gsh.getsockname(key)
	local ip
	local port

 	if(type(key) ~= "string") then
		error("LUA: gsh.getsockname 1st argument spected to be string but it's " .. type(key))
	elseif(socks[key] == nil or type(socks[key]) ~= "table") then
		error("LUA: gsh.getsockname the given socket does not exist")
	end

	if(socks[key].proto ~= lsok.proto.tcp) then
		print("LUA: gsh.getsockname this fucntion works only in tcp sockets")
	else
		ip, port = lsok.getsockname(socks[key].mysock)
	end

	return ip, port
 end

 function gsh.getclientsockname(key)
	local ip
	local port

 	if(type(key) ~= "string") then
		error("LUA: gsh.getclientsockname 1st argument spected to be string but it's " .. type(key))
	elseif(socks[key] == nil or type(socks[key]) ~= "table") then
		error("LUA: gsh.getclientsockname the given socket does not exist")
	end

	if(socks[key].proto ~= lsok.proto.tcp) then
		print("LUA: gsh.getclientsockname this fucntion works only in tcp sockets")
	else
		if(socks[key].csock ~= nil and socks[key].csock ~= 0) then
			ip, port = lsok.getsockname(socks[key].csock)
		end
	end

	return ip, port
 end
