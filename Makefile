CC = gcc
LD = gcc
LDFLAGS  =  -g
CPPFLAGS =     -DTRUE=1 -DFALSE=0 -DNULL=0 -g
prefix = /usr/local

#all: test mitm rfcomm inquiry l2cap-server l2cap-throughput
all: server_controller 

server_controller: server_controller.o sparky_utils.o $(OBJS) $(POBJS)
	$(LD) server_controller.o sparky_utils.o -lm -o server_controller $(LDFLAGS) $(DEBUGFLAGS) $(OBJS) $(POBJS)

sparky_listen: sparky_listen.o $(OBJS) sparky_utils.o$(POBJS)
	$(LD) sparky_listen.o sparky_utils.o -lm -o sparky_listen $(LDFLAGS) $(DEBUGFLAGS) $(OBJS) $(POBJS)

.c.o:
	$(CC) $(INCLUDES) -c $(INCDIRS) $(CPPFLAGS) $(DEBUGFLAGS) $*.c 

clean:
	rm *.o $(all)

