#define port_controller 9887
#define port_sparky 9886
//#define K_SERVER_NAME "johnandbrendan.com"
//#define K_SERVER_NAME "192.168.1.133"
#define K_SERVER_NAME "192.168.1.118"


int process_command(char *input, char *input_this, int len, char *this_command);

int open_socket(int port);
int accept_connect(int sock);
int connect_server(int port);
int connect_server_ex(int port, char *server_name);


