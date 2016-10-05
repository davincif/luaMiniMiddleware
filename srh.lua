--[[	SERVER TO REQUEST HANDLER	]]
srh = {}

function srh.recv(strmsg, proto)
	local sret
	local serversocket
	local clientsocket
	local bool
	local bytes

	if(type(proto) ~= "number") then
		sret = nil
		print("srh.recv 2st argument spected to be number but it's " .. type(proto))
	elseif(type(strmsg) ~= "string") then
		sret = nil
		print("srh.recv 1st argument spected to be string but it's " .. type(strmsg))
	elseif(proto <= lsok.proto.nome and proto >= lsok.proto.token) then
		sret = nil
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
