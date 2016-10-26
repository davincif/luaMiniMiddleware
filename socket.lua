--[[	GENERIC SOCKET HANDLER	]]
gsh = {}
local socks = {}
--[[
socks[key] = {}
socks[key].mysock = socket created when lsok.open() is called
if(proto == lsok.proto.tcp) then
	--socks[key].csock = future client sock
	socks[key].active = false --says if this socket already was accept, ou connecto to another one.
end
socks[key].proto = tcp ou udp ~up to now~
socks[key].openedAt = os.time()
socks[key].lastUse = socks[key].openedAt
]]

math.randomseed(os.time())


--	GLOBAL FUNCTIONS	--
function gsh.set(proto, key, ip, port)
--[[
	parameters:
		proto - the protocol to be used.
		key - the key to an valid already created socket
		ip - the ip to bind the socket
		port - the port to bind the socket
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
	elseif(type(ip) ~= "string") then
		error("LUA: gsh.set 4st argument spected to be string but it's " .. type(ip))
	elseif(type(port) ~= "number") then
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

			bool = lsok.bind(mysocket, ip, port)
			if(bool == false) then
				error("LUA: Could not bind")
			end

			bool = lsok.listen(mysocket)
			if(bool == false) then
				error("LUA: Could not listen")
			end
		elseif(proto == lsok.proto.udp) then
			--[[	UDP		]]
			mysocket = lsok.open(lsok.proto.udp)
			if(mysocket == 0) then
				error("LUA: Could not open socket")
			end

			bool = lsok.bind(mysocket, ip, port)
			if(bool == false) then
				error("LUA: Could not bind")
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
		true on success, false otherwise
]]
	local ok

	if(type(key) ~= "string") then
		error("LUA: gsh.accept 1st argument spected to be string but it's " .. type(key))
	elseif(socks[key] == nil or type(socks[key]) ~= "table") then
		error("LUA: gsh.accept the given key is not valid, \"key\" is "..type(socks[key]))
	elseif(socks[key].mysock == nil) then
		error("LUA: the socket needs to be set first")
	else
		ok = true
		socks[key].csock = lsok.accept(socks[key].mysock)
		if(socks[key].csock == -1) then
			error("LUA: gsh.accept, could not accept connection")
		end
		socks[key].active = true
	end

	return ok
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
	else
		ok = true
		if(lsok.connect(socks[key].mysock, ip, port) == false) then
			error("LAU: Could not connect socket")
		end
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

	PS.: to save time, this function will not check if the socket is correctly setted, so, be sure of if before trying to send
]]
	local sret

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
			sret = lsok.recv(socks[key].mysock, socks[key].proto)
		end

		if(flag ~= nil and flag == true) then
			gsh.close(key)
		else
			socks[key].lastUse = os.time()
		end
	end

	return sret
end

function gsh.send(strmsg, key, flag, ip, port)
--[[
	parameters:
		service - who had already requested a send? and now whant to receive the return msg.
		key - the key to an valid already created, setted and accepted/connect socket
		flag - pas true to delete this socket after use, false other while (or leave it nil!!)
		ip - if you're using a udp, you must pass the ip to send the msg. ignore it if you're use tcp
		port - if you're using a udp, you must pass the port to send the msg. ignore it if you're use tcp
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
		error("LUA: gsh.set the given key does not exist")
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
		error("LUA: gsh.accept 1st argument spected to be string but it's " .. type(key))
	elseif(socks[key] == nil or type(socks[key]) ~= "table") then
		error("LUA: gsh.close the given key is not valid, \"key\" is "..type(socks[key]))
	else
		bool = lsok.close(socks[key].mysock)
		if(bool == false) then
			print("LUA: Could not close socket: "..socks[key].mysock.." on key: "..key)
		end
		if(socks[key].csock ~= nil) then
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
			if(value.csock ~= nil) then
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

function gsh.isActive(key)
--[[
	parameters:
		key - the key to an valid already created socket
	return:
		true if the socket was already binded or accepted, false otherwise
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
]]
	local ret

	if(type(key) ~= "string") then
		error("LUA: gsh.isActive 1st argument spected to be string but it's " .. type(key))
	end

	if(socks[key] == nil or type(socks[key]) ~= "table") then
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