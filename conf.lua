--[[	CONFIGURATION FILE	]]


--[[	ATTENTION: ONLY EDIT THIS FILE IF YOU >>REALLY<< KNOW WHAT YOU'RE DOING!	]]


conf = {}


--	DEFINITIONS	--
conf.client = "client.lua"		--defines what file will be invoked when the client is called
conf.server = "srh.lua"			--defines what file will be invoked when the server is called
conf.dns = "drh.lua"			--defines what file will be invoked when the dns is called
conf.qs = "qsrh.lua"			--defines what file will be invoked when the queue server is called
conf.proto = "tcp"				--preferencial protocol do be used
conf.sockMax = 100				--the max number of sockets that may be opened at the same time
conf.sockCautionTime = 2		--if a socket spent more than this time without being used, be cautious
conf.dnsProto = "udp"			--protocol used to communicate with the DNS
conf.dnsIP = "127.0.0.1"		--the IP of the DNS server
conf.dnsPort = 6001				--the port of the DNS server
conf.notFound = "not found"		--the msg received when the requested service or client is not registered
conf.ok = "ok"				--the msg received when the requested service or client was performed successfully
conf.SPE = "SPE"				-- SPE (Server Parameter Error) in case the client call a function in the server with worng parameters, this will be returned
conf.CQNL = 6					--CQNL (Client Queue Name Length)
conf.CQNV = 2					--CQNV (Client Queue Name Variance)
conf.signE = "already signed"	--sign error (occuer when the same client try to sign to the same queue more than once)
conf.maxPort = math.pow(2,16)-1	--the maximal number to open a port
conf.minPort = 1023+1-1			--the minimal number to open a port
conf.output = true				--says if the programs will output mensagens (like a debug)


--AUTO ADJUSTMENTS
if(string.lower(conf.proto) == "tcp") then
	conf.proto = lsok.proto.tcp
elseif(string.lower(conf.proto) == "udp") then
	conf.proto = lsok.proto.udp
else
	error("the configure file had not recognezed the protocol \"" .. conf.proto .. "\"")
end
if(string.lower(conf.dnsProto) == "tcp") then
	conf.dnsProto = lsok.proto.tcp
elseif(string.lower(conf.dnsProto) == "udp") then
	conf.dnsProto = lsok.proto.udp
else
	error("the configure file had not recognezed the protocol \"" .. conf.proto .. "\"")
end

--GET FUNCTIONS
function conf.getClient()
	return conf.client
end

function conf.getServer()
	return conf.server
end

function conf.getDNS()
	return conf.dns
end

function conf.getQS()
	return conf.qs
end

function conf.getProto()
	return conf.proto
end

--OTHER FUNCTIONS
function conf.print(...)
	if(conf.output == true) then
		print(...)
	end
end