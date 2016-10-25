--[[	SERVER	]]
services = {} --all services my server can provide
local SERVER_IP = "127.0.0.1"

--	SERVICES REGISTRATION	--
regT = {} --registratoin table
regT.echo = {}
--regT["service"].doPar(str) - call this functions to return the correct paremetres in "str" to "service"
regT.echo.ip = SERVER_IP
regT.echo.port = 2323
regT.echo.reged = false --if this service already was registered
function regT.echo.doPar(str)
	return str
end

-- SERVICES IMPLEMENTATIONS --
function services.echo(str)
--[[
	parameters:
		str - string you want to hear the acho
	return:
		return str in success, or false otherwise
]]
	local sret

	if(type(str) ~= "string") then
		print("SERVER: ECHO's argument spected to be string but it's " .. type(strmsg))
		sret = false
	else
		print("SERVER: echo invoked for "..str) --testline
		sret = str
	end

	return sret
end


function regT.checkRegistration()
	local sockkey
	local bytes
	local ok

	sockkey = srh.setsock(conf.proto, "reg", SERVER_IP, 5101)
print("sockkey", sockkey)
	for key,value in pairs(regT) do
		if(type(value) == "table" and value.reged ~= true) then
print("ADD("..key..","..value.ip..","..value.port..")", sockkey, false)
			bytes = srh.send("ADD("..key..","..value.ip..","..value.port..")", sockkey, false)
			if(bytes == -1 or bytes == 0) then
				error("LUA: could not register service \""..key.."\" got bytes: "..bytes)
			end
			ok = srh.recv(sockgate)
			if(ok ~= "ok") then
				error("LUA: could not register service \""..key.."\" got dns answere: "..ok)
			end
			value.reged = true
		end
	end
	srh.close("reg")
end