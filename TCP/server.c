#include "server.h"

/*GLOBAL FUNCTIONS*/
void MDW_connect(char *serverHost, int port)
{
	struct sockaddr_in serverAddr;
	socklen_t addr_size;

	//socket creating
	welcomeSocket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);

	//naming socket
	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port = htons(port);
	serverAddr.sin_addr.s_addr = inet_addr(serverHost);
	memset(serverAddr.sin_zero, '\0', sizeof serverAddr.sin_zero);
	bind(welcomeSocket, (struct sockaddr *) &serverAddr, sizeof(serverAddr));
}

char* MDW_srh_rec()
{
	char *buffer, msg_size[MAX_MSG_SIZE];
	struct sockaddr_in serverAddr;
	socklen_t addr_size;
	struct sockaddr_storage serverStorage;
	int msg_size_int;


	//listen
	if(listen(welcomeSocket, 1) == 0)
	{
		getsockname(welcomeSocket, (struct sockaddr *) &serverAddr, &addr_size);
		printf("\tListening on\n");
		printf("\t%d , %d\n", serverAddr.sin_addr.s_addr, ntohs(serverAddr.sin_port));
	}else{
		printf("\tError\n");
		exit(1);
	}

	//waiting connection
	addr_size = sizeof(serverStorage);
	newSocket = accept(welcomeSocket, (struct sockaddr *) &serverStorage, &addr_size);

	//receiving message size
	recv(newSocket, msg_size, MAX_MSG_SIZE, 0);
	MDW_unmarshall(msg_size);
	msg_size_int = atoi(msg_size);

	//allocating message's space
	buffer = (char*) malloc(sizeof(char)*(msg_size_int+1));
	if(buffer == NULL)
	{
		printf("out of memmory\n!");
		exit(1);
	}

	//receiving message
	recv(newSocket, buffer, msg_size_int, 0);
	MDW_unmarshall(buffer);

	return buffer;
}

void MDW_srh_send(char* buffer)
{
	int msg_size_int;
	char *aux, msg_size[MAX_MSG_SIZE];

	//calculating and sending message size
	msg_size_int = strlen(buffer)+1;
	if(msg_size_int > pow(10, MAX_MSG_SIZE-1)-1)
	{
		printf("ERROR: message is too big!\n");
		exit(1);
	}
	sprintf(msg_size, "%d", msg_size_int);
	aux = MDW_marshall(msg_size);
	send(newSocket, aux, MAX_MSG_SIZE, 0);
	free(aux);

	//sending message
	aux = MDW_marshall(buffer);
	send(newSocket, aux, msg_size_int, 0);
	free(aux);
}

void MDW_srh_close()
{
	shutdown(welcomeSocket, SHUT_RDWR);
	//shutdown(newSocket, SHUT_RDWR);
	/*Duvida: pq quando fechamos o newSocket da bug quando roda a aplicação pela 2º vez?*/
}
/******************/