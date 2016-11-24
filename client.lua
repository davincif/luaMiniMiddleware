--[[	YOUR APPLICATION	]]
require "cproxy"

local say = ""
local said
local flag

while(say ~= "exit()") do
	io.write("\nyou: ")
	say = io.read()
	cproxy.chat.talk(say)
	repeat
		said, flag = cproxy.chat.listen()
		print("chat: "..said, flag)
	until(flag ~= true)
end
