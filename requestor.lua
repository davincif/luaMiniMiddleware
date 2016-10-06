--[[	REQUESTOR	]]
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

	if(type(strm) ~= "table") then
		print("request.echo argument spected to be table but it's " .. type(strm))
		sret = ""
	elseif(proto ~= nil and lsok.is_proto_valid(proto) == false) then
		print("request.echo 2st argument, proto, not recognized")
		sret = ""
	else
		if(proto == nil) then
			skey = crh.send(strm.service .."("..strm.load..")", conf.proto, request.echo)
		else
			skey = crh.send(strm.service .."("..strm.load..")", proto, request.echo)
		end

		if(skey ~= "") then
			sret = crh.recv(skey, true)
		end
	end

	return sret
end
