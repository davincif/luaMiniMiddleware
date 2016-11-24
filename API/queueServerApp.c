#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "luaAPI.h"

int main(int argc, char const *argv[])
{
	LS_Bool auxb;
	char *caux, *qserver;
	enum LS_PROTO_TYPE proto;
	void *Lstack; //lua stack, it shall be used only temporarily

	ls_init();

	Lstack = (void*) get_lua_State();

	//getting configurations
	lua_getglobal(Lstack, "conf");

	//get queue server file addrs
	lua_getfield(Lstack, -1, "getQS");
	if(lua_pcall(Lstack, 0, 1, 0) != 0)
		luaL_error(Lstack, "couldn't run function conf.getQS");
	caux = lua_tostring(Lstack, -1);
	qserver = (char*) malloc(sizeof(char)*(strlen(caux)+1));
	if(qserver == NULL)
		luaL_error(Lstack, "lack of memory, sorry");
	strcpy(qserver, caux);
	lua_pop(Lstack, 1);

	//getting preferencial protocol
	lua_getfield(Lstack, -1, "getProto");
	if(lua_pcall(Lstack, 0, 1, 0) != 0)
		luaL_error(Lstack, "couldn't run function conf.getProto");
	proto = lua_tointeger(Lstack, -1);
	lua_pop(Lstack, 1);
	Lstack = NULL;

	auxb = ls_run(qserver);
	if(auxb != LS_False)
		printf("Error running lua %s\n", qserver);

	free(qserver);
	ls_close();

	return 0;
}