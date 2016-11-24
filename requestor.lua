--[[	REQUESTOR	]]
require "lookup"

request = {}
--[[request.clientIP = "127.0.0.1"
request.clientPort = conf.randPort()]]

local chat = {}
chat.reged = false --if the client is registrated at chat queue at QS
chat.cname = "" --the name of this client at the chat queue
chat.socket = 0 --socket

request.chat = {}
function request.chat.talk(strm, proto)
--[[
	parameters:
		strm - table passed by the proxy, with 2 fields: "service" with a service offered by the server; and "load" with the msg to be sent.
		proto - what's the procotol that the msg will be sent. If nil, use the protocol preference in conf.lua.
	return:
		return the return of the recv, or string "" in fail
]]
	local sret
	local ip
	local port
	local bytes

	if(type(strm) ~= "table") then
		error("request.chat 1st argument spected to be table but it's " .. type(strm))
	elseif(proto ~= nil and lsok.is_proto_valid(proto) == false) then
		error("request.chat 2nd argument, proto, not recognized")
	else
		ip, port = lookup.search("chat")
		conf.print("serviço chat está em: "..ip.."   "..port)
		if(ip == conf.notFound) then
			sret = ""
			print("LUA: request.chat: 'chat' service not found at the server")
		else
			if(proto == nil) then
				proto = conf.proto
			end
			if(chat.reged == false) then
				if(request.sign("chat", ip, port, proto) == false) then
					sret = ""
					print("LUA: request.chat: sign to 'chat' service not found at the server")
				else
					print("sending msg: " .. strm.service.."(update,"..chat.cname..","..strm.load..")")
					bytes = lsok.send(chat.socket, strm.service.."(update,"..chat.cname..","..strm.load..")", ip, port)

					if(chat.socket > 0) then
						sret = lsok.recv(chat.socket, lsok.proto.udp)
						conf.print("server answere: "..sret)
					end
				end
			else
				print("client " .. chat.cname .. "registed.")
				print("sending msg: " .. strm.service.."(update,"..chat.cname..","..strm.load..")")
				bytes = lsok.send(chat.socket, strm.service.."(update,"..chat.cname..","..strm.load..")", ip, port)

				if(chat.socket > 0) then
					sret = lsok.recv(chat.socket, lsok.proto.udp)
					conf.print("server answere: "..sret)
				end
			end
		end
	end

	return sret
end

function request.chat.listen(proto)
	local clientn
	local resp
	local sret
	
	conf.print("wating response...")
	sret = lsok.recv(chat.socket, lsok.proto.udp)
	si = string.find(sret, "%(")
	sf = string.find(sret, ",")
	clientn = string.sub(sret, si+1, sf-1)
	si = string.find(sret, ")")
	resp = string.sub(sret, sf+1, si-1)

	return resp
end

function request.revoke(queueName, ip, port, proto)
--[[
	parameters:
		queueName - name of the service to reques sign
		ip - the ip where to send the msg. (it's only obligatory if key is nil or protocol is udp)
		port - the port where to send the msg. (it's only obligatory if key is nil or protocol is udp)
	return:
		true on success, false otherwise
]]
	local boolret
	local bytes
	local sret

	if(chat.cname == "") then
		conf.print("no client to revome in \""..queueName.."\" queue")
	else
		bytes = lsok.send(chat.socket, queueName.."(revoke,"..chat.cname..")", ip, port)
		chat.cname = lsok.recv(chat.socket, lsok.proto.udp)
		if(chat.cname == conf.signE) then
			--error
			conf.print("could not sign on chat queue"..conf.cname)
			chat.cname = ""
		else
			conf.print("client name on chat queue: "..chat.cname)
			chat.reged = true
		end

		gsh.deactivate(chat.socket)
	end

	return boolret
end


function request.sign(queueName, ip, port, proto)
--[[
	ATTENTION: do not use this function unless you really know what you're doing
	parameters:
		queueName - name of the service to reques sign
		ip - the ip where to send the msg. (it's only obligatory if key is nil or protocol is udp)
		port - the port where to send the msg. (it's only obligatory if key is nil or protocol is udp)
	return:
		the sokey openned
		true on success, false otherwise
]]
	local boolret
	local bytes
	local sret

	chat.socket = lsok.open(lsok.proto.udp)
	conf.print("Requesting sing: "..queueName.."(sign)".."to:"..ip..","..port)
	bytes = lsok.send(chat.socket, queueName.."(sign)", ip, port)

	conf.print("waiting response")
	chat.cname = lsok.recv(chat.socket, lsok.proto.udp)
	--conf.print("received: "..chat.cname)
	if(chat.cname == conf.signE) then
		--error
		conf.print("could not sign on chat queue"..conf.cname)
		chat.cname = ""
		boolret = false
	else
		conf.print("client name on chat queue: "..chat.cname)
		chat.reged = true
		boolret = true
	end

	--gsh.deactivate(chat.socket)

	return boolret
end