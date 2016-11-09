CC=gcc
CFLAGS=-O3
LUALIB=-L ./lua/ -llua -lm -ldl
INCLUDES=luaAPI.h tcpSocket.h -I lua/
OBJ=lsAuxLib.o marshaller.o luaAPI.o tcpSocket.o

build: $(OBJ) clientApp.o serverApp.o dnsApp.o queueServerApp.o
	$(CC) $(CFLAGS) $(OBJ) clientApp.o -o ../clientApp $(LUALIB)
	$(CC) $(CFLAGS) $(OBJ) serverApp.o -o ../serverApp $(LUALIB)
	$(CC) $(CFLAGS) $(OBJ) dnsApp.o -o ../dnsApp $(LUALIB)
	$(CC) $(CFLAGS) $(OBJ) queueServerApp.o -o ../queueServerApp $(LUALIB)
	make clean


lsAuxLib.o:
	$(CC) $(CFLAGS) $(INCLUDES) -fPIC -c lsAuxLib.c

luaAPI.o:
	$(CC) $(CFLAGS) $(INCLUDES) -fPIC -c luaAPI.c

marshaller.o:
	$(CC) $(CFLAGS) $(INCLUDES) -fPIC -c marshaller.c

tcpSocket.o:
	$(CC) $(CFLAGS) $(INCLUDES) -fPIC -c tcpSocket.c

clientApp.o:
	$(CC) $(CFLAGS) $(INCLUDES) -fPIC -c clientApp.c

serverApp.o:
	$(CC) $(CFLAGS) $(INCLUDES) -fPIC -c serverApp.c

dnsApp.o:
	$(CC) $(CFLAGS) $(INCLUDES) -fPIC -c dnsApp.c

queueServerApp.o:
	$(CC) $(CFLAGS) $(INCLUDES) -fPIC -c queueServerApp.c

clean:
	rm -f -v ./*.o ./*.h.gch

remove:
	rm -f -v ./*.o ./*.h.gch ../clientApp ../serverApp ../dnsApp ../queueServerApp