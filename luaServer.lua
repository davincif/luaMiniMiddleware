local bool
local clientsocket
local serverSocket
local stringRet

serverSocket = lsok.open(lsok.proto.tcp)
if(serverSocket == 0) then
	print("LUA: Could not open socket")
	os.exit(1)
end

bool = lsok.bind(serverSocket, "127.0.0.1", 2323)
if(bool == false) then
	print("LUA: Could bind")
	os.exit(1)
end

bool = lsok.listen(serverSocket)
if(bool == false) then
	os.exit(1)
end

clientsocket = lsok.accept(serverSocket)
if(clientsocket == -1) then
	os.exit(1)
end

print("LAU: serverSocket", serverSocket)
bytes = lsok.send(clientsocket, "FUATI!")
print("LAU: bytes", bytes)

print("LUA: vamo fechar o serverSocket", serverSocket)
bool = lsok.close(serverSocket)
if(bool == false) then
	print("LUA: Could not close socket: ", serverSocket)
end