--[[	QUEUE SERVER TO REQUEST HANDLER		]]
require "qsinvoker"

qsrh = {}
local STP = 100000 --STP (Sleep Time Pattern) --100000μs = 0,1s

-- CHECK AND REGISTER SERVICES --
function qsrh.checkNregister()
--[[
	Functionality:
		call this funtion to check if all the services in this server are registrated.
		if they dont, this function will register it.
	Return:
		true in success, false otherwise
]]
	local dnsSock
	local bytes
	local sret
	local ok = true

	--openning and setting up the socket
	dnsSock = lsok.open(lsok.proto.udp)
	if(dnsSock == 0) then
		error("LUA: Could not open socket")
	end


	print("services registration...")
	for key,value in pairs(qregS) do
		print("\tADD("..key..","..value.ip..","..value.port..")")
		bytes = lsok.send(dnsSock, "ADD("..key..","..value.ip..","..value.port..")", conf.dnsIP, conf.dnsPort)
		sret = lsok.recv(dnsSock, lsok.proto.udp)
		print("\t\t"..sret)

		if(sret == conf.ok) then
			value.reged = true
		else
			ok = false
			print("LUA: in checkNregister, could not register \""..key.."\" service")
			break
		end
	end
	print("all services registrated")

	if(lsok.close(dnsSock) == false) then
		print("LUA: Could not close socket used to connect with the DNS")
	end

	return ok
end

function qsrh.opensockets()
--[[
	parameters:
		just open the socket of all services in the server
	return:
		a table with all keys
]]
	local boolret
	local tret = {}

	for rkey,rval in pairs(qregS) do
		if(rval.reged == true) then
			--only open socket to those services who are registrated in the queue server
			if(rval.skey == nil) then
				rval.skey = lsok.open(lsok.proto.tcp)
				if(rval.skey == 0) then
					error("LUA: Could not open socket")
				end
				boolret = lsok.bind(rval.skey, rval.ip, rval.port)
				if(boolret == false) then
					error("could not bind socktable of queue service \""..rkey.."\"")
				end
				boolret = lsok.listen(rval.skey)
				if(boolret == false) then
					error("could not listen socktable of queue service \""..rkey.."\"")
				end
			end
			table.insert(tret, rval.skey)
		end
	end

	return tret
end

function qsrh.QS_update()
--[[
	parameters:
		none
	return:
		none
	PS.: this functions will actualize any needed information from the QS to the server
]]
	local answere
	local bytes

	for serv,value in pairs(qregS) do
		--what services to be updated on the server?

		if(qservices[serv].queue.s_update == true) then
			--this service needs updated on server
			conf.print("updating \""..serv.."\" queue on the server")
			for qsckey,qscvalue in pairs(qservices[serv].queue) do
				--in this service, what are the client that needs update on server?
				if(type(qscvalue) == "table" and qservices[serv].queue[qsckey].s_update == true) then
					--update the client in qsckey
					conf.print("\tupdating \""..qsckey.."\" queue client on the server")
	print("update("..")", qregS[serv].skey, gsh.getsockname(qregS[serv].skey))
					bytes = lsok.send(qregS[serv].skey, "update("..")")
					answere = lsok.recv(qregS[serv].skey, lsok.proto.tcp)
					conf.print("\t"..answere)
				end
			end
		end

		if(qservices[serv].queue.c_update == true) then
			--does this service needs to be updated on the client?
			conf.print("\""..serv.."\" queue need to be updated on the client")
			for qsckey,qscvalue in pairs(qservices[serv].queue) do
				--in this service, what are the client that needs update on client?
				if(type(qscvalue) == "table" and qservices[serv].queue[qsckey].c_update == true) then
					--update the client in qsckey
					conf.print("updating \""..qsckey.."\" queue client on the server")
					conf.print("\t"..answere)
				end
			end
		end
	end
end

--[[	RUNNING SERVER	]]
local bytes
local scmd
local worked
local keyt
local taux


--request registration on the DNS
qsrh.checkNregister()
keyt = qsrh.opensockets()

while(true) do
	local cs --connected socket
	worked = false

	--receive the request from a new conection
	taux = lsok.select(#keyt, keyt)
	if(taux ~= nil) then
		conf.print("accept request identified in")
		for key, value in pairs(taux) do
			cs = lsok.accept(value)
		end
		--call invoker and return it's answere
		scmd = lsok.recv(cs, lsok.proto.tcp)
		if(scmd ~= nil) then
			scmd = qsinvok.invoker(scmd)
			conf.print("server will answer: "..scmd)
			bytes = lsok.send(cs, "ADD("..key..","..value.ip..","..value.port..")")
		end
		if(lsok.close(cs) == false) then
			print("Could not close socket")
			--do some error handling stuff
		end
		worked = true
	end

	qsrh.QS_update()

	if(worked == false) then
		lsok.sleep(STP)
	end
end

gsh.closeAll()
