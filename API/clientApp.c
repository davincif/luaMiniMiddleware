#include <stdio.h>

#include "luaAPI.h"

int main(int argc, char const *argv[])
{
	LS_Bool auxb;

	ls_init();

	auxb = ls_run("luaClient.lua");
	if(auxb != LS_False)
		printf("Error running lua luaClient.lua\n");

	ls_close();

	return 0;
}