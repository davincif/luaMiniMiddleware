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
local clientsocket
local bytes

clientsocket = lsok.open(lsok.proto.tcp)
if(clientsocket == 0) then
	print("LAU: Could not open socket")
	os.exit(1)
end

bytes = lsok.send(clientsocket, "FUATI!")
print("LAU: sent bytes", bytes)

--[[
bool = lsok.connect(clientsocket, "127.0.0.1", 2323)
if(bool == false) then
	print("LAU: Could not connect socket: ", clientsocket)
	os.exit(1)
end

bytes = lsok.send(clientsocket, "FUATI!")
print("LAU: sent bytes", bytes)

bool = lsok.close(clientsocket)
if(bool == false) then
	print("LAU: Could not close socket: ", clientsocket)
end
]]