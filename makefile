CC=gcc
CFLAGS=-O3
LUALIB= -L /lua/ -llua -lm -ldl
INCLUDES=luaAPI.h tcpSocket.h -I lua/
OBJ=lsAuxLib.o luaAPI.o tcpSocket.o

build: $(OBJ) clientApp.o serverApp.o
	$(CC) $(CFLAGS) $(OBJ) clientApp.o -o clientApp $(LUALIB)
	$(CC) $(CFLAGS) $(OBJ) serverApp.o -o serverApp $(LUALIB)


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