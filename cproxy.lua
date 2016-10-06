--[[	CLIENT PROXY	]]
require "requestor"

cproxy = {}
cproxy.proto = lsok.proto.tcp -- preferencial protocol to be used, TCP by pattern.

function cproxy.echo(str)
--[[
	parameters:
		str - string that you want to see the echo
	return:
		on success the returned string (str), an empty string otherwise.
]]
	local sret
	local msg

	if(type(str) ~= "string") then
		print("cproxy.echo argument spected to be string but it's " .. type(str))
		sret = ""
	else
		msg = {}
		msg.service = "ECHO"
		msg.load = str
		sret = request.echo(msg)
	end

	return sret
end

function cproxy.set_preferencial_proto(proto)
--[[
	parameters:
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