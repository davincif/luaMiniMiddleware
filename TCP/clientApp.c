#include <stdio.h>
#include <stdlib.h>

#include "client.h"

typedef enum bool
{
	false = 0, true = 1
} bool;

char ip[16];
int port;

void hold_args(int argc, char const *argv[])
{
	int i;
	char *aux;
	bool arg_invalid = true;

	if(argc <= 1)
	{
		printf("No argumens...\n");
		printf("\t-port=x\n");
		printf("if you do not specify an ip I'll assume it's localhost. But if you do want, try:\n");
		printf("\t-ip=x.x.x.x\n");
		exit(1);
	}

	for(i = 2; i <= argc; i++)
	{
		aux = strstr(argv[i-1], "-ip=");
		if(aux != NULL)
		{
			if(*(aux+4) < '0' && *(aux+4) > '9' && strcmp((aux+4), "localhost"))
			{
				printf("Error, ip not recognized.\n");
				printf("Try using an IP adress with number or \"localhost\", or just leave it alone.\n");
				exit(1);
			}
			strcpy(ip, (aux+4));
			arg_invalid = false;
		}

		aux = strstr(argv[i-1], "-port=");
		if(aux != NULL && arg_invalid == true)
		{
			port = atoi(argv[i-1]+6);
			if(port == 0)
			{
				printf("Error, port \"%s\" not valid. Got 0(zero)\n", argv[i-1]+6);
				exit(1);
			}

			arg_invalid = false;
		}

		if(arg_invalid == true)
		{
			printf("Error, argument \"%s\"  not recognized.\n", argv[i-1]);
			exit(1);
		}
	}

	if(port == 0)
	{
		printf("Error, missing port definition\n");
		exit(1);
	}

	if(ip[0] == '\0')
		strcpy(ip, "127.0.0.1");
}

int main(int argc, char const *argv[])
{
	char *answer;

	hold_args(argc, argv);

	answer = MDW_crh(ip, port, "FUIAT!");
	printf("Data received: %s\n", answer);


	return 0;
}