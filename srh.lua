--[[	SERVER TO REQUEST HANDLER	]]
srh = {}
local socks = {}
socks.max = 100 --max of socket that may be opened at the same time
socks.cautionTime = 2 --if a socket spent more than this time without being used, be cautious

math.randomseed(os.time())

--	GLOBAL FUNCTIONS	--
function srh.recv(proto)
--[[
	parameters:
		proto - the protocol to be used.
	return:
		-
]]
	local sret
	local serversocket
	local clientsocket
	local bool
	local bytes

	if(type(proto) ~= "number") then
		sret = ""
		print("srh.recv 2st argument spected to be number but it's " .. type(proto))
	elseif(lsok.is_proto_valid(proto) == false) then
		sret = ""
		print("in srh.recv, protocol \"" .. proto .. "\" not recognized")
	else
		if(proto == lsok.proto.tcp) then
			--[[	TCP		]]
			print("LUA: tcp") --testline
			serversocket = lsok.open(lsok.proto.tcp)
			if(serversocket == 0) then
				print("LUA: Could not open socket")
				os.exit(1)
			end

			bool = lsok.bind(serversocket, "127.0.0.1", 2323)
			if(bool == false) then
				print("LUA: Could bind")
				os.exit(1)
			end

			bool = lsok.listen(serversocket)
			if(bool == false) then
				os.exit(1)
			end

			clientsocket = lsok.accept(serversocket)
			if(clientsocket == -1) then
				os.exit(1)
			end

			stringRet = lsok.recv(clientsocket, lsok.proto.tcp)
			print("LUA: recv string", stringRet) --testline

			bytes = lsok.send(clientsocket, stringRet)
			print("LAU: sent bytes", bytes) --testline

			bool = lsok.close(serversocket)
			if(bool == false) then
				print("LUA: Could not close socket: ", serversocket)
			end
			bool = lsok.close(clientsocket)
			if(bool == false) then
				print("LUA: Could not close socket: ", clientsocket)
			end
		elseif(proto == lsok.proto.udp) then
			--[[	UDP		]]
			print("LUA: udp") --testline
			serversocket = lsok.open(lsok.proto.udp)
			if(serversocket == 0) then
				print("LUA: Could not open socket")
				os.exit(1)
			end

			bool = lsok.bind(serversocket, "127.0.0.1", 2323)
			if(bool == false) then
				print("LUA: Could not bind")
				os.exit(1)
			end

			stringRet = lsok.recv(serversocket, lsok.proto.udp)
			print("LUA: recvs: ", stringRet) --testline

			bytes = lsok.send(serversocket, stringRet, "127.0.0.1", 3232)
			print("LAU: sent bytes", bytes) --testline


			bool = lsok.close(serversocket)
			if(bool == false) then
				print("LUA: Could not close socket: ", serversocket)
			end
		end
	end

	return sret
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
