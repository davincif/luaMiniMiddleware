--[[	LOOKUP	]]
require "crh"

lookup = {}
local serv = {} --services

function lookup.search(service)
--[[
	parameters:
		service - the service's name you want know about.
	return:
		the correct service's ip and por in success, conf.dnsNotFoun otherwise
]]
	local ip
	local port
	local skey

	if(type(service) ~= "string") then
		error("LUA: lookup.search 1st argument spected to be string but it's " .. type(service))
	else
		if(serv[service] == nil) then
			local skey
			local si, sf
			
			serv[service] = {}
			serv[service].qtd = 1 --the quantity registrated serves that provide the 'services'
			serv[service][1] = {}

			skey = crh.send("SEARCH("..service..")", nil, conf.proto, conf.dnsIP, conf.dnsPort)
			skey = crh.recv(skey, true)
			print("service \"" ..service.."\" on server: "..skey) --testline

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

function lookup.add(serveName, ip, port)
--[[
	parameters:
		serveName - The nome of the service
		ip - the ip for the DNS communicate with you
		port - the port for the DNS communicate with you
	return:
		conf.dnsOk if the registration was perfomaed successfully, an empty string otherwise.
]]
	local skey
	local ret

	if(type(serveName) ~= "string") then
		error("LUA: lookup.add 1st argument spected to be string but it's " .. type(serveName))
	elseif(type(ip) ~= "string") then
		error("LUA: lookup.add 2nd argument spected to be string but it's " .. type(ip))
	elseif(type(port) ~= "number") then
		error("LUA: lookup.add 3nd argument spected to be number but it's " .. type(port))
	else
		skey = crh.send("ADD("..serveName..","..ip..","..port..")", nil, conf.proto, conf.dnsIP, conf.dnsPort)
		skey, ret = crh.recv(skey, true)
		if(ret ~= conf.dnsOk) then
			ret = ""
		end
	end

	return ret
end