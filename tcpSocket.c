#include "tcpSocket.h"

/*GLOBAL FUNCTIONS*/
int ls_create(enum name protocol)
{
	int clientSocket;

	switch(protocol)
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

	return clientSocket;
}
/******************/