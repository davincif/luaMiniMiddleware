#include "luaAPI.h"


/*LOCAL FUNCTIONS*/
static int socket_open()
{
/*
	lua calling: like socket_open(int Protocol)
*/
	int sock;

	if(!lua_isinteger(LCS, -1))
	{
		luaL_error(LCS, "1st argument of function 'socket_open' must be integer\n");
		sock = 0;
	}else{
		switch(lua_tointeger(LCS, -1))
		{
			case LS_PROTO_TCP:
				sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
			break;

			case LS_PROTO_UDP:
				sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
			break;
			
			default:
				sock = 0;
				printf("Error, socket protocol not recognized\n");
		}

		if(sock == -1)
			printf("Error opening socket:  %s\n", strerror(errno));
	}

	lua_pushinteger(LCS, sock);
	return 1;
}

static int socket_close()
{
/*
	lua calling: like socket_close(int ScoketToClose)
*/
	LS_Bool ret;

	if(!lua_isinteger(LCS, -1))
		luaL_error(LCS, "1st argument of function 'socket_close' must be integer\n");

	if(close(lua_tointeger(LCS, -1)) == -1)
	{
		ret = LS_False;
		printf("Oh dear, closing a scoket usually do not go wrong... are you sure this is the right socket?\n");
		printf("Error:  %s\n", strerror(errno));
	}else{
		ret = LS_True;
	}

	lua_pushboolean(LCS, ret);
	return 1;
}

static int socket_shutdown()
{
/*
	lua calling: like socket_shutdown(int ScoketToClose, int how)
*/
	LS_Bool ret;
	enum LS_SHUT_MODE shutmode;

	if(!lua_isinteger(LCS, -2))
		luaL_error(LCS, "1st argument of function 'socket_shutdown' must be integer\n");
	if(!lua_isinteger(LCS, -1))
		luaL_error(LCS, "1st argument of function 'socket_shutdown' must be integer\n");

	shutmode = lua_tointeger(LCS, -1);

	if(shutmode <= LS_SHUT_MODE_NONE || shutmode >= LS_SHUT_MODE_TOKEN)
	{
		ret = LS_False;
		printf("Error, shutdown mode not recognized\n");
	}else{
		if(shutdown(lua_tointeger(LCS, -2), shutmode) == -1)
		{
			ret = LS_False;
			printf("Oh dear, shutting down a scoket usually do not go wrong... are you sure this is the right socket?\n");
			printf("Error:  %s\n", strerror(errno));
		}else{
			ret = LS_True;
		}
	}

	lua_pushboolean(LCS, ret);
	return 1;
}

static int socket_connect()
{
/*
	lua calling: like socket_connect(int socket, char *ipaddr, int port)
*/
	const char *ip;
	int port, sock;
	struct sockaddr_in addr;
	LS_Bool ret = LS_True;
	
	if(!lua_isinteger(LCS, -1))
		luaL_error(LCS, "1st argument of function 'socket_connect' must be integer\n");
	else if(!lua_isstring(LCS, -2))
		luaL_error(LCS, "2st argument of function 'socket_connect' must be string\n");
	else if(!lua_isinteger(LCS, -3))
		luaL_error(LCS, "3st argument of function 'socket_connect' must be integer\n");

	port = lua_tointeger(LCS, -1);
	if(port < 0 || port > MAX_PORT_SIZE)
		luaL_error(LCS, "port %d is out of range. Must be > 0 and < %d\n", port, MAX_PORT_SIZE);
	ip = lua_tostring(LCS, -2);
	sock = lua_tointeger(LCS, -3);

	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	inet_aton(ip, &addr.sin_addr);
	memset(addr.sin_zero, '\0', sizeof addr.sin_zero);

	if(connect(sock, (struct sockaddr *) &addr, sizeof(addr)) == -1)
	{
		printf("Couldn't connect:  %s\n", strerror(errno));
		ret = LS_False;
	}

	lua_pushboolean(LCS, ret);
	return 1;
}

