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
		bytes = lsok.send(sock, "ADD("..key..","..rval.ip..","..rval.port..")", conf.dnsIP, conf.dnsPort)
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
	local boolret
	local tret = {}
	local ok

	conf.print("warning the Queue Server about who is the correct server to send data...")
	for rkey,rval in pairs(regS) do
		if(rval.reged == true) then
			--only open socreatecket to those services who are registrated in the queue server
			conf.print("service: "..rkey.."...")
			rval.socket = lsok.open(lsok.proto.tcp)
			if(rval.socket == 0) then
				error("LUA: Could not open socket")
			end
			--[[	 	PAREI AQUI			]]
			ok = gsh.set(rval.proto, rval.skey, nil, nil, true)
			if(ok == false) then
				error("Could not set socket of service: "..rkey)
			end
			gsh.connect(rval.skey, rval.QS_IP, rval.QS_PORT)
			rval.ip, rval.port = gsh.getsockname(rval.skey)
print(rval.ip, rval.port)
			rval.skey, bytes = srh.send(rkey.."(sign,server,"..services.getPassword()..","..rval.ip..","..rval.port..")", rval.skey)
			rval.skey, sret = srh.recv(rval.skey, false)
			conf.print("\t"..sret)
			table.insert(tret, rval.skey)
		end
	end
	conf.print("done")

	return tret
end

--[[	RUNNING SERVER	]]
local bytes
local scmd
local worked
local keyt
local taux

srh.findS()
keyt = srh.opensockets()

while(true) do
	worked = false

	--receive the request from a new conection
	taux = gsh.is_acceptable(keyt)
	if(taux ~= nil) then
		conf.print("accept request identified")
		for key, value in pairs(taux) do
			conf.print("\t", gsh.accept(value))
			worked = true
		end
	end

	--receive a new msg from a already connected socket (in tcp case)
	taux = gsh.is_readable(keyt)
	if(taux ~= nil) then
		conf.print("identified msg waiting")
		for key, value in pairs(taux) do
			taux.skey, scmd = srh.recv(taux.skey, false, conf.proto, taux.ip, taux.port)
			--call invoker and return it's answere
			scmd = invok.invoker(scmd)
			conf.print("server will answer: "..scmd)
			taux.skey, bytes = srh.send(scmd, taux.skey)
			
			gsh.deactivate(taux.skey)
			worked = true
		end
	end

	if(worked == false) then
		lsok.sleep(STP)
	end
end

gsh.closeAll()
