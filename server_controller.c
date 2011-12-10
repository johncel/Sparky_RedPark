
/*

server_controller.c

allow tcp connections on port 9887 and 9886

9887 - for controller -- reads commands from SparkyController Cocoa 
9886 - for sparky receiver -- sends commands to sparky_listen on Sparky

*/

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

#include "sparky_utils.h"

#define MAX_CONNECTIONS 1024

//#define DASHBOARD_PATH "/Users/johncelenza/Sites/dashboard.html"
#define DASHBOARD_PATH "/web/htdocs/johncelenza.com/dashboard.html"

enum SOCKET_TYPE { kCONTROLLER_SOCKET, kSPARKY_SOCKET };

//session info data structure -- keep info on the session between a robot and driver
struct session_info {
	int controller_socket;
	int sparky_socket;
	char username[1024];
	char password[1024];
};


struct session_info sessions[MAX_CONNECTIONS];
int num_sessions = 0;
int select_sockets[MAX_CONNECTIONS*2];
int num_socks = 0;
fd_set socks;
int highsock;

void dumpSessions(char *message)
{
	fprintf(stderr,"%s num_sessions:%d\n", message, num_sessions);
	int i;
	for (i = 0; i < num_sessions; i++)
	{
		fprintf(stderr,"%s:: i:%d controller_socket:%d sparky_socket:%d username:%s password:%s\n", message, i, sessions[i].controller_socket, sessions[i].sparky_socket, sessions[i].username, sessions[i].password);
	}
}

void dumpDashboard()
{
	char htmlname[1024];
	char htmlnametemp[1024];

	sprintf(htmlname,"%s", DASHBOARD_PATH);
	sprintf(htmlnametemp,"%s.tmp", htmlname);

	FILE *html = fopen(htmlnametemp,"w");

	fprintf(html, "<html>\n");
	fprintf(html, "<head>\n");
	fprintf(html, "        <title>Sparky Status</title>\n");
	fprintf(html, "		<meta http-equiv=\"Refresh\" content=\"2;URL=dashboard.html\" /> \n");

	fprintf(html, "</head>\n");
	fprintf(html, "<body>\n");
	fprintf(html, "<h1>Sparky Status</h1>\n");
	fprintf(html, "<table>\n");
	fprintf(html, "<tr style=\"font-weight:bold;\">\n");
	fprintf(html, "        <td>Username</td><td>Type</td><td>Socket</td>\n");
	fprintf(html, "</tr>\n");
	int i = 0;
	for (i = 0; i < num_sessions; i++)
	{
		char typestr[1024];
		int this_socket = -1;

		if (sessions[i].controller_socket >= 0)
		{
			this_socket = sessions[i].controller_socket;
			strcpy(typestr,"CONTROLLER");
		}
		else if (sessions[i].sparky_socket >= 0)
		{
			this_socket = sessions[i].sparky_socket;
			strcpy(typestr,"SPARKY");
		}
		else
			strcpy(typestr,"UNUSED");

		fprintf(html,"<tr><td>%s</td><td>%s</td><td>%d</td></tr>\n", sessions[i].username, typestr, this_socket);
	}
	fprintf(html, "</table>\n");
	fprintf(html, "download:<a href=\"SparkyController.dmg\">dmg</a>\n");
	fprintf(html, "</body>");
	fprintf(html, "</html>\n");

	fclose(html);
	rename(htmlnametemp, htmlname);
}

void dumpSession(char *message, int j)
{
	fprintf(stderr,"%s num_sessions:%d\n", message, num_sessions);
	int i;
	for (i = 0; i < num_sessions; i++)
	{
		if (i==j)
			fprintf(stderr,"%s:: i:%d controller_socket:%d sparky_socket:%d username:%s password:%s\n", message, i, sessions[i].controller_socket, sessions[i].sparky_socket, sessions[i].username, sessions[i].password);
	}
}

void initSessionInfo()
{
	int i;

	for (i = 0; i < MAX_CONNECTIONS; i++)
	{
		sessions[i].controller_socket = -1;
		sessions[i].sparky_socket = -1;
	}
}

int findSessionByControllerSocket(int controller_socket)
{
	int i;

	for (i = 0; i < num_sessions; i++)
	{
		if (sessions[i].controller_socket == controller_socket)
		{
			dumpSession("findSessionByControllerSocket found",i);
			return i;	
		}
	}

	return -1;
}

int findSessionBySparkySocket(int sparky_socket)
{
	int i;

	for (i = 0; i < num_sessions; i++)
	{
		if (sessions[i].sparky_socket == sparky_socket)
		{
			dumpSession("findSessionBySparkySocket found",i);
			return i;	
		}
	}

	return -1;
}


