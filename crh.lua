--[[	CLIENT TO REQUEST HANDLER	]]
crh = {}

function crh.send(strmsg, proto)
--[[
	parametrs:
		strmsg - string to be sent over the net.
		proto - the protocol to be used.
	return:
		still thikning about it ^^'
]]
	local sret
	local clientsocket
	local bool
	local bytes

	if(type(proto) ~= "number") then
		sret = nil
		print("crh.send 2st argument spected to be number but it's " .. type(proto))
	elseif(type(strmsg) ~= "string") then
		sret = nil
		print("crh.send 1st argument spected to be string but it's " .. type(strmsg))
	elseif(proto <= lsok.proto.none and proto >= lsok.proto.token) then
		sret = nil
		print("in crh.send, protocol \"" .. proto .. "\" not recognized")
	else
		if(proto == lsok.proto.tcp) then
			--[[	TCP		]]
			print("LUA: tcp") --testline
			clientsocket = lsok.open(lsok.proto.tcp)
			if(clientsocket == 0) then
				print("LAU: Could not open socket")
				os.exit(1)
			end

			bool = lsok.connect(clientsocket, "127.0.0.1", 2323)
			if(bool == false) then
				print("LAU: Could not connect socket: ", clientsocket)
				os.exit(1)
			end

			bytes = lsok.send(clientsocket, strmsg)
			print("LAU: sent bytes", bytes) --testline

			sret = lsok.recv(clientsocket, lsok.proto.tcp)
			print("LUA: recv string", sret) --testline

			bool = lsok.close(clientsocket)
			if(bool == false) then
				print("LAU: Could not close socket: ", clientsocket)
			end
		elseif(proto == lsok.proto.udp) then
			--[[	UDP		]]
			print("LUA: udp") --testline
			clientsocket = lsok.open(lsok.proto.udp)
			if(clientsocket == 0) then
				print("LAU: Could not open socket")
				os.exit(1)
			end

			bool = lsok.bind(clientsocket, "127.0.0.1", 3232)
			if(bool == false) then
				print("LUA: Could not bind")
				os.exit(1)
			end


			bytes = lsok.send(clientsocket, strmsg, "127.0.0.1", 2323)
			print("LAU: sent bytes", bytes) --testline

			stringRet = lsok.recv(clientsocket, lsok.proto.udp)
			print("LUA: recv string", stringRet) --testline

			bool = lsok.close(clientsocket)
			if(bool == false) then
				print("LAU: Could not close socket: ", clientsocket)
			end
		end
	end

	return sret
end
