#include "marshaller.h"

/*GLOBAL FUNCTIONS*/
char* ls_marshall(char *str)
{
	char *newstr;
	int aux;

	aux = strlen(str);
	newstr = (char*) malloc(sizeof(char)*aux+2); //+1 for the (char) 1 and +1 for the '\0'
	if(newstr == NULL)
	{
		newstr = NULL;
	}else{
		strcpy(newstr, str);
		newstr[aux] = (char) 1;
		newstr[aux+1] = '\0';
	}

	return newstr;
}

void ls_unmarshall(char *str)
{
	int aux;

	aux = strlen(str)-1;
	if(str[aux] == (char) 1)
	{//everything is all right, go on
		str[aux] = '\0';
	}else{
		//houston, we have a problem.
		printf("unmarshalling error!\n");
	}
}
/******************/