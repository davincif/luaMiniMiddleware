print("Use UDP or TCP?")
if(string.lower(io.read()) == "tcp") then --TPC
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
	print("LUA: recv string", stringRet)

	bool = lsok.close(serversocket)
	if(bool == false) then
		print("LUA: Could not close socket: ", serversocket)
	end
elseif(string.lower(io.read()) == "udp") then --UDP
	serversocket = lsok.open(lsok.proto.udp)
	if(serversocket == 0) then
		print("LUA: Could not open socket")
		os.exit(1)
	end

	bool = lsok.bind(serversocket, "127.0.0.1", 2323)
	if(bool == false) then
		print("LUA: Could bind")
		os.exit(1)
	end

	stringRet = lsok.recv(serversocket, lsok.proto.udp)
	print("LUA: recv string", stringRet)

	bool = lsok.close(serversocket)
	if(bool == false) then
		print("LUA: Could not close socket: ", serversocket)
	end
end