static int socket_listen()
{
/*
	lua calling: like socket_listen(int socket)
*/
	LS_Bool ret;
	int sock;

	if(!lua_isinteger(LCS, -1))
		luaL_error(LCS, "1st argument of function 'socket_listen' must be integer\n");
	sock = lua_tointeger(LCS, -1);

	if(listen(sock, 1) == 0)
	{
		ret = LS_True;
	}else{
		printf("\tError listening: %s\n", strerror(errno));
		ret = LS_False;
	}

	lua_pushboolean(LCS, ret);
	return 1;
}

static int socket_bind()
{
/*
	lua calling: like socket_bind(int socket, char *ipaddr, int port)
*/

	struct sockaddr_in addr;
	socklen_t addr_size;
	const char *ip;
	int port, sock;
	LS_Bool ret;
	
	if(!lua_isinteger(LCS, -1))
		luaL_error(LCS, "1st argument of function 'socket_bind' must be integer\n");
	else if(!lua_isstring(LCS, -2))
		luaL_error(LCS, "2st argument of function 'socket_bind' must be string\n");
	else if(!lua_isinteger(LCS, -3))
		luaL_error(LCS, "3st argument of function 'socket_bind' must be integer\n");

	port = lua_tointeger(LCS, -1);
	if(port < 0 || port > MAX_PORT_SIZE)
		luaL_error(LCS, "port %d is out of range. Must be > 0 and < %d\n", port, MAX_PORT_SIZE);
	ip = lua_tostring(LCS, -2);
	sock = lua_tointeger(LCS, -3);

	//naming socket
	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	inet_aton(ip, &addr.sin_addr);
	memset(addr.sin_zero, '\0', sizeof addr.sin_zero);
	if(bind(sock, (struct sockaddr *) &addr, sizeof(addr)) != 0)
	{
		ret = LS_False;
		printf("\tError binding: %s\n", strerror(errno));
	}else{
		ret = LS_True;
	}


	lua_pushboolean(LCS, ret);
	return 1;
}

static int socket_accept()
{
/*
	lua calling: like socket_accept(int socket)
	PS.: this is a blocking function
*/
	socklen_t addr_size;
	struct sockaddr_storage serverStorage;
	int newSocket;

	if(!lua_isinteger(LCS, -1))
		luaL_error(LCS, "1st argument of function 'socket_bind' must be integer\n");

	addr_size = sizeof(serverStorage);
	//this is a blockinf function
	newSocket = accept(lua_tointeger(LCS, -1), (struct sockaddr *) &serverStorage, &addr_size);

	if(newSocket == -1)
		printf("\tError accepting: %s\n", strerror(errno));

	lua_pushinteger(LCS, newSocket);
	return 1;
}

