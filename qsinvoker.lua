--[[	QUEUE SERVER INVOKER	]]
require "qserver"

qsinvok = {}

local tp = os.time() --time parameter
local tlp = 30 --time lapse parameter, in seconds
math.randomseed(tp)

local lf = {} --local functions

function qsinvok.invoker(command)
--[[
	parameters:
		command - the command that the client sent to the server
	return:
		return the msg to be sent back to the client, or nil if the invoker fails
]]
	local answere
	local rs --rs = resquested service
	local rq --rq = resquested queue
	local load

print("comando ", command)
	--coomand exemple: "chat(update,cja823,'ei vey bora logo!')"
	if(type(command) ~= "string") then
		error("LUA: 1st argument of qsinvok.invoker spected to be string but it's " .. type(command))
	else
		local si, sf
		si = string.find(command, "%(")
		rq = string.lower(string.sub(command, 1, si-1)) --service: chat or qpos
		sf = string.find(command, ",")
		if(sf == nil) then
			sf = string.find(command, ")")
			rs = string.lower(string.sub(command, si+1, sf-1))
			load = ""
		else
			rs = string.lower(string.sub(command, si+1, sf-1)) --command to process
			si = string.find(command, ")")
			load = string.sub(command, sf+1, si-1) -- name and str
		end
		--invoking the correct service with the correct parameters
		if(rs == "sign") then
			--sign("clientName")
			--coomand exemple: "chat(sign,cja823)" or "chat(sign)"
			local name = ""

			if(qservices[rq] == nil) then
				answere = conf.notFound
			else
				if(load == "") then
					load = lf.randomString(qservices[rq].queue)
				end

				sf = string.find(load, ",")
				if(sf ~= nil) then
					name = string.sub(load, 1, sf-1)
				end
				if(name == "server") then
					--server contact
					--exemple: "chat(sign,server,password,ip,port)"
					local password

					si = string.find(load, ",", sf+1)
					password = string.sub(load, sf+1, si-1)
					if(qservices.comparePass(password) ~= true) then
						conf.print("wrong password!")
						answere = conf.SPE
					else
						sf = string.find(load, ",", si+1)
						qregS[rq].serverIP = string.sub(load, si+1, sf-1)
						qregS[rq].serverPORT = string.sub(load, sf+1)
						answere = conf.ok
print(qregS[rq].serverIP, qregS[rq].serverPORT)
					end
				else
					answere = qservices[rq].sign(load)
					if(answere == true) then
						answere = load
					else
						answere = conf.signE
					end
				end
			end
		elseif(rs == "revoke") then
			--revoke("clientName")
			--coomand exemple: "chat(revoke,cja823)"
			if(qservices[rq] == nil) then
				answere = conf.notFound
			else
				if(load == "") then
					answere = conf.SPE
				else
					if(qservices[rq].revoke(load) == true) then
						--answere = conf.ok
						answere = conf.close
					else
						answere = conf.signE
					end
				end
			end
		elseif(rs == "update") then
			--update
			--coomand exemple: "chat(revoke,cja823, data, data, ...)"
			local cname
			local str

			si = string.find(load, ",")
			cname = string.sub(load, 1, si-1)
			str = string.sub(load, si+1)
			sf = qservices[rq].update(cname, str) --reusing the variable
			if(sf == true) then
				answere = conf.ok
			elseif(sf == false) then
				answere = conf.notFound
			else
				answere = conf.signE
				print("entrei no ultimo erro aqui")
			end
		else
			answere = nil
			print("LUA: the requested service do not exist!")
		end
	end

	return answere
end

function qsinvok.QS_update()
--[[
	parameters:
		none
	return:
		none
	PS.: this functions will actualize any needed information from the QS to the server
]]

	for key,value in pairs(qregS) do
		print(key, value, value.serverIP, value.serverPORT)
	end
end

--[[LOCAL FUNCTIONS]]
function lf.randomString(queue)
--[[
	parameters:
		queue - the queue where this client will be added
	return:
		an random string to be used as a client name

	PS.: this function will not add the client in the queue!! but it's need to check if the random
	string already exist or not.
]]
	local num
	local len = conf.CQNL + math.random(-conf.CQNV, conf.CQNV)
	local taux = os.time()
	local str = ""

	if(os.difftime(tp, taux) > tlp) then
		tp = taux
		math.randomseed(tp)
	end

	repeat
		repeat
			repeat
				num = math.random(48, 122)
			until((num > 47 and num < 58) or (num > 64 and num < 91) or (num > 96 and num < 123))
			str = str .. string.char(num)
			len = len - 1
		until(len == 0)
	until(queue[str] == nil)

	return str
end
