--[[	CONFIGURATION FILE	]]
conf = {}


--	EDIT THIS SECTION AT YOUR WILL	--
conf.client = "client.lua"	--defines what file will be invoked when the client is called
conf.server = "server.lua"	--defines what file will be invoked when the server is called
conf.proto = "tcp"		--preferencial protocol do be used


--DO NOT MESS ANYTHING HERE!
if(string.lower(conf.proto) == "tcp") then
	conf.proto = lsok.proto.tcp
elseif(string.lower(conf.proto) == "udp") then
	conf.proto = lsok.proto.udp
else
	error("the configure file had not recognezed the protocol \"" .. conf.proto .. "\"")
end

function conf.getClient()
	return conf.client
end

function conf.getServer()
	return conf.server
end

function conf.getProto()
	return conf.proto
end

