#include "server.h"

/*GLOBAL FUNCTIONS*/
void MDW_connect(char *serverHost, int port)
{
	int flag;
	struct sockaddr_in serverAddr;
	socklen_t addr_size;
	welcomeSocket = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);

	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port = htons(port);
	serverAddr.sin_addr.s_addr = inet_addr(serverHost);
	memset(serverAddr.sin_zero, '\0', sizeof serverAddr.sin_zero);
	flag = bind(welcomeSocket, (struct sockaddr *) &serverAddr, sizeof(serverAddr));
	if(flag == -1)
	{
		printf("BIND Error\n");
		exit(1);
	}
}

char* MDW_srh_rec()
{
	int flag, addr_size, msg_size_int;
	char *buffer, msg_size[MAX_MSG_SIZE];
	struct sockaddr_in serverAddr;

	//receiving message size
	printf("Waiting data...\n");
	addr_size = sizeof(serverStorage);
	flag = recvfrom(welcomeSocket, msg_size, MAX_MSG_SIZE, 0, (struct sockaddr *) &serverStorage, &addr_size);
	if(flag == -1)
	{
		printf("ERROR receiving data.\n");
		exit(1);
	}
	MDW_unmarshall(msg_size);
	msg_size_int = atoi(msg_size);

	//allocating message's space
	buffer = (char*) malloc(sizeof(char)*(msg_size_int+1));
	if(buffer == NULL)
	{
		printf("out of memmory\n!");
		exit(1);
	}

	//receiving message size
	flag = recvfrom(welcomeSocket, buffer, msg_size_int, 0, (struct sockaddr *) &serverStorage, &addr_size);
	if(flag == -1)
	{
		printf("ERROR receiving data.\n");
		exit(1);
	}
	MDW_unmarshall(buffer);
	printf("Data received: %s\n", buffer);
	return buffer;
}

void MDW_srh_send(char* buffer)
{
	int flag, addr_size, msg_size_int;
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

	//seding message size
	printf("Sending data...\n");
	addr_size = sizeof(serverStorage);
	flag = sendto(welcomeSocket, aux, MAX_MSG_SIZE, 0, (struct sockaddr *) &serverStorage, addr_size);
	if(flag == -1)
	{
		printf("ERROR sending data.\n");
		exit(1);
	}
	free(aux);

	//seding message size
	aux = MDW_marshall(buffer);
	flag = sendto(welcomeSocket, aux, msg_size_int, 0, (struct sockaddr *) &serverStorage, addr_size);
	if(flag == -1)
	{
		printf("ERROR sending data.\n");
		exit(1);
	}
	free(aux);
}

void MDW_srh_close()
{
	printf("Closing socket...\n");
	shutdown(welcomeSocket, SHUT_RDWR);
}
/******************/