#ifndef LS_LUAAPI
#define LS_LUAAPI

/*CLIBRARIES*/
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <math.h>
/************/

/*EXTERNAL LIBRARIES*/
#include "lua/lua.h"
#include "lua/lualib.h"
#include "lua/lauxlib.h"
/*********************/

/*INTERNAL LIBRARIES*/
#include "lsAuxLib.h"
#include "marshaller.h"
/********************/

/*MARCOS*/
#define MAX_MSG_SIZE 4
#define MAX_PORT_SIZE 65535
#define LS_IS_BIGENDIAN(A) ((*(char*)&A == 0) ? LS_True : LS_False)
/********/

/*ENUM AND TYPES*/
enum LS_PROTO_NAME
{
	LS_PROTO_NONE = 0, LS_PROTO_TCP, LS_PROTO_UDP, LS_PROTO_TOKEN
};

enum LS_SHUT_MODE
{
	LS_SHUT_MODE_NONE = 0, LS_SHUT_MODE_RECV = SHUT_RD, LS_SHUT_MODE_SEND = SHUT_WR,
	LS_SHUT_MODE_RS = SHUT_RDWR, LS_SHUT_MODE_TOKEN
};
/****************/

/*EXTRUTURED TYPES*/
/******************/

/*GLOBAL VARIABLES*/
static lua_State *LCS; //Lua Client State
static int max_msg_len;
/******************/

/*GLOBAL FUNCTIONS*/
lua_State* get_lua_State();
void ls_init();
void ls_close();
LS_Bool ls_run(char *lclient);
/******************/

/*LOCAL FUNCTIONS*/
static int socket_open();
static int socket_close();
static int socket_shutdown();
static int socket_connect();
static int socket_listen();
static int socket_bind();
static int socket_accept();
static int socket_send();
static int socket_recv();
static int is_bigendian();
/*****************/


#endif