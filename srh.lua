--[[	SERVER TO REQUEST HANDLER	]]
require "invoker"

srh = {}
local socks = {}

socks.max = 100 --max of socket that may be opened at the same time
socks.cautionTime = 2 --if a socket spent more than this time without being used, be cautious

math.randomseed(os.time())


--	GLOBAL FUNCTIONS	--
function srh.recv(proto, service)
--[[
	parameters:
		proto - the protocol to be used.
		service - who is requesting this recv? Since lua is dynamicly typed, service may be anything you want that identify who is asking this recv
	return:
		key - on success a key (string) that uniquely identify who is asking this send, an empty string otherwise.
		msg - the msg (string) sent by the client, or an empty string if there is any error
]]
	local sret
	local serversocket
	local clientsocket
	local bool
	local bytes
	local key
	local sret

	if(type(proto) ~= "number") then
		key = ""
		sret = ""
		print("srh.recv 1st argument spected to be number but it's " .. type(proto))
	elseif(lsok.is_proto_valid(proto) == false) then
		key = ""
		sret = ""
		print("in srh.recv, protocol \"" .. proto .. "\" not recognized")
	else
		key = srh.getkey(service)
		if(key == "") then
			key = socks.create()
		end
		if(key ~= "") then
			if(proto == lsok.proto.tcp) then
				--[[	TCP		]]
				serversocket = lsok.open(lsok.proto.tcp)
				if(serversocket == 0) then
					print("LUA: Could not open socket")
					os.exit()
				end

				bool = lsok.bind(serversocket, "127.0.0.1", 2323)
				if(bool == false) then
					print("LUA: Could bind")
					os.exit()
				end

				bool = lsok.listen(serversocket)
				if(bool == false) then
					os.exit()
				end

				clientsocket = lsok.accept(serversocket)
				if(clientsocket == -1) then
					os.exit()
				end

				sret = lsok.recv(clientsocket, lsok.proto.tcp)
			elseif(proto == lsok.proto.udp) then
				--[[	UDP		]]
				serversocket = lsok.open(lsok.proto.udp)
				if(serversocket == 0) then
					print("LUA: Could not open socket")
					os.exit()
				end

				bool = lsok.bind(serversocket, "127.0.0.1", 2323)
				if(bool == false) then
					print("LUA: Could not bind")
					os.exit()
				end

				sret = lsok.recv(serversocket, lsok.proto.udp)
			end

			socks[key] = {}
			local taux = socks[key]
			taux.ssock = serversocket
			if(proto == lsok.proto.tcp) then
				taux.csock = clientsocket
			end
			taux.proto = proto
			taux.service = service
			taux.openedAt = os.time()
			taux.lastUse = taux.openedAt
		end
	end

	return key, sret
end

function srh.send(strmsg, key, flag)
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
		bret = false
		print("LUA: in srh.recv 1st argument must be a key string, but it's "..type(key))
	elseif(key == nil or type(key) ~= "string") then
		bret = false
		print("LUA: in srh.recv 2st argument must be a key string, but it's "..type(key))
	elseif(socks[key] == nil) then
		bret = false
		print("LUA: the given key does not exist")
	elseif((os.time() - socks[key].lastUse > socks.cautionTime) and (lsok.is_socket_open() == false)) then
		bret = false
		print("LUA: socket \""..socks[key].sock.."\" was closed by the OS")
		socks[key] = nil
		--one day we will implement an automatically reopen of the socket
	else
		bret = true
		socktable = socks[key]
		if(socktable.proto == lsok.proto.tcp) then
			bytes = lsok.send(socktable.csock, strmsg)
		elseif(socktable.proto == lsok.proto.udp) then
			bytes = lsok.send(socktable.ssock, strmsg, "127.0.0.1", 3232)
		end

		if(flag ~= nil and flag == false) then
			bool = lsok.close(socktable.ssock)
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

function srh.getkey(service)
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

function srh.close(service)
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
		bool = lsok.close(socks[skey].ssock)
		if(bool == false) then
			print("LAU: Could not close socket: ", socks[skey].ssock)
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
function socks.create()
--[[
	parameters:
		any
	return:
		on success a key (string) that uniquely identify who is asking this send, an empty string otherwise.
]]
	local key
	local count = 0

	key = math.random(socks.max)
	while(socks[tostring(key)] ~= nil and count <= socks.max) do
		key = key + 1
		if(key > socks.max) then
			key = 1
		end
		count = count + 1
	end

	if(count > socks.max) then
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

sockgate, scmd  = srh.recv(conf.proto, "watcher") --socket where the requisition will get from client

if(sockgate == "") then
	print("LUA: srh.lua could'n create the listener socket")
	os.exit()
end

srh.send(invok.invoker(scmd), sockgate, true)
