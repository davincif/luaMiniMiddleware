#ifndef MDW_SERVER
#define MDW_SERVER

/*CLIBRARIES*/
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <string.h>
#include <math.h>
/************/

/*MARCOS*/
#define MAX_MSG_SIZE 5
/********/

/*EXTERNAL LIBRARIES*/
/*********************/

/*INTERNAL LIBRARIES*/
#include "marshaller.h"
/********************/

/*ENUM AND TYPES*/
/****************/

/*EXTRUTURED TYPES*/
/******************/

/*GLOBAL VARIABLES*/
/******************/

/*LOCAL VARIABLES*/
static int welcomeSocket;
static int newSocket;
/*****************/

/*GLOBAL FUNCTIONS*/
void MDW_connect(char *serverHost, int port);
char* MDW_srh_rec();
void MDW_srh_send(char* buffer);
void MDW_srh_close();
/******************/


#endif