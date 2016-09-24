#ifndef LS_TCPSOCKET
#define LS_TCPSOCKET

/*CLIBRARIES*/
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
/************/

/*MARCOS*/
#define MAX_MSG_SIZE 5
/********/

/*EXTERNAL LIBRARIES*/
#include "lua/lua.h"
#include "lua/lualib.h"
#include "lua/lauxlib.h"
/*********************/

/*INTERNAL LIBRARIES*/
#include "lsAuxLib.h"
/********************/

/*ENUM AND TYPES*/
enum name
{
	LS_PROTO_TCP = 1, LS_PROTO_UDP, LS_PROTO_TOKEN
};
/****************/

/*EXTRUTURED TYPES*/
/******************/

/*GLOBAL VARIABLES*/
/******************/

/*GLOBAL FUNCTIONS*/
int ls_create(enum name protocol);
/******************/


#endif