int findSessionByUsernamePassword(char *username, char *password, enum SOCKET_TYPE type, int last_socket)
{
	int i;

fprintf(stderr,"findSessionByUsernamePassword:: username:%s password:%s type:%d\n  kSPARKY_SOCKET:%d",username, password, (int)type, (int)kSPARKY_SOCKET);

	for (i = last_socket; i < num_sessions; i++)
	{
		if (!strcmp(username, sessions[i].username) && !strcmp(password, sessions[i].password))
		{
			if (type == kCONTROLLER_SOCKET && sessions[i].controller_socket >= 0)
			{
				dumpSession("findSessionByUsernamePassword found",i);
				return i;	
			}
			else if (type == kSPARKY_SOCKET && sessions[i].sparky_socket >= 0)
			{
				dumpSession("findSessionByUsernamePassword found",i);
				return i;	
			}
		}
	}

	return -1;
}

int findFreeSession()
{
	int i;

	for (i = 0; i < num_sessions; i++)
	{
		if (sessions[i].controller_socket == -1 && sessions[i].sparky_socket == -1)
		{
			sessions[i].username[0] = 0;
			sessions[i].password[0] = 0;
			return i;	
		}
	}

	if (num_sessions < MAX_CONNECTIONS)
	{
		num_sessions++;
		return num_sessions - 1;
	}
}

int checkAuth(int session_id, int index)
{
	if (!strlen(sessions[session_id].username))
	{
		fprintf(stderr,"checkAuth:: username blank\n");
		return 0;
	}
	else if (strcmp(sessions[session_id].username, sessions[index].username))
	{
		fprintf(stderr,"checkAuth:: usernames don't match %s to %s\n", sessions[session_id].username, sessions[index].username);
		return 0;
	}
	else if (strcmp(sessions[session_id].password, sessions[index].password))
	{
		fprintf(stderr,"checkAuth:: passwords don't match %s to %s\n", sessions[session_id].password, sessions[index].password);
		return 0;
	}

	return 1;
};


void build_select_list() {
//	int listnum;	     /* Current item in connectlist for for loops */

	/* First put together fd_set for select(), which will
	   consist of the sock veriable in case a new connection
	   is coming in, plus all the sockets we have already
	   accepted. */
	
	
	/* FD_ZERO() clears out the fd_set called socks, so that
		it doesn't contain any file descriptors. */
	
	FD_ZERO(&socks);
	
	/* FD_SET() adds the file descriptor "sock" to the fd_set,
		so that select() will return if a connection comes in
		on that socket (which means you have to do accept(), etc. */
	
	//FD_SET(sock,&socks);
	
	/* Loops through all the possible connections and adds
		those sockets to the fd_set */
	
	int i;
	num_socks = 0;
	for (i = 0; i < num_sessions; i++) {
		if (sessions[i].controller_socket >= 0)
		{
			FD_SET(sessions[i].controller_socket, &socks);
			select_sockets[num_socks] = sessions[i].controller_socket;
fprintf(stderr,"build_select_list adding controller_socket:%d\n",sessions[i].controller_socket);
			if (sessions[i].controller_socket > highsock)
				highsock = sessions[i].controller_socket;
			num_socks++;
		}
		if (sessions[i].sparky_socket >= 0)
		{
			FD_SET(sessions[i].sparky_socket, &socks);
			select_sockets[num_socks] = sessions[i].sparky_socket;
fprintf(stderr,"build_select_list adding sparky_socket:%d\n",sessions[i].sparky_socket);
			if (sessions[i].sparky_socket > highsock)
				highsock = sessions[i].sparky_socket;
			num_socks++;
		}
	}
}

void clear_bad_filedescriptor (void)
{
	int i;
	for (i = 0; i < num_sessions; i++) {
		if (sessions[i].controller_socket >= 0 && fstat(sessions[i].controller_socket) == -1)
		{
			sessions[i].controller_socket = -1;	
			sessions[i].username[0] = 0;
			sessions[i].password[0] = 0;
		}
		if (sessions[i].sparky_socket >= 0 && fstat(sessions[i].sparky_socket) == -1)
		{
			sessions[i].sparky_socket = -1;	
			sessions[i].username[0] = 0;
			sessions[i].password[0] = 0;
		}
	}
}


extern int errno;
int controller_socket = -1;
int sparky_socket = -1;

