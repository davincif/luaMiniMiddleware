#include "luaAPI.h"


/*LOCAL FUNCTIONS*/
static int socket_open()
{
/*
	lua calling: like socket_open(int Protocol)
*/
	int clientSocket;

	if(!lua_isinteger(LCS, -1))
	{
		luaL_error(LCS, "1st argument of function 'socket_open' must be integer\n");
		clientSocket = 0;
	}else{
		switch(lua_tointeger(LCS, -1))
		{
			case LS_PROTO_TCP:
				clientSocket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
			break;

			case LS_PROTO_UDP:
				/*create it*/
				printf("UDP protocol no implemented yet\n");
			break;
			
			default:
				/*error*/
				clientSocket = 0;
				printf("ERROR                           ---            ------\n");
		}
	}

	lua_pushinteger(LCS, clientSocket);
	return 1;
}

static int socket_close()
{
/*
	lua calling: like socket_open(int ScoketToClose)
*/
	LS_Bool ret = LS_True;

	if(!lua_isinteger(LCS, -1)){
		luaL_error(LCS, "1st argument of function 'socket_close' must be integer\n");
	}else{
		if(shutdown(lua_tointeger(LCS, -1), SHUT_RDWR) != 0)
		{
			ret = LS_False;
			printf("Oh dear, closing a scoket usually do not go wrong... are you sure this is the right socket?\n");
			printf("Here is the C error msg:  %s\n", strerror(errno));
		}
	}

	lua_pushboolean(LCS, ret);
	return 1;
}

static int socket_connect()
{
/*
	lua calling: like socket_open(int socket, char *ipaddr, int port)
*/
	char *ip;
	int port, sock;
	struct sockaddr_in addr;
	
	if(!lua_isinteger(LCS, -1))
		luaL_error(LCS, "1st argument of function 'socket_connect' must be integer\n");
	else if(!lua_isstring(LCS, -2))
		luaL_error(LCS, "2st argument of function 'socket_connect' must be string\n");
	else if(!lua_isinteger(LCS, -3))
		luaL_error(LCS, "3st argument of function 'socket_connect' must be integer\n");

	port = lua_tointeger(LCS, -1);
printf("port %d\n", port);
	ip = lua_tostring(LCS, -2);
printf("ip %s\n", ip);
	sock = lua_tointeger(LCS, -3);
printf("sock %d\n", sock);
	if(port < 0 || port > MAX_PORT_SIZE)
		luaL_error(LCS, "port %d is out of range. Must be > 0 and < %d\n", port, MAX_PORT_SIZE);

	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	addr.sin_addr.s_addr = inet_addr(ip);
	memset(addr.sin_zero, '\0', sizeof addr.sin_zero);
	connect(sock, (struct sockaddr *) &addr, sizeof(addr));
}
/*****************/

/*GLOBAL FUNCTIONS*/
lua_State* get_lua_State()
{
	return LCS;
}

void ls_init()
{
	// Create new Lua state and load the lua libraries
	LCS = luaL_newstate();
	if(LCS == NULL)
	{
		printf("can't initialize lua state\n");
		exit(1);
	}
	luaL_openlibs(LCS);


	//creating lua structures
	lua_newtable(LCS); //general table
	//creating enums
	lua_newtable(LCS);
	lua_pushinteger(LCS, LS_PROTO_TCP);
	lua_setfield(LCS, -2, "tcp");
	lua_pushinteger(LCS, LS_PROTO_UDP);
	lua_setfield(LCS, -2, "udp");
	lua_setfield(LCS, -2, "proto"); //set inner table as "proto"
	lua_pushcfunction(LCS, socket_open);
	lua_setfield(LCS, -2, "open");
	lua_pushcfunction(LCS, socket_close);
	lua_setfield(LCS, -2, "close");
	lua_pushcfunction(LCS, socket_connect);
	lua_setfield(LCS, -2, "connect");
	lua_setglobal(LCS, "lsok"); //set general table as "lsok"
}

LS_Bool ls_run(char *lclient)
{
	LS_Bool ret;
	ret = (LS_Bool) luaL_dofile(LCS, lclient);
	if(ret != LS_False)
		lua_error(LCS);
	
	return ret;
}

void ls_close()
{
	// Close the Lua state
	lua_close(LCS);
}
/******************/