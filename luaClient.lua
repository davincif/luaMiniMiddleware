--testes
--[[
print("lsok", type(lsok))
for key, value in pairs(lsok) do
	print(key,value)
end
print("lsok.proto", type(lsok.proto))
for key, value in pairs(lsok.proto) do
	print(key,value)
end
--]]

--Variables
local bool
local clientSocket
local bytes

clientSocket = lsok.open(lsok.proto.tcp)
if(clientSocket == 0) then
	print("LAU: Could not open socket")
	os.exit(1)
end

bool = lsok.connect(clientSocket, "127.0.0.1", 2323)
if(bool == false) then
	print("LAU: Could not connect socket: ", clientSocket)
	os.exit(1)
end

stringRet = lsok.recv(clientSocket)
print("LUA: stringRet: ", stringRet)

bool = lsok.close(clientSocket)
if(bool == false) then
	print("LAU: Could not close socket: ", clientSocket)
end