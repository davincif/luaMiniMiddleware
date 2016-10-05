--[[	CLIENT PROXY	]]
require "requestor"

cproxy = {}
cproxy.proto = lsok.proto.tcp -- preferencial protocol to be used, TCP by pattern.

function cproxy.echo(str)
	local ok
	local msg

	if(type(str) == "string") then
		msg = {}
		msg.service = "ECHO"
		msg.load = str
		ok = request.echo(msg)
	else
		print("cproxy.echo argument spected to be string but it's " .. type(str))
		ok = false
	end

	return ok
end

function cproxy.set_preferencial_proto(proto)
--[[
	parametrs:
		proto - what the procotol shall be the preferencial protocol now
	return:
		false if this protocol is not supported, true otherwise.
]]
	local ok

	if(lsok.is_proto_valid(proto) == true) then
		conf.proto = proto
		ok = true
	else
		print("protocol " .. proto .. "not recognized")
		ok = false
	end

	return ok
end