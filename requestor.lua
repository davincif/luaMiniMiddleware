--[[	REQUESTOR	]]
require "crh"

request = {}

function request.echo(strm, proto)
--[[
	parametrs:
		strm - table passed by the proxy, with 2 fields: "service" with a service offered by the server; and "load" with the msg to be sent.
		proto - what's the procotol that the msg will be sent. If nil, use the protocol preference in conf.lua.
	return:
		true if the request was sent correctly, false otherwise.
]]
	--strm = string msg
	local ok

	if(type(strm) == "table") then
		if(proto == nil) then
			sret = crh.send(strm.service .."("..strm.load..")", conf.proto)
		else
			sret = crh.send(strm.service .."("..strm.load..")", proto)
		end

		if(sret == nil or sret == "") then
			ok = false
		else
			ok = true
		end
	else
		print("request.echo argument spected to be table but it's " .. type(strm))
		ok = false
	end

	return ok
end
