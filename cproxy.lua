--[[	CLIENT PROXY	]]
require "requestor"

cproxy = {}
cproxy.proto = lsok.proto.tcp -- preferencial protocol to be used, TCP by pattern.

cproxy.chat = {}
function cproxy.chat.talk(str)
--[[
	parameters:
		str - string to be sent to the chat
	return:
		on success the returned conf.ok, an empty string otherwise.
]]
	local sret
	local flag

	if(type(str) ~= "string") then
		error("cproxy.chat argument spected to be string but it's " .. type(str))
	else
		sret = request.chat.talk(str)
		repeat
			if(sret == conf.notFound) then
				print(sret)
			elseif(sret == conf.signE) then
				print(sret)
			elseif(sret ~= conf.ok) then
				request.chat.push(sret)
				sret, flag = request.chat.listen(nil, true)
			end
		until(sret == conf.ok or sret == conf.notFound or sret == conf.signE)
	end

	return sret
end

function cproxy.chat.listen()
	local str
	local flag

	str = request.chat.pop()
	if(str == nil) then
		str, flag = request.chat.listen()
	else
		local si
		local sf
		local clientn

		conf.print("server already answere to chat.listen queue: "..str)
		si = string.find(str, "%(")
		sf = string.find(str, ",")
		clientn = string.sub(str, si+1, sf-1)
		si = string.find(str, ")")
		str = string.sub(str, sf+1, si-1)
	end

	return str, flag
end

cproxy.qpos = {}
function cproxy.qpos.talk(str)
--[[
	parameters:
		str - string to be sent to the chat
	return:
		on success the returned conf.ok, an empty string otherwise.
]]
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