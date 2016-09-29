local bool
local clientsocket
local serversocket
local stringRet

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

stringRet = lsok.recv(clientsocket)
print("LUA: recv string", stringRet)

bool = lsok.close(serversocket)
if(bool == false) then
	print("LUA: Could not close socket: ", serversocket)
end