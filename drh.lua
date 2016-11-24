--[[	SERVER TO REQUEST HANDLER	]]
require "dns"

--[[	RUNNING SERVER	]]

local sockgate
local scmd --scmd = string command

sockgate = lsok.open(lsok.proto.udp)
local bool = lsok.bind(sockgate, conf.dnsIP, conf.dnsPort)
if(bool == false) then
	error("Could not bind")
end

while(true) do
	local si
	local sf
	local cmd --command
	local service
	local ip
	local port
	local bytes
	local recvIP
	local recvPORT

	--receive the request from a new conection
	scmd, recvIP, recvPORT = lsok.recv(sockgate, lsok.proto.udp)
	print("command recreived: "..scmd)

	--process the request
	si = string.find(scmd, "%(")
	cmd = string.lower(string.sub(scmd, 1, si-1))
	if(cmd == "add") then
		local asnwere

		sf = string.find(scmd, ",")
		service = string.lower(string.sub(scmd, si+1, sf-1))
		si = string.find(scmd, ",", sf+1)
		ip =string.sub(scmd, sf+1, si-1)
		sf = string.find(scmd, ")", si+1)
		port = tonumber(string.sub(scmd, si+1, sf-1))
		conf.print("processed as: (service, ip, port) ".."-> ("..service..","..ip..","..port..")")

		--call the corrent function
		asnwere = dns.add(service, ip, port)

		--send back the correct asnwere
		bytes = lsok.send(sockgate, asnwere, recvIP, recvPORT)
	elseif(cmd == "search") then
		sf = string.find(scmd, ")")
		service = string.lower(string.sub(scmd, si+1, sf-1))
		conf.print("processed as: (service)", "("..service..")")

		--call the corrent function
		ip, port = dns.search(service)

		if(ip == nil or port == nil) then
			cmd = conf.notFound --reusing variable
		else
			cmd = "("..ip..","..tostring(port)..")" --reusing variable
		end

		--send back the correct asnwere
		bytes = lsok.send(sockgate, cmd, recvIP, recvPORT)
	end
end

--close the current conection
lsok.close(sockgate)
sockgate = nil
