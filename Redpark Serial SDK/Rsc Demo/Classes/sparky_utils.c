#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <signal.h>
#include <fcntl.h>
#include <errno.h>

char SERVER_NAME[1024];

/*
	process_command
	
	pull off full commands from strings coming in over tcp

	|comand|

	@param $controller_input -- the remaining data from last read
	@param $controller_input_this -- new text to add

*/
int process_command(char *input, char *input_this, int len, char *this_command)
{
	char *pos;
	char buf[4096];
	int input_len = strlen(input);

fprintf(stderr,"process_command input:%s input_this:%s\n",input,input_this);

	this_command[0] = 0;

	if (strlen(input_this))
		strcat(input, input_this);

	input[len+input_len] = 0;

	strcpy(buf, input);

	//do we have enough in input to pull off a command?
	if ((pos = strstr(buf,"|")))
	{
		sscanf(buf,"%[^|]",this_command);
		strcpy(input,(pos+1));
		fprintf(stderr,"input now:%s this_command:%s\n",input,this_command);
	}

	return 1;
}

/*
	open_socket 

	open socket on a PORT`
*/
int open_socket(int port)
{
int         i;
int err, len;
int fd;
int         s;
int result = -1;
struct sockaddr_in serv;

fprintf(stderr,"open_socket:: port %d\n", port);
/*
 * Create a socket 
 */
	s = socket(AF_INET,SOCK_STREAM, 0);
if (s < 0) {
   fprintf(stderr," cannot open socket for port %d\n", port);
   return -1;
   }
memset((char *) &serv, 0, sizeof(serv));
//serv.sin_addr.s_addr = htonl(INADDR_ANY);
serv.sin_family = AF_INET;
serv.sin_port = htons(port);
/*
* Bind socket 
*/
   err = bind(s, (struct sockaddr *) & serv, sizeof(serv));
   if (err < 0){
	fprintf(stderr,"can not bind\n");
	close(s);
	return -1;
	}

	fprintf(stderr,"bound!\n");

	result = listen(s, 1);

	if (result < 0)
	{
		char error_msg[1024];

		perror(error_msg);
		fprintf(stderr,"listen error:%s\n",error_msg);
	}
	else
	{
		fprintf(stderr,"listening!\n");
	}

        fcntl(s, F_SETFL,O_NONBLOCK);

	return s;
}

/*
	accept_connect

	accept a connection for a socket

*/
int accept_connect(int sock)
{
	int err;
	socklen_t len;
	struct sockaddr_in inet;
	int fd = -1;

fprintf(stderr,"accept_connect:: sock:%d\n",sock);

	memset((char *) &inet, 0, sizeof(inet));
	len = sizeof(inet);
	inet.sin_addr.s_addr = 0;
	fd = accept(sock, (struct sockaddr *) & inet, &len);
	if (fd < 0) {
		char error_msg[1024];
		perror(error_msg);	
		fprintf(stderr,"accept_connect:: no one sock:%d %s\n",sock,error_msg);

		
		
   		return -1;
   		}
	else
		fprintf(stderr,"accept_connect:: connected to socket\n");
	err = ioctl(fd, FIONBIO, &len);
	return fd;
}

int connect_server(int port)
{
    if (strlen(SERVER_NAME))
        return connect_server_ex(port,SERVER_NAME);
    else
        return -1;
}

/*
        connect_server

        open socket on a server`
*/
int connect_server_ex(int port, char *server_name)
{
        struct hostent *server;
        struct sockaddr_in socket_in;
        int result = -1;
        
        int sock;
        
        sock = socket(AF_INET,SOCK_STREAM, 0);
        //fcntl(sock, F_SETFL,O_NONBLOCK);

        
        bzero((char *) &socket_in, sizeof(socket_in));
        server = gethostbyname(server_name);
        
        socket_in.sin_family = AF_INET;
        socket_in.sin_port = htons(port);
            bcopy((char *)server->h_addr,
                (char *)&socket_in.sin_addr.s_addr,
                server->h_length);
    fcntl(sock, F_SETFL,O_NONBLOCK);    

            result = connect (sock, (struct sockaddr *)&socket_in, sizeof(socket_in));
    /*
    perror("perror");
    fprintf(stderr, "connect_server_ex sock:%d result:%d\n",sock,result);
	if (result<0)
    {
        
        close(sock);
        
		return -1;
    
    }
     */
    fcntl(sock, F_SETFL,O_NONBLOCK);    
        return sock;
}

