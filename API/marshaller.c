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
	int iaux;

	iaux = strlen(str)-1;
	if(str[iaux] == (char) 1)
	{//everything is all right, go on
		str[iaux] = '\0';
	}else{
		printf("marshalling!\n");
		for(iaux = 0; str[iaux] != '\0'; iaux++)
		{
			str[iaux] = ((str[iaux] & 0xF0) >> 4) | ((str[iaux] & 0x0F) << 4);
			str[iaux] = ((str[iaux] & 0xCC) >> 2) | ((str[iaux] & 0x33) << 2);
			str[iaux] = ((str[iaux] & 0xAA) >> 1) | ((str[iaux] & 0x55) << 1);
		}
		if(str[iaux] == (char) 1)
			printf("marshalling error!\n");
	}
}
/******************/