--[[	YOUR APPLICATION	]]
require "cproxy"

local say = ""

while(say ~= "exit()") do
	io.write("you: ")
	say = io.read()
	cproxy.chat.talk(say)
	print(cproxy.chat.listen())
end

--print(cproxy.chat("Go Go!!"))