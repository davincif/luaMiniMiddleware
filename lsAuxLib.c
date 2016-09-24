#include "lsAuxLib.h"

/*GLOBAL FUNCTIONS*/
void stoupper(char *str)
{
	int i;

	for(i = 0; str[i] != '\0'; i++)
		str[i] = (char) toupper((int) str[i]);
}
/******************/