--[[	REQUESTOR	]]
require "lookup"
require "crh"

request = {}

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

	if(type(strm) ~= "table") then
		error("request.echo argument spected to be table but it's " .. type(strm))
	elseif(proto ~= nil and lsok.is_proto_valid(proto) == false) then
		error("request.echo 2st argument, proto, not recognized")
	else
		ip, port = lookup.search("echo")
print("serviço está em: ", ip, port)
os.exit()
		if(ip == conf.dnsNotFoun or port == conf.dnsNotFoun) then
			sret = ""
			print("LUA: request.echo 'echo' service not found at the server")
		else
			if(proto == nil) then
				skey = crh.send(strm.service .."("..strm.load..")", nil, conf.proto, ip, port)
			else
				skey = crh.send(strm.service .."("..strm.load..")", nil, proto, ip, port)
			end

			if(skey ~= "" and skey ~= nil) then
				sret = crh.recv(skey, true)
			end
		end
	end

	return sret
end