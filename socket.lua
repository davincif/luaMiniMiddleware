--[[	GENERIC SOCKET HANDLER	]]
gsh = {}
local socks = {}

math.randomseed(os.time())


--	GLOBAL FUNCTIONS	--
function gsh.setsock(proto, key, ip, port)
--[[
	parameters:
		proto - the protocol to be used.
		key - the key to an valid already created socket
		ip - the ip to bind the socket
		port - the port to bind the socket
	return:
		key - on success a key (string) that uniquely identify who is asking this send, an empty string otherwise.
]]
	local sret
	local mysocket
	local bool
	local bytes
	local key
	local sret

	if(type(proto) ~= "number") then
		error("gsh.setsock 1st argument spected to be number but it's " .. type(proto))
	elseif(lsok.is_proto_valid(proto) == false) then
		error("in gsh.setsock, protocol \"" .. proto .. "\" not recognized")
	elseif(type(ip) ~= "string") then
		error("LUA: gsh.setsock 4st argument spected to be string but it's " .. type(ip))
	elseif(type(port) ~= "number") then
		error("LUA: gsh.setsock 5st argument spected to be number but it's " .. type(port))
	else if(type(key) ~= "string") then
		error("LUA: gsh.setsock 2st argument spected to be string but it's " .. type(key))
	else if(socks[key] == nil or type(socks[key]) ~= "table") then
		error("LUA: the given key is not valid, socks["..key.."] is "..type(socks[key]))
	else
		if(key ~= "") then
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
				--taux.csock = future client sock
				taux.ip = ip
				taux.port = port
			end
			taux.proto = proto
			taux.openedAt = os.time()
			taux.lastUse = taux.openedAt
		end
	end

	return key	
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
	else if(socks[key] == nil or type(socks[key]) ~= "table") then
		error("LUA: the given key is not valid, socks["..key.."] is "..type(socks[key]))
	else if(socks[key].proto ~= lsok.proto.tcp) then
		print("LUA: only tcp protocol needs to accept")
		ok = false
	else if(socks[key].mysock ~= nil) then
		error("LUA: the socket needs to be set first")
	else
		ok = true
		socks[key].csock = lsok.accept(socks[key].mysock)
		if(socks[key].csock == -1) then
			error("LUA: gsh.accept, could not accept connection")
		end
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
	else if(socks[key] == nil or type(socks[key]) ~= "table") then
		error("LUA: the given key is not valid, socks["..key.."] is "..type(socks[key]))
	else if(socks[key].proto ~= lsok.proto.tcp) then
		print("LUA: only tcp protocol needs to connect")
		ok = false
	else
		ok = true
		if(lsok.connect(socks[key].mysock, ip, port) == false) then
			error("LAU: Could not connect socket")
		end
	end

	return ok
end

function gsh.recv(key)
--[[
	parameters:
		proto - the protocol to be used.
		service - who is requesting this recv? Since lua is dynamicly typed, service may be anything you want that identify who is asking this recv
		ip - the ip to bind the socket
		port - the port to bind the socket
	return:
		key - on success a key (string) that uniquely identify who is asking this send, an empty string otherwise.
		msg - the msg (string) sent by the client, or an empty string if there is any error
]]
	local sret

	if(key == nil or type(key) ~= "string") then
		error("LUA: in gsh.recv 2st argument must be a key string, but it's "..type(key))
	elseif(socks[key] == nil) then
		error("in gsh.recv, protocol \"" .. proto .. "\" not recognized")
	else
		if(socks[key].proto == lsok.proto.tcp) then
			--[[	TCP		]]
			if(socks[key].csock == nil) then
				socks[key].csock = lsok.accept(socks[key].mysock)
				if(socks[key].csock == -1) then
					error("LUA: gsh.recv, could not accept connection")
				end
			end
			sret = lsok.recv(socks[key].csock, socks[key].proto)
		elseif(socks[key].proto == lsok.proto.udp) then
			--[[	UDP		]]
			sret = lsok.recv(socks[key].socks, socks[key].proto)
		end
	end

	return sret
