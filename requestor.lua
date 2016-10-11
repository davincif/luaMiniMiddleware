--[[	REQUESTOR	]]
require "crh"

request = {}
local serv = {} --services

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
		ip, port = serv.get("echo")
		if(ip == conf.dnsNotFoun or port == conf.dnsNotFoun) then
			sret = ""
			print("request.echo 'echo' service not found at the server")
		else
			if(proto == nil) then
				skey = crh.send(strm.service .."("..strm.load..")", conf.proto, request.echo, ip, port)
			else
				skey = crh.send(strm.service .."("..strm.load..")", proto, request.echo, ip, port)
			end

			if(skey ~= "") then
				sret = crh.recv(skey, true)
			end
		end
	end

	return sret
end

function serv.get(service)
	local ip
	local port

	if(type(service) ~= "string") then
		error("LUA: serv.get 1st argument spected to be string but it's " .. type(service))
	else
		if(serv[service] == nil) then
			local skey
			local si, sf
			
			serv[service] = {}
			serv[service].qtd = 1 --the quantity registrated serves that provide the 'services'
			serv[service][1] = {}

			skey = crh.send("SEARCH("..service..")", conf.proto, request.echo, conf.dnsIP, conf.dnsPort)
			skey = crh.recv(skey, true)
			print("service \"" ..service.."\" on server "..skey) --testline

			si = string.find(skey, "%(")
			sf = string.find(skey, ",")
			ip = string.sub(skey, si+1, sf-1)
			si = string.find(skey, ")")
			port = tonumber(string.sub(skey, sf+1, si-1))
		else
			local aux

			if(serv[service].qtd > 1) then
				aux = math.random(1, serv[service].qtd)
			else
				aux = 1
			end
			ip = serv[service][aux].ip
			port = serv[service][aux].port
		end
	end

	return ip, port
end