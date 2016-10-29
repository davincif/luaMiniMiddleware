--[[	REQUESTOR	]]
require "lookup"
require "crh"

request = {}
request.clientIP = "127.0.0.1"
request.clientPort = 2656

function request.echo(strm, proto)
--[[
	parameters:
		strm - table passed by the proxy, with 2 fields: "service" with a service offered by the server; and "load" with the msg to be sent.
		proto - what's the procotol that the msg will be sent. If nil, use the protocol preference in conf.lua.
	return:
		return the return of the crh.recv, or string "" in fail
]]
	--strm = string msg
	local skey
	local sret
	local ip
	local port
	local bytes

	if(type(strm) ~= "table") then
		error("request.echo argument spected to be table but it's " .. type(strm))
	elseif(proto ~= nil and lsok.is_proto_valid(proto) == false) then
		error("request.echo 2st argument, proto, not recognized")
	else
		ip, port = lookup.search("echo")
print("serviço está em: ", ip, port)
		if(ip == conf.dnsNotFoun) then
			sret = ""
			print("LUA: request.echo 'echo' service not found at the server")
		else
			if(proto == nil) then
				proto = conf.proto
			end
print("enviando de: ", request.clientIP, request.clientPort)
print("para: ", ip, port)
			skey, bytes = crh.send(strm.service.."("..strm.load..")", nil, ip, port, {proto = proto, ip = request.clientIP, port = request.clientPort})

			if(skey ~= "" and skey ~= nil) then
				skey, sret = crh.recv(skey, true)
			end
		end
	end

	return sret
end