static int socket_send()
{
/*
	lua calling: like
		socket_send(int socket, char *message) if TPC
		or socket_send(int socket, char *message, char *ip, int port) if UPD
*/
	char *saux, *msg, *ip, msg_size[MAX_MSG_SIZE+1];
	int bytesent, sock, msglen, port, proto;
	struct sockaddr_in serverAddr;

	switch(lua_gettop(LCS))
	{
		case 2: //TCP
			if(!lua_isinteger(LCS, -2))
				luaL_error(LCS, "2st argument of function 'socket_send' must be integer\n");
			else if(!lua_isstring(LCS, -1))
				luaL_error(LCS, "1st argument of function 'socket_send' must be string\n");

			//getting arguments
			sock = lua_tointeger(LCS, -2);
			msg = lua_tostring(LCS, -1);
			msglen = strlen(msg)+1;
			if(msglen > max_msg_len)
				luaL_error(LCS, "msg is too big, you can't send more than %d bytes at once\n", max_msg_len);
			proto = LS_PROTO_TCP;
		break;

		case 4: //UDP
			if(!lua_isinteger(LCS, -4))
				luaL_error(LCS, "4st argument of function 'socket_send' must be integer\n");
			else if(!lua_isstring(LCS, -3))
				luaL_error(LCS, "3st argument of function 'socket_send' must be string\n");
			else if(!lua_isstring(LCS, -2))
				luaL_error(LCS, "2st argument of function 'socket_send' must be string\n");
			else if(!lua_isinteger(LCS, -1))
				luaL_error(LCS, "1st argument of function 'socket_send' must be integer\n");

			//getting arguments
			sock = lua_tointeger(LCS, -4);
			msg = lua_tostring(LCS, -3);
			msglen = strlen(msg)+1;
			if(msglen > max_msg_len)
				luaL_error(LCS, "msg is too big, you can't send more than %d bytes at once\n", max_msg_len);
			ip = lua_tostring(LCS, -2);
			port = lua_tointeger(LCS, -1);
			proto = LS_PROTO_UDP;
		break;

		default: //ERROR
			luaL_error(LCS, "wrong arguments, this function gets 2 or 4 arguments. See API");
	}


	sprintf(msg_size, "%d", msglen);
	saux = ls_marshall(msg_size);
	if(saux == NULL)
		luaL_error(LCS, "out of memory when marshalling");
	//seeding via tcp or udp
	switch(proto)
	{
		case LS_PROTO_TCP:
			bytesent = send(sock, saux, MAX_MSG_SIZE+1, MSG_NOSIGNAL);
		break;

		case LS_PROTO_UDP:
			serverAddr.sin_family = AF_INET;
			serverAddr.sin_port = htons(port);
			inet_aton(ip, &serverAddr.sin_addr);
			memset(serverAddr.sin_zero, '\0', sizeof serverAddr.sin_zero);
			bytesent = sendto(sock, saux, MAX_MSG_SIZE+1, MSG_NOSIGNAL, (struct sockaddr *) &serverAddr, sizeof(serverAddr));
		break;
	}
	free(saux);
	switch(bytesent)
	{
		case -1:
			printf("Couldn't send size msg:  %s\n", strerror(errno));
		break;
	
		case 0:
			printf("Error! No bytes sent: %s\n", strerror(errno));
		break;
		
		default:
			//message sent successfully
			saux = ls_marshall(msg);
			if(saux == NULL)
				luaL_error(LCS, "out of memory when marshalling");
			//seeding via tcp or udp
			switch(proto)
			{
				case LS_PROTO_TCP:
					bytesent = send(sock, saux, msglen, MSG_NOSIGNAL);
				break;

				case LS_PROTO_UDP:
					bytesent = sendto(sock, saux, msglen, MSG_NOSIGNAL, (struct sockaddr *) &serverAddr, sizeof(serverAddr));
				break;
			}
			free(saux);
			if(bytesent == -1)
				printf("Couldn't send msg:  %s\n", strerror(errno));
			else if(bytesent == 0)
				printf("Error! No bytes sent: %s\n", strerror(errno));
	}

	lua_pushinteger(LCS, bytesent);
	return 1;
}

static int socket_recv()
{
/*
	lua calling: like socket_accept(int socket, int protocol)
	returns the string received if TCP
	or string received, IP and PORT received if UDP
	OBS.: this is a blocking function
*/
	int byterecv, sock, msglen, proto, port, ret = 1;
	char *msg = NULL, msg_size[MAX_MSG_SIZE+1], *ip;
	struct sockaddr_in serverStorage;
	socklen_t socklen;

	if(!lua_isinteger(LCS, -2))
		luaL_error(LCS, "2st argument of function 'socket_recv' must be integer\n");
	if(!lua_isinteger(LCS, -1))
		luaL_error(LCS, "1st argument of function 'socket_recv' must be integer\n");

	sock = lua_tointeger(LCS, -2);
	proto = lua_tointeger(LCS, -1);

	//seeding via tcp or udp
	switch(proto)
	{
		case LS_PROTO_TCP:
			byterecv = recv(sock, msg_size, MAX_MSG_SIZE+1, 0);
		break;
		
		case LS_PROTO_UDP:
			socklen = sizeof(serverStorage);
			byterecv = recvfrom(sock, msg_size, MAX_MSG_SIZE+1, 0, (struct sockaddr *) &serverStorage, &socklen);
			if(getsockname(sock, (struct sockaddr *) &serverStorage, &socklen) == -1)
			{
				//error... don't know how to deal with it ^^"
			}else{
				ip = inet_ntoa(serverStorage.sin_addr);
				port = ntohs(serverStorage.sin_port);
			}
		break;

		default:
			luaL_error(LCS, "Required protocol not recognized\n");
	}
	ls_unmarshall(msg_size);
	//chekcing if send worked fine
	switch(byterecv)
	{
		case -1:
			printf("Couldn't recv msg size: %s\n", strerror(errno));
		break;

		case 0:
			printf("Error! No bytes recv: %s\n", strerror(errno));
		break;

		default:
			msglen = atoi(msg_size);
			msg = (char*) malloc(sizeof(char)*(msglen+1));
			if(msg == NULL)
				luaL_error(LCS, "Couldn't alloc memory to sotore msg!");

			//seeding via tcp or udp
			switch(proto)
			{
				case LS_PROTO_TCP:
					byterecv = recv(sock, msg, msglen, 0);
				break;
				
				case LS_PROTO_UDP:
					byterecv = recvfrom(sock, msg, msglen, 0, (struct sockaddr *) &serverStorage, &socklen);
					ret = 3;
				break;
			}
			//chekcing if send worked fine
			if(byterecv == -1)
			{
				printf("Couldn't recv msg size: %s\n", strerror(errno));
				free(msg);
				msg = NULL;
			}else if(byterecv == 0){
				printf("Error! No bytes recv: %s\n", strerror(errno));
				free(msg);
				msg = NULL;
			}else{
				ls_unmarshall(msg);
			}
	}

	lua_pushstring(LCS, msg);
	if(msg != NULL)
		free(msg);
	if(proto == LS_PROTO_UDP)
	{
		lua_pushstring(LCS, ip);
		lua_pushinteger(LCS, port);
	}
	return ret;
}

