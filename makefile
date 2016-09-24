CC=gcc
CFLAGS=-O3
LUALIB= -L /lua/ -llua -lm -ldl
INCLUDES=luaAPI.h tcpSocket.h -I lua/
OBJ=lsAuxLib.o luaAPI.o tcpSocket.o clientApp.o

build: $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -o clientApp $(LUALIB)


lsAuxLib.o:
	$(CC) $(CFLAGS) $(INCLUDES) -fPIC -c lsAuxLib.c

luaAPI.o:
	$(CC) $(CFLAGS) $(INCLUDES) -fPIC -c luaAPI.c

tcpSocket.o:
	$(CC) $(CFLAGS) $(INCLUDES) -fPIC -c tcpSocket.c

clientApp.o:
	$(CC) $(CFLAGS) $(INCLUDES) -fPIC -c clientApp.c

clean:
	rm -f -v ./*.o ./*.h.gch

remove:
	rm -f -v ./*.o ./*.h.gch clientApp