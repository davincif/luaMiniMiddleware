--[[	CLIENT PROXY	]]
require "requestor"

cproxy = {}
cproxy.proto = lsok.proto.tcp -- preferencial protocol to be used, TCP by pattern.

function cproxy.chat(str)
--[[
	parameters:
		str - string to be sent to the chat
	return:
		on success the returned conf.ok, an empty string otherwise.
]]
	local sret
	local msg

	if(type(str) ~= "string") then
		error("cproxy.chat argument spected to be string but it's " .. type(str))
	else
		msg = {}
		msg.service = "CHAT"
		msg.load = str
		sret = request.chat(msg)
	end

	return sret
end

function cproxy.wChat(str)
--[[
	parameters:
		str - string to be sent to the chat
	return:
		on success the returned conf.ok, an empty string otherwise.
]]
	local sret
	local msg

	if(type(str) ~= "string") then
		error("cproxy.chat argument spected to be string but it's " .. type(str))
	else
		msg = {}
		msg.service = "CHAT"
		msg.load = str
		sret = request.chat(msg)
	end

	return sret
end

function cproxy.qpos(str)
--[[
	parameters:
		str - string to be sent to the chat
	return:
		on success the returned conf.ok, an empty string otherwise.
]]
	local sret
	local msg

	if(type(str) ~= "string") then
		error("cproxy.qpos argument spected to be string but it's " .. type(str))
	else
		msg = {}
		msg.service = "QPOS"
		msg.load = str
		sret = request.chat(msg)
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