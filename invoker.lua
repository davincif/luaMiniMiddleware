--[[	INVOKER		]]
require "server"

invok = {}

function invok.invoker(command)
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

	conf.print("command: "..command)
	--coomand exemple: "chat(update,cja823,'ei vey bora logo!')"
	if(type(command) ~= "string") then
		error("1st argument of invok.invoker spected to be string but it's " .. type(command))
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
		if(rs == "revoke") then
			--revoke("clientName")
			--coomand exemple: "chat(revoke,cja823)"
			if(services[rq] == nil) then
				answere = conf.notFound
			else
				if(load == "") then
					answere = conf.SPE
				else
					if(services[rq].revoke(load) == true) then
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
			answere = services[rq].update(cname, str) --reusing the variable
		else
			answere = nil
			print("the requested service do not exist!")
		end
	end

	return answere, rq
end