end

function gsh.send(strmsg, key, flag)
--[[
	parameters:
		service - who had already requested a send? and now whant to receive the return msg.
		flag - pas true to delete this socket after use if the service wont the socket anymore.
	return:
		on success returns true, false otherwise.
]]
	local socktable
	local bret
	local bool
	local bytes

	if(type(strmsg) ~= "string") then
		error("LUA: in gsh.send 1st argument must be string, but it's "..type(strmsg))
	elseif(key == nil or type(key) ~= "string") then
		error("LUA: in gsh.send 2st argument must be a key string, but it's "..type(key))
	elseif(socks[key] == nil) then
		error("LUA: the given key does not exist")
	elseif((os.time() - socks[key].lastUse > conf.sockCautionTime) and (lsok.is_socket_open() == false)) then
		bret = false
		print("LUA: socket \""..socks[key].sock.."\" was closed by the OS")
		socks[key] = nil
		--one day we will implement an automatically reopen of the socket
	elseif(flag == nil) then
		error("LUA: in gsh.send 3st argument must not be nil")
	else
		bret = true
		socktable = socks[key]
		if(socktable.proto == lsok.proto.tcp) then
			bytes = lsok.send(socktable.csock, strmsg)
		elseif(socktable.proto == lsok.proto.udp) then
			error("LUA: UDP not implemented") --UDP NOT IMPLEMENTED YET
			bytes = lsok.send(socktable.mysock, strmsg, socktable.ip, socktable.port)
		end

		if(flag ~= nil and flag == false) then
			bool = lsok.close(socktable.mysock)
			if(bool == false) then
				print("LUA: Could not close socket: ", serversocket)
			end
			if(socktable.csock ~= nil) then
				bool = lsok.close(socktable.csock)
				if(bool == false) then
					print("LUA: Could not close socket: ", clientsocket)
				end
			end
			socktable = nil
			socks[key] = nil
		else
			socktable.lastUse = os.time()
		end
	end

	return bret
end

function gsh.getkey(service)
--[[
	parameters:
		service - the service that has already opened a socket that you wish to look for
	return:
		on success a key (string) that uniquely identify who is asking this send, an empty string otherwise.
]]
	local skey = ""

	for key,value in pairs(socks) do
		if(type(value) == "table" and type(value.service) ~= nil and value.service == service) then
			skey = key
		end
	end

	return skey
end

function gsh.close(service)
--[[
	parameters:
		service - the service whose socket shall be closed
	return:
		on success the return true, false otherwise.
]]
	local ok = false
	local skey
	local bool

	for key,value in pairs(socks) do
		if(type(value) == "table" and type(value.service) ~= nil and value.service == service) then
			ok = true
			skey = key
		end
	end

	if(ok == false) then
		print("LUA: no socket found to this service")
	else
		bool = lsok.close(socks[skey].mysock)
		if(bool == false) then
			print("LAU: Could not close socket: ", socks[skey].mysock)
		end
		if(socks[skey].csock ~= nil) then
			bool = lsok.close(socks[skey].csock)
			if(bool == false) then
				print("LAU: Could not close socket: ", socks[skey].csock)
			end
		end
		socks[skey] = nil
	end

	return ok
end


--	LOCAL FUNCTIONS	--
function gsh.create()
--[[
	parameters:
		any
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

	return key
end

--[[	RUNNING SERVER	]]
local sockgate
local scmd --scmd = string command

regT.checkRegistration()

sockgate = gsh.setsock(conf.proto, "watcher", SERVER_IP, 2323)
scmd  = gsh.recv(sockgate) --socket where the requisition will get from client

if(sockgate == "") then
	print("LUA: gsh.lua could'n create the listener socket")
	os.exit()
end

gsh.send(invok.invoker(scmd), sockgate, true) --tcp