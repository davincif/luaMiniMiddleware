CC=gcc
CFLAGS=-O3
CLIENT_INCLUDES = client.h marshaller.h
CLIENT_OBJ = marshaller.o client.o clientApp.o
SERVER_INCLUDES = server.h marshaller.h
SERVER_OBJ = marshaller.o server.o application.o

build: $(CLIENT_OBJ) $(SERVER_OBJ)
	$(CC) $(CFLAGS) $(CLIENT_INCLUDES) $(CLIENT_OBJ) -o clientApp
	$(CC) $(CFLAGS) $(SERVER_INCLUDES) $(SERVER_OBJ) -o application

_client: $(CLIENT_OBJ)
	$(CC) $(CFLAGS) $(CLIENT_INCLUDES) $(CLIENT_OBJ) -o clientApp

_server: $(SERVER_OBJ)
	$(CC) $(CFLAGS) $(SERVER_INCLUDES) $(SERVER_OBJ) -o application

marshaller.o:
	$(CC) $(CFLAGS) $(CLIENT_INCLUDES) -fPIC -c marshaller.c

clientApp.o: client.o
	$(CC) $(CFLAGS) $(CLIENT_INCLUDES) -fPIC -c clientApp.c

client.o:
	$(CC) $(CFLAGS) $(CLIENT_INCLUDES) -fPIC -c client.c


application.o: server.o
	$(CC) $(CFLAGS) $(SERVER_INCLUDES) -fPIC -c application.c

server.o:
	$(CC) $(CFLAGS) $(SERVER_INCLUDES) -fPIC -c server.c


clean:
	rm -f -v ./*.o ./*.h.gch

remove:
	rm -f -v ./*.o ./*.h.gch clientApp application