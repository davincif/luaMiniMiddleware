--[[	CLIENT TO REQUEST HANDLER	]]
crh = {}
local socks = {}

math.randomseed(os.time())

--	GLOBAL FUNCTIONS	--
function crh.send(strmsg, proto, service, ip, port)
--[[
	parameters:
		strmsg - string to be sent over the net.
		proto - the protocol to be used.
		service - who is requesting this send? Since lua is dynamicly typed, service may be anything you want that identify who is asking this send
		ip - the ip to send the msg
		port - the port to send the msg
	return:
		on success a key (string) that uniquely identify who is asking this send, an empty string otherwise.
]]
	local clientsocket
	local bool
	local bytes
	local key

	if(type(proto) ~= "number") then
		error("LUA: crh.send 2st argument spected to be number but it's " .. type(proto))
	elseif(lsok.is_proto_valid(proto) == false) then
		error("LUA: in crh.send, protocol \"" .. proto .. "\" not recognized")
	elseif(type(strmsg) ~= "string") then
		error("LUA: crh.send 1st argument spected to be string but it's " .. type(strmsg))
	elseif(service == nil) then
		error("LUA: crh.send 3st argument cant not be nil!")
	elseif(type(ip) ~= "string") then
		error("LUA: crh.send 4st argument spected to be string but it's " .. type(ip))
	elseif(type(port) ~= "number") then
		error("LUA: crh.send 5st argument spected to be number but it's " .. type(port))
	else
		key = crh.getkey(service)
		if(key == "") then
			key = socks.create()
		end
		if(key ~= "") then
			if(proto == lsok.proto.tcp) then
				--[[	TCP		]]
				clientsocket = lsok.open(lsok.proto.tcp)
				if(clientsocket == 0) then
					print("LAU: Could not open socket")
					os.exit()
				end

				bool = lsok.connect(clientsocket, ip, port)
				if(bool == false) then
					print("LAU: Could not connect socket: ", clientsocket)
					os.exit()
				end

				bytes = lsok.send(clientsocket, strmsg)
			elseif(proto == lsok.proto.udp) then
				--[[	UDP		]]
				error("LUA: udp not implemented") --UDP NOT IMPLEMENTED
				clientsocket = lsok.open(lsok.proto.udp)
				if(clientsocket == 0) then
					print("LAU: Could not open socket")
					os.exit()
				end

				bool = lsok.bind(clientsocket, ip, port)
				if(bool == false) then
					print("LUA: Could not bind")
					os.exit()
				end


				bytes = lsok.send(clientsocket, strmsg, ip, port)
			end

			socks[key] = {}
			local taux = socks[key]
			taux.sock = clientsocket
			taux.proto = proto
			taux.service = service
			taux.openedAt = os.time()
			taux.lastUse = taux.openedAt
		end
	end

	return key
end

function crh.recv(key, flag)
--[[
	parameters:
		service - who had already requested a recv? and now whant to receive the return msg.
		flag - pas true to delete this socket after use if the service wont the socket anymore.
	return:
		on success the returned string, an empty string otherwise.
]]
	local socktable
	local sret

	if(key == nil or type(key) ~= "string") then
		sret = ""
		print("LUA: in crh.recv 1st argument must be a key string")
	elseif(socks[key] == nil) then
		sret = ""
		print("LUA: the given key does not exist")
	elseif((os.time() - socks[key].lastUse > conf.sockCautionTime) and (lsok.is_socket_open() == false)) then
		sret = ""
		print("LUA: socket \""..socks[key].sock.."\" was closed by the OS")
		socks[key] = nil
		--one day we will implement an automatically reopen of the socket
	else
		socktable = socks[key]
		if(socktable.proto == lsok.proto.tcp) then
			sret = lsok.recv(socktable.sock, lsok.proto.tcp)
		elseif(socktable.proto == lsok.proto.udp) then
			sret = lsok.recv(socktable.sock, lsok.proto.udp)
		end
		if(flag ~= nil and flag == true) then
			bool = lsok.close(socktable.sock)
			if(bool == false) then
				print("LAU: Could not close socket: ", socktable.sock)
			end
			socktable = nil
			socks[key] = nil
		else
			socktable.lastUse = os.time()
		end
	end

	return sret
end

function crh.getkey(service)
--[[
	parameters:
		service - the service that has already opened a socket that you wish to look for
	return:
		on success a key (string) that uniquely identify who is asking this send, an empty string otherwise.
]]
	local skey = ""

	for key,value in pairs(socks) do
		if(type(value) == "table" and type(socks[key].service) ~= nil and socks[key].service == service) then
			skey = key
		end
	end

	return skey
end

function crh.close(service)
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
		bool = lsok.close(socks[skey].sock)
		if(bool == false) then
			print("LAU: Could not close socket: ", socks[skey].sock)
		end
		socks[skey] = nil
	end

	return ok
end

--	LOCAL FUNCTIONS	--
function socks.create()
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
