--[[	QUEUE SERVER INVOKER	]]
require "qserver"

qsinvok = {}

local tp = os.time() --time parameter
local tlp = 30 --time lapse parameter, in seconds
math.randomseed(tp)

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

	--coomand exemple: "chat(update,cja823,'ei vey bora logo!')"
	if(type(command) ~= "string") then
		error("LUA: 1st argument of qsinvok.invoker spected to be string but it's " .. type(command))
	else
		local si, sf
		si = string.find(command, "%(")
		rq = string.lower(string.sub(command, 1, si-1))
		sf = string.find(command, ",")
		rs = string.sub(command, si+1, sf-1)
		si = string.find(command, ")")
		load = string.sub(command, sf+1, si-1)
		--invoking the correct service with the correct parameters
		if(rs == "sign") then
			--sing("clientName")
			if(qservices[rq] == nil) then
				answere = conf.dnsNotFound
			else
				if(load == "") then
					load = randomString()
				end

				answere = qservices[rq].sing(load)
				if(answere == true) then
					answere = load
				else
					answere = conf.signE
				end
			end
		elseif(rs == "revoke") then
			--revoke("clientName")
			if(qservices[rq] == nil) then
				answere = conf.dnsNotFound
			else
				if(load == "") then
					answere = conf.SPE
				else
					if(qservices[rq].revoke(load) == true) then
						answere = conf.dnsOk
					else
						answere = conf.signE
					end
				end
			end
		elseif(rs == "update") then
			--update
			local cname
			local str

			si = string.find(load, ",")
			cname = string.sub(load, 1, si-1)
			str = string.sub(load, si+1)

			sf = qservices[rq].update(cname, str) --reusing the variable
			if(sf == true) then
				answere = conf.dnsOk
			elseif(sf == false) then
				answere = conf.dnsNotFound
			else
				answere = conf.signE
			end
		else
			answere = nil
			print("LUA: the requested service do not exist!")
		end
	end

	return answere
end

--[[LOCAL FUNCTIONS]]
local function randomString(queue)
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
	local srt

	if(os.difftime(tp, taux) > tlp) then
		tp = taux
		math.randomseed(tp)
	end

	repeat
		repeat
			repeat
				num = math.randomseed(48, 122)
			until((num > 47 and num < 58) or (num > 64 and num < 91) or (num > 96 and num < 123))
			str = str .. string.char(num)
			len = len - 1
		until(len == 0)
	until(queue[str] == nil)

	return str
end

--answere = qservices[rs](regS[rs].doPar(load))
--qservices[service].sign()
--qservices[service].revoke()
--qservices[service].update()
