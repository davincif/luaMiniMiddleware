--[[	LOOKUP	]]

lookup = {}
local serv = {} --services

function lookup.search(service)
--[[
	parameters:
		service - the service's name you want know about.
	return:
		the correct service's ip and por in success, conf.notFoun otherwise
]]
	local ip
	local port
	local socket

	if(type(service) ~= "string") then
		error("LUA: lookup.search 1st argument spected to be string but it's " .. type(service))
	else
		socket = lsok.open(lsok.proto.udp)
		if(serv[service] == nil) then
			local si, sf
			local sret --string returned
			local bytes
			
			serv[service] = {}
			serv[service].qtd = 1 --the quantity registrated serves that provide the 'services'
			serv[service][1] = {}

			bytes = lsok.send(socket, "SEARCH("..service..")", conf.dnsIP, conf.dnsPort)
			sret = lsok.recv(socket, lsok.proto.udp)
print("retornou do dns: ", sret)
			if(sret == conf.notFound) then
				print("service \"" ..service.."\" not registrated at the DNS")
				ip = sret
			else
				--print("service \"" ..service.."\" on server: "..sret) --testline

				si = string.find(sret, "%(")
				sf = string.find(sret, ",")
				ip = string.sub(sret, si+1, sf-1)
				si = string.find(sret, ")")
				port = tonumber(string.sub(sret, sf+1, si-1))
			end
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

	lsok.close(socket)

	return ip, port
end