int main(int argc, char **argv)
{
	char controller_input[4096];

	struct sigaction ignore_sigpipe;
	struct sigaction old_sigpipe;

	initSessionInfo();

	//we want to ignore SIGPIPE, because closed connections will trigger SIGPIPE and we want to simply trash those connections
    	ignore_sigpipe.sa_handler = SIG_IGN;
    	sigaction(SIGPIPE,&ignore_sigpipe,&old_sigpipe);


	// make the sockets
	controller_socket = open_socket(port_controller);;
	sparky_socket = open_socket(port_sparky);

	//listen to a controller loop
	char input_controller[1024];

	int client_controller = -1;
	int client_sparky = -1;

	input_controller[0] = 0;
	while (1)
	{
dumpDashboard();
fprintf(stderr,"SERVER_CONTROLLER :: BEFORE READ ***********************\n");
fprintf(stderr,".");
		//try to rebind if we are not bound
		if (controller_socket < 0)
			controller_socket = open_socket(port_controller);
		if (sparky_socket < 0)
			sparky_socket = open_socket(port_sparky);

		if (!controller_socket || !sparky_socket)
		{
fprintf(stderr,"missing sockets controller_socket:%d spakry_socket:%d\n",controller_socket, sparky_socket);
			usleep(1000000);
			continue;
		}

		//accept a connection if there is no connection right now
//JJC SELECT add code here to connect into data structure
		//if (client_controller < 0)
		{
			client_controller = accept_connect(controller_socket);
			if (client_controller >= 0)
			{
				int session = findFreeSession();
				if (session >= 0)
					{
						sessions[session].controller_socket = client_controller;
						char str[1024];
						char username[1024];
						char password[1024];
						str[0] = 0;
						int bytes = read(client_controller, str, 1024);
fprintf(stderr,"client_controller:%d bytes read:%d str:%s\n", client_controller, bytes, str);
						if (bytes > 0 && sscanf(str,"username:%[^,],password:%[^|]", username, password)==2)
						{
							fprintf(stderr,"got username:%s password:%s for client_controller:%d session_id:%d \n", username,password,client_controller, session);
							strcpy(sessions[session].username, username);
							strcpy(sessions[session].password, password);
						}
					}
				else
					fprintf(stderr,"ERROR: could not find free session for client_controller:%d\n", client_controller);
dumpSessions("after accept_connect");
			}
		}
		//if (client_sparky < 0)
		{
			client_sparky = accept_connect(sparky_socket);
			if (client_sparky >= 0)
			{
				int session = findFreeSession();
				if (session >= 0)
				{
					sessions[session].sparky_socket = client_sparky;
					char str[1024];
					char username[1024];
					char password[1024];
					str[0] = 0;
					int bytes = read(client_sparky, str, 1024);
				
fprintf(stderr,"client_sparky:%d bytes read:%d str:%s\n", client_sparky, bytes, str);
					if (bytes > 0 && sscanf(str,"username:%[^,],password:%[^|]", username, password)==2)
					{
						fprintf(stderr,"got username:%s password:%s for client_sparky:%d session_id:%d \n", username,password,client_sparky, session);
						strcpy(sessions[session].username, username);
						strcpy(sessions[session].password, password);
					}
				}
				else
					fprintf(stderr,"ERROR: could not find free session for client_sparky:%d\n", client_sparky);
			}
		}


//JJC SELECT add code here to select and see if any socket is read or writable
//  call function to read username,password combo, and update data structures
		dumpSessions("build_select_list");
		build_select_list();
		//perform select
		struct timeval timeout;
		timeout.tv_sec = 0;
		timeout.tv_usec = 100000;

		int session_id = -1;
		
		/* The first argument to select is the highest file
			descriptor value plus 1. In most cases, you can
			just pass FD_SETSIZE and you'll be fine. */
			
		/* The second argument to select() is the address of
			the fd_set that contains sockets we're waiting
			to be readable (including the listening socket). */
			
		/* The third parameter is an fd_set that you want to
			know if you can write on -- this example doesn't
			use it, so it passes 0, or NULL. The fourth parameter
			is sockets you're waiting for out-of-band data for,
			which usually, you're not. */
		
		/* The last parameter to select() is a time-out of how
			long select() should block. If you want to wait forever
			until something happens on a socket, you'll probably
			want to pass NULL. */
		
		int readsocks = select(highsock+1, &socks, (fd_set *) 0, 
		  (fd_set *) 0, &timeout);
		//walk fd_set if something changed
		if (readsocks < 0) {
			//perror("select");
			//exit(1);
			fprintf(stderr,"found bad file descriptor...\n");
			clear_bad_filedescriptor();	
			
		}
		if (readsocks == 0) {
			/* Nothing ready to read, just show that
			   we're alive */
			//printf(".");
			fprintf(stderr,"nothing to see here\n");
		} 
		else
		{
			int i;
			//find which socket had a state change
			for (i = 0; i < num_socks; i++)
			{
				client_controller = -1;
fprintf(stderr,"SELECT:: testing socket %d\n", select_sockets[i]);
				if (FD_ISSET(select_sockets[i],&socks))
				{
					int cci = findSessionByControllerSocket(select_sockets[i]);
					if (cci >= 0)
					{
						client_controller = sessions[cci].controller_socket;
						session_id = cci;
					}
					
					//try reading for sparky to get username password commands
					int tclient_sparky = -1;
					int si = findSessionBySparkySocket(select_sockets[i]);
					if (si >= 0)
						tclient_sparky = sessions[si].sparky_socket;
fprintf(stderr,"SELECT:: YES  socket %d client_controller:%d tclient_sparky:%d\n", select_sockets[i], client_controller, tclient_sparky);
					if (tclient_sparky > 0)
					{
fprintf(stderr,"trying to read from sparky_socket:%d session_id:%d\n", tclient_sparky, si);
						char str[1024];
						char username[1024];
						char password[1024];
						int bytes = read(tclient_sparky, str, 1024);
						if (bytes > 0 && sscanf(str,"username:%[^,],password:%[^|]", username, password)==2)
						{
							fprintf(stderr,"got username:%s password:%s for tclient_sparky:%d session_id:%d \n", username,password,tclient_sparky, session_id);
							strcpy(sessions[si].username, username);
							strcpy(sessions[si].password, password);
						}
					}
				
				}
				

				//try reading from the controller
				if (client_controller >= 0)
				{
					char controller_input_this[1024];
					char next_command[1024];
					char sparky_input_this[1024];
					int bytes = 0;

					fprintf(stderr,".");
					//perform a write test
					bytes = write(client_controller, ".", 1);
					if (bytes <= 0)
					{
						if (errno != EAGAIN)
						{
							char error_message[1024];
							fprintf(stderr,"detected controller disconnect\n");
							close(client_controller);
							int cci = findSessionByControllerSocket(client_controller);
							sessions[cci].controller_socket = -1;
							//exit(0);
							client_controller = -1;
							perror(error_message);
							fprintf(stderr,"perror:%s\n",error_message);
						}
					}

					controller_input_this[0] = 0;
read_more:
					bytes = read(client_controller, controller_input_this, 1024);

					if (bytes <= 0)
					{
						if (errno != EAGAIN)
						{
							char error_message[1024];
							fprintf(stderr,"detected controller disconnect\n");
							close(client_controller);
							//exit(0);
							int cci = findSessionByControllerSocket(client_controller);
							sessions[cci].controller_socket = -1;
							client_controller = -1;
							perror(error_message);
							fprintf(stderr,"perror:%s\n",error_message);
						}
					}

					if (bytes > 0)
					{
						controller_input_this[bytes] = 0;
						if (strlen(controller_input_this))
							fprintf(stderr,"controller_received: %s\n",controller_input_this);

						//process any input
						while (process_command(controller_input, controller_input_this, bytes, next_command) && strlen(next_command) > 1)
						{
							char username[1024], password[1024];
							if (sscanf(next_command,"username:%[^,],password:%[^|]", username, password)==2)
							{
								fprintf(stderr,"got username:%s password:%s for client_controller:%d session_id:%d \n", username,password,client_controller, session_id);
								strcpy(sessions[session_id].username, username);
								strcpy(sessions[session_id].password, password);
								controller_input_this[0] = 0;
								continue;	
							}
							fprintf(stderr, "controller got command %s\n",next_command);
							int index = -1;
							write_sparky:
							index = findSessionByUsernamePassword(sessions[session_id].username, sessions[session_id].password,kSPARKY_SOCKET, index+1);
							client_sparky = -1;
							//check auth
							if (index >= 0 && checkAuth(session_id, index))
								client_sparky = sessions[index].sparky_socket;
							if (client_sparky >= 0)
							{
								char next_command_pipe[1024];
								sprintf(next_command_pipe,"%s|",next_command);
								fprintf(stderr,"sending command:%s to sparky len:%d\n",next_command_pipe,(int)strlen(next_command_pipe));
								int written = write(client_sparky, next_command_pipe, strlen(next_command_pipe));
								if (errno != EAGAIN && written < 0)
								{
									fprintf(stderr,"detected sparky disconnect errno:%d bytes:%d\n",errno,written);
									int cci = findSessionByControllerSocket(client_sparky);
									if (cci >= 0)
										sessions[cci].sparky_socket = -1;
									close(client_sparky);
									//exit(0);
									client_sparky = -1;
								}

								//read status from sparky
								{
									int bytes = read(client_sparky, sparky_input_this, 1024);
									if (bytes > 0)
									{
										sparky_input_this[bytes] = 0;
										fprintf(stderr,"sparky status:%s",sparky_input_this);
									}
								}

							}
							controller_input_this[0] = 0;
							//if (index >= 0)
								//goto write_sparky;

						}



						goto read_more;
					}
				}
			}
		}
fprintf(stderr,"server_controller::::: GOING TO SLEEP *************]\n\n");
fflush(stderr);
		if (client_sparky < 0 || client_controller < 0)
			usleep(100000);
		else
			usleep(100000);
fprintf(stderr,"server_controller::::: AFTER SLEEP *************]\n\n");
			//usleep(10000);
	}

	return 0;
}

