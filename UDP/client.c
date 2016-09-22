#include "client.h"

/*GLOBAL FUNCTIONS*/
char* MDW_crh(char *serverHost, int serverPort, char *msg) /*IP, port and msn to send*/
{
	int clientSocket, flag, addr_size, msg_size_int;
	char *buffer, msg_size[MAX_MSG_SIZE];
	struct sockaddr_in serverAddr;

	clientSocket = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if(clientSocket == -1)
	{
		printf("ERROR creating socket.\n");
		exit(1);
	}

	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port = htons(serverPort);
	serverAddr.sin_addr.s_addr = inet_addr(serverHost);
	memset(serverAddr.sin_zero, '\0', sizeof serverAddr.sin_zero);

	//calculating and sending message size
	printf("Sending data: %s\n", msg);
	msg_size_int = strlen(msg)+1; //+1 -> +'1' do marshaller
	if(msg_size_int > pow(10, MAX_MSG_SIZE-1)-1)
	{
		printf("ERROR: message is too big!\n");
		exit(1);
	}
	sprintf(msg_size, "%d", msg_size_int);
	buffer = MDW_marshall(msg_size);
	addr_size = sizeof(serverAddr);
	flag = sendto(clientSocket, buffer, MAX_MSG_SIZE, 0, (struct sockaddr *) &serverAddr, addr_size);
	if(flag == -1)
	{
		printf("ERROR sending data.\n");
		exit(1);
	}
	free(buffer);

	//sending message
	buffer = MDW_marshall(msg);
	flag = sendto(clientSocket, buffer, msg_size_int, 0, (struct sockaddr *) &serverAddr, addr_size);
	if(flag == -1)
	{
		printf("ERROR sending data.\n");
		exit(1);
	}
	free(buffer);
	
	//receiving message size
	flag = recvfrom(clientSocket, msg_size, MAX_MSG_SIZE, 0, (struct sockaddr *) &serverAddr, &addr_size);
	if(flag == -1)
	{
		printf("ERROR receiving data.\n");
		exit(1);
	}
	MDW_unmarshall(msg_size);
	msg_size_int = atoi(msg_size);

	//allocating message's space
	buffer = (char*) malloc(sizeof(char)*(msg_size_int));
	if (buffer == NULL)
	{
		printf("out of memmory\n!");
		exit(1);
	}

	//receiving message
	flag = recvfrom(clientSocket, buffer, msg_size_int, 0, (struct sockaddr *) &serverAddr, &addr_size);
	if(flag == -1)
	{
		printf("ERROR receiving data.\n");
		exit(1);
	}
	MDW_unmarshall(buffer);

	printf("Data received...\nClosing socket...\n");
	shutdown(clientSocket, SHUT_RDWR);

	return buffer;
}
/******************/