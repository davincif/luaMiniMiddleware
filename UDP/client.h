#ifndef MDW_CLIENT
#define MDW_CLIENT

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

/*GLOBAL FUNCTIONS*/
char* MDW_crh(char *serverHost, int serverPort, char *msg);
/******************/


#endif