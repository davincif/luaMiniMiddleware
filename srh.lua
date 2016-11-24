--[[	SERVER TO REQUEST HANDLER	]]
require "invoker"

srh = {}
local STP = 100000 --STP (Sleep Time Pattern) --100000μs = 0,1s

function srh.findS()
-- FIND SERVICE --
--[[
	parameters:
		none
	return:
		none
	PS.: this function's duty is to find the Services address of the QS in the DNS and store it.
]]
	local sock
	local si, sf
	local sret --string returned
	local bytes

	sock = lsok.open(lsok.proto.udp)
	if(sock == 0) then
		error("LUA: Could not open socket")
	end

	conf.print("searching QS services on DNS...")
	for rkey,rval in pairs(regS) do
		bytes = lsok.send(sock, "SEARCH("..rkey..")", conf.dnsIP, conf.dnsPort)
		sret = lsok.recv(sock, lsok.proto.udp)
		if(sret == conf.notFound) then
			conf.print("DNS returned error: "..sret)
			conf.print("service \"" ..rkey.."\" not registrated at the DNS")
		else
			conf.print("service \"" ..rkey.."\" on server: "..sret) --testline

			si = string.find(sret, "%(")
			sf = string.find(sret, ",")
			rval.QS_IP = string.sub(sret, si+1, sf-1)
			si = string.find(sret, ")")
			rval.QS_PORT = tonumber(string.sub(sret, sf+1, si-1))
			rval.reged = true
		end
	end

	lsok.close(sock)
end

function srh.opensockets()
--[[
	parameters:
		just open the socket of all services in the server
	return:
		a table with all keys
]]
	local tret = {}
	local boolret
	local ok
	local bytes
	local answere

	conf.print("warning the Queue Server about who is the correct server to send data...")
	for rkey,rval in pairs(regS) do
		if(rval.reged == true) then
			--only open socreatecket to those services who are registrated in the queue server
			conf.print("service: "..rkey.."...")
			rval.socket = lsok.open(lsok.proto.tcp)
			if(rval.socket == 0) then
				error("LUA: Could not open socket")
			end
			ok = lsok.bind(rval.socket ,rval.ip, rval.port)
			if(ok == false) then
				error("could not bind socktable of queue service \""..rkey.."\"")
			end
			if(lsok.connect(rval.socket, rval.QS_IP, rval.QS_PORT) == false) then
				error("Could not connect socket")
			end
			bytes = lsok.send(rval.socket, rkey.."(sign,server,"..services.getPassword()..","..rval.ip..","..rval.port..")")
			answere = lsok.recv(rval.socket, lsok.proto.tcp)
			conf.print("\t"..answere)
			table.insert(tret, rval.socket)
		end
	end
	conf.print("done")

	return tret
end

function srh.closeServes()
end

--[[	RUNNING SERVER	]]
local bytes
local scmd
local worked
local keyt
local taux
local cs --connected socket

srh.findS()
keyt = srh.opensockets()

while(true) do
	worked = false

	--receive the request from a new conection
	taux = lsok.select(#keyt, keyt)
for key, value in pairs(taux) do
print(">>", key, value)
end
	if(taux ~= nil) then
		conf.print("accept request identified")
		for key, value in pairs(taux) do
			cs = lsok.accept(value)
			if(cs <= 0) then
				break
			end
		end
		--call invoker and return it's answere
		scmd = lsok.recv(cs, lsok.proto.tcp)
		if(scmd ~= nil) then
			scmd = qsinvok.invoker(scmd)
			conf.print("server will answer: "..scmd)
			bytes = lsok.send(cs, scmd)
		end
		if(lsok.close(cs) == false) then
			print("Could not close socket")
			--do some error handling stuff
		end
		worked = true
	end

	if(worked == false) then
		lsok.sleep(STP)
	end
	break
end

srh.closeServes()