static int ls_is_bigendian()
{
	int flag = 2;

	lua_pushboolean(LCS, LS_IS_BIGENDIAN(flag));
	return 1;
}

static int ls_is_proto_valid()
{
	enum LS_PROTO_TYPE proto;

	if(!lua_isinteger(LCS, -1))
		luaL_error(LCS, "1st argument of function 'ls_is_proto_valid' must be integer\n");

	proto = lua_tointeger(LCS, -1);

	lua_pushboolean(LCS, LS_IS_PROTO_VALID(proto));
	return 1;
}
/*****************/

/*GLOBAL FUNCTIONS*/
lua_State* get_lua_State()
{
	return LCS;
}

void ls_init()
{
/*
	initialize lua socket API
*/
	max_msg_len = ((int) pow((double) 10, (double) (MAX_MSG_SIZE-1))) - 1;

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
	//adding enums
	lua_newtable(LCS);
	lua_pushinteger(LCS, LS_PROTO_NONE);
	lua_setfield(LCS, -2, "none");
	lua_pushinteger(LCS, LS_PROTO_TCP);
	lua_setfield(LCS, -2, "tcp");
	lua_pushinteger(LCS, LS_PROTO_UDP);
	lua_setfield(LCS, -2, "udp");
	lua_pushinteger(LCS, LS_PROTO_TOKEN);
	lua_setfield(LCS, -2, "token");
	lua_setfield(LCS, -2, "proto"); //set inner table as "proto"
	//adding functions
	lua_pushcfunction(LCS, socket_open);
	lua_setfield(LCS, -2, "open");
	lua_pushcfunction(LCS, socket_close);
	lua_setfield(LCS, -2, "close");
	lua_pushcfunction(LCS, socket_shutdown);
	lua_setfield(LCS, -2, "shutdown");
	lua_pushcfunction(LCS, socket_connect);
	lua_setfield(LCS, -2, "connect");
	lua_pushcfunction(LCS, socket_listen);
	lua_setfield(LCS, -2, "listen");
	lua_pushcfunction(LCS, socket_bind);
	lua_setfield(LCS, -2, "bind");
	lua_pushcfunction(LCS, socket_accept);
	lua_setfield(LCS, -2, "accept");
	lua_pushcfunction(LCS, socket_send);
	lua_setfield(LCS, -2, "send");
	lua_pushcfunction(LCS, socket_recv);
	lua_setfield(LCS, -2, "recv");
	lua_pushcfunction(LCS, ls_is_bigendian);
	lua_setfield(LCS, -2, "is_bigendian");
	lua_pushcfunction(LCS, ls_is_proto_valid);
	lua_setfield(LCS, -2, "is_proto_valid");
	lua_setglobal(LCS, "lsok"); //set general table as "lsok"

	ls_run("conf.lua"); //running configure file
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
/*
	close and clean lua socket API garbage
*/
	// Close the Lua state
	lua_close(LCS);
}
/******************/