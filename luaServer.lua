local bool
local ret
local serverSocket

serverSocket = lsok.open(lsok.proto.tcp)
if(clientSocket == 0) then
	print("Could not open socket")
	os.exit(1)
end

bool = lsok.bind(serverSocket, "127.0.0.1", 2323)
if(bool == false) then
	print("Could bind")
	os.exit(1)
end

print("socket",serverSocket)
bool = lsok.listen(serverSocket)
if(bool == false) then
	os.exit(1)
end

ret = lsok.accept(serverSocket)
if(ret == -1) then
	os.exit(1)
end