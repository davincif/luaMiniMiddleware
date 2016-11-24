--[[	YOUR APPLICATION	]]
require "cproxy"

local say = ""
local said
local flag

while(say ~= "exit()") do
	io.write("you: ")
	say = io.read()
	cproxy.chat.talk(say)
	repeat
		said, flag = cproxy.chat.listen()
		print(said)
	until(flag ~= true)
end

--print(cproxy.chat("Go Go!!"))