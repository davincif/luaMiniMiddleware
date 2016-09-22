#include "client.h"

/*GLOBAL FUNCTIONS*/
char* MDW_crh(char *serverHost, int serverPort, char *msg) /*IP, port and msn to send*/
{
	int clientSocket, msg_size_int;
	char *buffer, msg_size[MAX_MSG_SIZE];
	struct sockaddr_in serverAddr;
	socklen_t addr_size;

	//socket creating
	clientSocket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);

	//connecting
	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port = htons(serverPort);
	serverAddr.sin_addr.s_addr = inet_addr(serverHost);
	memset(serverAddr.sin_zero, '\0', sizeof serverAddr.sin_zero);
	addr_size = sizeof(serverAddr);
	connect(clientSocket, (struct sockaddr *) &serverAddr, addr_size);

	//calculating and sending message size
	msg_size_int = strlen(msg)+1; //+1 -> +'1' do marshaller
	if(msg_size_int > pow(10, MAX_MSG_SIZE-1)-1)
	{
		printf("ERROR: message is too big!\n");
		exit(1);
	}
	sprintf(msg_size, "%d", msg_size_int);
	buffer = MDW_marshall(msg_size);
	send(clientSocket, buffer, MAX_MSG_SIZE, 0);
	free(buffer);

	//sending message
	buffer = MDW_marshall(msg);
	send(clientSocket, buffer, msg_size_int, 0);
	free(buffer);

	//receiving message size
	recv(clientSocket, msg_size, MAX_MSG_SIZE, 0);
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
	recv(clientSocket, buffer, msg_size_int, 0);
	MDW_unmarshall(buffer);

	//close socket
	shutdown(clientSocket, SHUT_RDWR);	

	return buffer;
}
/******************/