--[[	DYNAMIC NAME SERVICE	]]
-- da vinci fez modificacao no srh que nao tem nesse branch

dns = {} -- construct an empty table for service, port and ip
local i = 1

--	GLOBAL FUNCTIONS  --
function dns.add(service, ip, port)
--[[
	parameters:
		service - name of service offered by a server
		port - port where service is hosted 
		ip - IP of server that host the service
	return:
		conf.dnsOk in success, an empty string otherwise
]]
	local ok = ""

	if(dns[service] == nil) then
		dns[service] = {}
		dns[service][i] = {}
		dns[service][i].port = port
		dns[service][i].ip = ip
		ok = conf.dnsOk
	else
		i = tablelen(dns[service]) + 1
		dns[service][i] = {}
		dns[service][i].port = port
		dns[service][i].ip = ip
		ok = conf.dnsOk
	end

	return ok
end

function dns.search(service)
--[[
	parameters:
		service - name of service that a client is searching
	return:
		ip - IP of server that host the service
		port - port where service is hosted 
]]
	local ip, port

	if(dns.service == nil) then
		print("There are no server offering service \""..service.."\"")
	else
		-- i = fazer bonitinho depois
		ip = dns[service][1].ip
		port = dns[service][1].port
	end

	return ip, port
end


--	LOCAL FUNCTIONS  --
local function tablelen(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end

	return count
end