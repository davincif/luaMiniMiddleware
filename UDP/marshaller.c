#include "marshaller.h"

/*GLOBAL FUNCTIONS*/
char* MDW_marshall(char *str)
{
	char *newstr;

	newstr = (char*) malloc(sizeof(char)*(strlen(str))+2);
	if(newstr == NULL)
	{
		printf("out fo memory\n");
		exit(1);
	}

	strcpy(newstr, str);
	newstr[strlen(newstr)] = (char) 1;
	return newstr;
}

void MDW_unmarshall(char *str)
{
	if(str[strlen(str)-1] == (char) 1)
	{//everything is all right, go on
		str[strlen(str)-1] = '\0';
	}else{
		//houston, we have a problem.
		printf("unmarshalling error!\n");
	}
}
/******************/