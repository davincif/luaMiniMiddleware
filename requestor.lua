--[[	REQUESTOR	]]
require "lookup"
require "crh"

request = {}
request.clientIP = "127.0.0.1"
request.clientPort = math.random(conf.minPort, conf.maxPort)

local chat = {}
chat.reged = false --if the client is registrated at chat queue at QS
chat.cname = "" --the name of this client at the chat queue
chat.skey = nil --socket key
function request.chat(strm, proto)
--[[
	parameters:
		strm - table passed by the proxy, with 2 fields: "service" with a service offered by the server; and "load" with the msg to be sent.
		proto - what's the procotol that the msg will be sent. If nil, use the protocol preference in conf.lua.
	return:
		return the return of the crh.recv, or string "" in fail
]]
	--strm = string msg
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
conf.print("sending from: "..request.clientIP.."   "..request.clientPort)
--conf.print("to: "..ip.."   "..port)
			if(chat.reged == false) then
				if(request.sign("chat", ip, port, proto) == false) then
					sret = ""
					print("LUA: request.chat: sign to 'chat' service not found at the server")
				else
					print("sending msg: " .. strm.service.."(update,"..chat.cname..","..strm.load..")")
					chat.skey, bytes = crh.send(strm.service.."(update,"..chat.cname..","..strm.load..")", chat.skey, ip, port, {proto = proto, ip = request.clientIP, port = request.clientPort})

					if(chat.skey ~= "" and chat.skey ~= nil) then
						chat.skey, sret = crh.recv(chat.skey, false)
						conf.print("server answere: "..sret)
					end
				end
			else
				print("client " .. chat.cname .. "registed.")
				print("sending msg: " .. strm.service.."(update,"..chat.cname..","..strm.load..")")
				chat.skey, bytes = crh.send(strm.service.."(update,"..chat.cname..","..strm.load..")", chat.skey, ip, port, {proto = proto, ip = request.clientIP, port = request.clientPort})

				if(chat.skey ~= "" and chat.skey ~= nil) then
					chat.skey, sret = crh.recv(chat.skey, false)
					conf.print("server answere: "..sret)
				end

			end
		end
	end
	gsh.deactivate(chat.skey)
	return sret
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
		chat.skey, bytes = crh.send(queueName.."(revoke,"..chat.cname..")", chat.skey, ip, port, {proto = proto, ip = request.clientIP, port = request.clientPort})

		chat.skey, chat.cname = crh.recv(chat.skey, false)
		if(chat.cname == conf.signE) then
			--error
			conf.print("could not sign on chat queue"..conf.cname)
			chat.cname = ""
		else
			conf.print("client name on chat queue: "..chat.cname)
			chat.reged = true
		end

		gsh.deactivate(chat.skey)
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

	--conf.print("Requesting sing: "..queueName.."(sign)".."to:"..ip..","..port)
	chat.skey, bytes = crh.send(queueName.."(sign)", chat.skey, ip, port, {proto = proto, ip = request.clientIP, port = request.clientPort})

	conf.print("waiting response")
	chat.skey, chat.cname = crh.recv(chat.skey, false)
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

	--gsh.deactivate(chat.skey)

	return boolret
end