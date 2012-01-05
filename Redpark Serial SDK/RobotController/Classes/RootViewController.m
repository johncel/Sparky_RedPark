//
//  RootViewController.m
//  Rsc Demo
//
//  Copyright © 2011 Redpark  All Rights Reserved
//

#import "RootViewController.h"
#import "DashViewController.h"
#import "SelectionViewController.h"
#import "EditFieldViewController.h"
#import "RscMgr.h"
#import "Rsc_DemoAppDelegate.h"

#import "sparky_utils.h"
#import "createoi.h"

short max_accel = 64;
short max_accel_rad = 2;
#define kMAXVEL 1000 //maximum velocity for iRobot
#define kMINVEL -1000 //maximum reverse velocity for iRobot


 char SERVER_NAME[1024];
char USER_NAME[1024];
char PASSWORD[1024];


enum 
{
	kSectionCableStatus = 0,
	kNumCableStatus = 1,
	kSectionPortConfig = 1,
	kSectionStats = 2,
	kNumStats = 2,
    kSectionServerName=3,
    kDash=4,
	
};


#define MODEM_STAT_ON_COLOR [UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:1.0]
#define MODEM_STAT_OFF_COLOR [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0]
#define MODEM_STAT_RECT CGRectMake(0.0f,0.0f,42.0f,21.0f)

#define TABLE_DATA_PLIST @"PortconfigStrings"

#define CABLE_CONNECTED_TEXT @"Connected";
#define CABLE_NOT_CONNECTED_TEXT @"Not Connected";
#define CABLE_REQUIRES_PASSCODE_TEXT @"Passcode Required"


//libirobot stuff
#define MAX_IROBOT(a,b)        (a > b? a : b)
#define MIN_IROBOT(a,b)        (a < b? a : b)
#define LMIN(a,b)	(a < b? a : b)

//sparky stuff
#define CONTROL_TIMEOUT 4
static NSTimer *sparkyTimer = NULL;
static struct roomba_drive_info *groomba = nil;

@implementation RootViewController
@synthesize updateString;
@synthesize updateProperty;
@synthesize textViewLog;

+(void) initialize
{
    if (! groomba)
        groomba = (struct roomba_drive_info*)calloc(sizeof(struct roomba_drive_info),1);
    
}

+(struct roomba_drive_info) getRoomba
{
    return *groomba; 
}

+(void)setRoomba: (struct roomba_drive_info)newinfo
{
    *groomba = newinfo;
}

#pragma mark -
#pragma mark View lifecycle

int min(int a, int b)
{
    if (a < b)
        return a;
    else
        return b;
}

/** \brief      Drive the robot with a given velocity and turning radius
 *
 *      Drives the Create with the given velocity (mm/s) and turning
 *  radius (mm).  The velocity ranges from -500 to 500mm/s, with
 *  negative velocities making the Create drive backward.  The radius
 *  ranges from -2000 to 2000mm, with positive radii turning the
 *  Create left and negative radii turning it right.
 *
 *      A radius of -1 makes the Create turn in place clockwise and 1
 *      makes it turn in place counter-clockwise.  Also, a radius of 0
 *      will make the Create drive straight.
 *
 *      \param vel The velocity, in mm/s, of the robot 
 *      \param rad The turning radius, in mm, from the center of the
 *      turning circle to the center of the Create.
 *
 *      \return         0 if successful or -1 otherwise
 
           this function applies accelerations accordingly
 */
int drive (uint8_t *data, int *len, short vel, short rad)
{
    byte cmd[5];
    
    static short svel=0;
    static short srad = 0;
    short acceleration;
    short acceleration_rad;
    
    short acceleration_req = vel - svel;
    if (acceleration_req > max_accel)
        acceleration = max_accel;
    else if (acceleration_req < -max_accel)
        acceleration = -max_accel;
    else
        acceleration = acceleration_req;

    /*
    acceleration_req = rad - srad;
    if (acceleration_req > max_accel_rad)
        acceleration_rad = max_accel_rad;
    else if (acceleration_req < -max_accel_rad)
        acceleration_rad = -max_accel_rad;
    else
        acceleration_rad = acceleration_req;
    */
    
    vel = svel + acceleration;
    //rad = srad + acceleration_rad;
    svel = vel;
    //srad = rad;
    
    //keep args within Create limits
    vel = MIN_IROBOT(kMAXVEL, vel);
    vel = MAX_IROBOT(kMINVEL, vel);
    rad = MIN_IROBOT(2000, rad);
    rad = MAX_IROBOT(-2000, rad);
    
    if (0 == rad)   //special case for drive straight (from manual)
        rad = 32768;
    
    cmd[0] = OPCODE_DRIVE;
    cmd[1] = (vel >> 8) & 0x00FF;
    cmd[2] = vel & 0x00FF;
    cmd[3] = (rad >> 8) & 0x00FF;
    cmd[4] = rad & 0x00FF;
    
    *len = 5;
    memcpy(data, cmd, *len);
    
    //pthread_mutex_lock( &create_mutex );
    
    //if (cwrite (fd, cmd, 5) < 0)
    //{
    //perror ("Could not start drive");
    //pthread_mutex_unlock( &create_mutex );
    //return -1;
    //}
    //pthread_mutex_unlock( &create_mutex );
    return 0;
}

void move_dir(uint8_t *data, int *len, char *action)
{
    static float velocity = 0;
    static int speed = 0;//store user input.
    static int turn = 0;
    
    static float radius = 0;
    
    static int charge;
    
    float leftPercent = 0, rightPercent = 0;
    
    //erase();
    //charge = getCharge();
    //printf("Battery Charge: %d%%", charge);
    printf("%f %f", velocity, radius);
    //refresh();
    
    fprintf(stderr,"move_dir:: action:%s\n",action);
    int slider0 = 50;
    int slider1 = 0;
    //move_reverse_reverse0_176_reverse1_176
    char slider0Name[1024];
    char slider1Name[1024];
    
    
    sscanf(action,"move_%*[^_]_%[^_]_%d_%[^_]_%d", slider0Name, &slider0, slider1Name, &slider1);
    
    if (strstr(action,"move_left"))
    {
        //turn =  LMAX(turn + 1, 0);
        radius = 50;
        velocity = slider0;
    }
    else if (strstr(action,"move_right"))
    {
        turn =  LMIN(turn - 1, 0);
        velocity = slider0;
        radius = -50;
    }
    if (strstr(action,"move_straight"))
    {
        if (speed < 0) {
            speed = 0;
            turn = 0;
        } else {
            speed += 50;
        }
        
        velocity = slider0;
        radius = 0;
    }
    else if (strstr(action,"move_reverse"))
    {
        if (speed > 0) {
            speed = 0;
            turn = 0;
        } else {
            speed -= 50;
        }
        velocity = -slider0;
        speed = -slider0;
        radius = 0;
    }
    else if (strstr(action,"stop"))
    {
        speed = 1;
        radius = 1;
        velocity = 0;
    }
    
    fprintf(stderr,"***********check action:%s\n",action);
    if (strstr(action,"move_velocityradius"))
    {
        int min_slider1 = 10;
        //velocity = slider0*2.0;
        velocity = slider0*6.0;
        //radius = slider1/100.0;       
        if (slider1 > min_slider1)
            radius = -1*(101.f - slider1)*10;
        else if (slider1 <= -min_slider1)
            radius = (101.f + slider1)*10;
        else
            radius = 0;
        
        //if (radius > 1 || radius < -1 )
        //      velocity *= (fabs(radius)/10);
        
        fprintf(stderr,"move_velocityradius slider0:%d slider1:%d\n", slider0, slider1);
    }
    //match move_<DIR>_L_<PERCENT>_R_<PERCENT>
    //printf("*************************action:%s\n",action);
    /*
     if (sscanf(action,"move_%*[^_]_L_%f_R_%f", &leftPercent, &rightPercent)==2)
     {
     if(fabs(leftPercent - rightPercent) > 0.1)
     radius = (-1.0/(leftPercent - rightPercent)) * 256.0;
     velocity = ((fabs(leftPercent) + fabs(rightPercent)) / 2.0) * 256.0;
     if ((leftPercent + rightPercent) < 0)
     velocity = -velocity;
     
     
     printf("moving high fidelity radius:%d velocity:%d leftPercent:%.2f rightPercent:%.2f\n",radius, velocity,leftPercent, rightPercent);
     }
     */
    
    if (velocity == 0)
        radius = 0;
    
    printf("drive (velocity=%f, radius=%f\n",velocity, radius);
    groomba->velocity = velocity;
    groomba->radius = radius;
    groomba->slider0 = slider0;
    groomba->slider1 = slider1;
    drive(data, len, velocity, radius);
    
    /*
     else
     {
     fprintf(stderr,"could not understand action:%s\n", action);
     }*/
    
}


int process_command_string(char *command, uint8_t *data, int *len)
{
 //   static HDF *config = NULL;
    //char command[1024];
    char action[1024];
  //  struct stat mystat;
    FILE *in_action = NULL;
    int time_elapsed = 0;
    static time_t last_command_epoch;
    static char last_action[1024];
    static char last_action_last[1024];
    
    static int fudgeCount = 0;
    
    //horn(data,len);
    //return 0;

#if 0
    if (config == NULL)
    {
        last_command_epoch = time(NULL);
        hdf_init(&config);
        hdf_read_file(config, "control.hdf");
        
        strcpy(last_action,"stop");
        
    }
#endif
    
#if 0
    //touch the lock file
    sprintf(command,"touch /tmp/SparkyController.lock; chmod a+rw /tmp/SparkyController.lock");
    system(command);
    
#endif
    *action = 0;
    
#if 0
    if (!stat("/tmp/SparkyController.lock", &mystat))
    {
        in_action=fopen("/tmp/SparkyController.lock","r");
    }
    
    if (in_action)
#endif
    {
        
        strcpy(action,command);
        
        printf("last_action:%s action:%s\n", last_action, action);
        //                      if (strcmp(last_action, action))
        if (strlen(action))
        {
            //printf("file changed or command changed last_action:%s action:%s mystat.st_mtime:%d ?> last_command_epoch:%d \n", last_action, action, (int)mystat.st_mtime, (int)last_command_epoch);
            //echo "setting last_command_epoch".time();
            strcpy(last_action, action);
            last_command_epoch = time(NULL);
            time_elapsed = 0;
            strcpy(last_action_last,"update");
        }
        else
        {
            printf ("SETTING time_elapsed = %d - %d\n", (int)time(NULL), (int)last_command_epoch);
            time_elapsed = time(NULL) - last_command_epoch;
        }
        
        
        
        if (time_elapsed > CONTROL_TIMEOUT && strcmp(action,"stop"))
        {
            
            printf("control timeout: setting stop time_elapsed: %d last_command_epoch:%d time:%d\n",time_elapsed, (int)last_command_epoch, (int)time(NULL));
            strcpy(action, "stop");
#if 0
            if (1)
            {
                FILE *out_action;
                umask(0777);
                
                out_action = fopen("/tmp/SparkyController.lock","w");
                if (out_action)
                {
                    fprintf(out_action,"%s",action);
                    fprintf(out_action,"%d", (int)time(NULL));
                    fclose(out_action);
                }
            }
#endif
            
        }
    }
    
    
    int show_ui = 1;
    //DO MAIN SUMULATION LOOP STUFF HERE
    /*
     
     if (0 != bumper)                                                        //sensor was tripped
     {
     if (1 == bumper)
     {
     drive (120, 1);
     waitAngle (45, 1);
     }
     else if (2 == bumper)
     {
     drive (120, -1);
     waitAngle (-45, 1);
     }
     else if (3 == bumper)
     {
     drive (250, -1);
     waitAngle (-90, 1);
     }
     }
     */
    
    
    
    
    
    
    
    //STOP ON BUMPER
    //TODO SUPPORT QUERY TO IROBOT
    /*
     int angle, tol = 20, bumper = 0;
     bumper = getBumpsAndWheelDrops(writeIROBOT, readIROBOT);
     if (bumper!=0 && !strstr(action,"move_reverse"))
     {
     printf("bump! drive(0,0)\n");
     horn(data, len);
     if (len > 0)
     write(writeIROBOT,data,*len);
     }
     else 
     */
    //if (strlen(action) && strcmp(action, last_action_last))
    
    char taction[1024];
    strcpy(taction,action);
    
    if (!strlen(action) && !strstr("stop",last_action))
    {
        strcpy(action, last_action);
    }
    
    if (strlen(action))
    {
        show_ui = 0;
        //printf("%s\n",action);
        
        //echo "Sending ACTION $action to SC_move_dir\n";
        fprintf(stderr,"move_dir: Sending action:%s\n", action);
//        move_dir(data, len, action,config);
        move_dir(data, len, action);

        if (*len > 0)
        {
            //fprintf(stderr,"writing to fd:%d data:%s len:%d\n", writeIROBOT, data, *len);
            //unsigned char datadebug[1024];
            //datadebug[0] = 128;
            //datadebug[1] = 131;
            //write(writeIROBOT,datadebug,2);
            //TODO HERE
            if (fudgeCount > 10 || 1)
            {
                //JJC WRITE TO SERIAL PORT HERE
//                int res = write(writeIROBOT,data,*len);
                //[self.rscMgr write:data Length:*len];

//                fprintf(stderr,"result:%d writing to fd:%d data:%s len:%d\n", res, writeIROBOT, data, *len);
            }
        }
        //horn();
    }
    strcpy(last_action_last, taction);
    
    
    //printf("loop! last_action_hero:%s\n", last_action_hero);
    
    
    //        usleep(10000);
    
    return 0;
}

/* timerTicked
 
  this function gets called every 1/10th of a second from a timer.
  it reads from the servercontroller to see if any change in motion needs to be sent to the robot
  the function handles the messages from servercontroller and calls drive with requested speed and radiusapplies accelerations accordingly
 */

- (void)timerTicked:(NSTimer*)timer {
    
    NSLog(@"tick\n");
    static int counter = 0;
    [self tvLog:[NSString stringWithFormat:@"tick counter %d\n",counter++]];
    
    
    char data[1024];
    static char input[4096];
    int len;
    
    static int fd_server = -1;
    
    
    if (fd_server < 0)
    {
        if (strlen(SERVER_NAME))
        {
            fd_server = connect_server_ex(port_sparky,SERVER_NAME);
            [self tvLog:[NSString stringWithFormat:@"attempting connect %s %d\n",SERVER_NAME, port_sparky]];
        }
        
        usleep(1000000);
      //  return;
    }
   
    [self tvLog:[NSString stringWithFormat:@"fd from server %d\n", fd_server]];
    
    if (fd_server >= 0)
    {
        char input_this[1024];
        char next_command[1024];
        int bytes = 0;
        
        //write our auth
        char auth_str[1024];
        sprintf(auth_str,"username:%s,password:%s|",USER_NAME,PASSWORD);
        bytes = write(fd_server, auth_str, strlen(auth_str));
        NSLog(@"writing auth_str:%s wrote %d bytes\n", auth_str, bytes);
    
        
        input_this[0] = 0;
        bytes = read(fd_server, input_this, 1024);
        
//        if (bytes <= 0)
            if (bytes < 0)

        {
            if (errno != EAGAIN)
            {
                perror("timerTicked:\n");
                close(fd_server);
                fd_server = -1;
                [self tvLog:[NSString stringWithFormat:@"ERRNO != EAGAIN fd from server %d\n", fd_server]];

            }
        }
        
        if (bytes > 0)
        {
            input_this[bytes] = 0;
            if (strlen(input_this))
            {
                fprintf(stderr,"sparky_received: %s\n",input_this);
                [self tvLog:[NSString stringWithFormat:@"sparky_received: %s\n", input_this]];
                
            }
            
            
            //process any input
            next_command[0] = 0;

            while (process_command(input, input_this, bytes, next_command) && strlen(next_command))
            {
                char sys_command[1024];
                
                fprintf(stderr, "sparky got command %s\n",next_command);
                [self tvLog:[NSString stringWithFormat:@"sparky got command %s\n", next_command]];
                input_this[0] = 0;
                process_command_string(next_command, data, &len);
                if (len > 0)
                {
                    [rscMgr write:data Length:len];
                    int i;
                    [self tvLog:[NSString stringWithFormat:@"data: "]];                        

                    for (i = 0; i < len; i++)
                    {
                        [self tvLog:[NSString stringWithFormat:@" %u", data[i]]];                        
                    }
                    [self tvLog:[NSString stringWithFormat:@"\n"]];                        
                    
                
                }
                //else
                {
                    char datadebug[64*1024];
                    
                    datadebug[0] = 128;
                    datadebug[1] = 131;
                    //write(writeIROBOT,datadebug,2);
                    [rscMgr write:datadebug Length:2];
                    [self tvLog:[NSString stringWithFormat:@" reset:"]];                        

                    [self tvLog:[NSString stringWithFormat:@"  %u %u", datadebug[0], datadebug[1]]];                        
                    
                
                    [self tvLog:[NSString stringWithFormat:@"\n"]];                        

                }

                
                //execute the command to the http api
                //sprintf(sys_command,"curl \"http://localhost/~Sparky/control.php?action=%s\" &", next_command);
                //system(sys_command);
            }
            
            
        }
        else
        {
            char blank[1024];
            blank[0] = 0;
            
            process_command_string(blank, data, &len);
        }
    }

    //restart background task if need be
    UIApplication *app = [UIApplication sharedApplication];
    int timeremaining = [app backgroundTimeRemaining];
    NSLog(@"%d seconds remaining in background task, please apple :-)\n",timeremaining);
    if (timeremaining < 595 && timeremaining >= 0)
    {
        
        //restart
        bgTaskNew = [app beginBackgroundTaskWithExpirationHandler:^{ 
            [app endBackgroundTask:bgTask]; 
            bgTask = UIBackgroundTaskInvalid;
        }];
        NSLog(@"making new background task %d\n", (int)bgTaskNew);


        
        if (bgTask != UIBackgroundTaskInvalid) {
            [app endBackgroundTask:bgTask]; 
            bgTask = UIBackgroundTaskInvalid;
        }

        bgTask = bgTaskNew;
    }
    
    
  }

- (void)init
{
    self.updateString = NULL;
    
    [super init];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"RootViewController::viewWillAppear\n");
    if(self.updateString && [self.updateProperty isEqualToString:@"SERVER_NAME"])
    {
        strcpy(SERVER_NAME, [self.updateString UTF8String]);
    }
    else if(self.updateString && [self.updateProperty isEqualToString:@"USER_NAME"])
    {
        strcpy(USER_NAME, [self.updateString UTF8String]);
    }
    else if(self.updateString && [self.updateProperty isEqualToString:@"PASSWORD"])
    {
        strcpy(PASSWORD, [self.updateString UTF8String]);
    }


    
    [self.tableView reloadData];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"ViewDidLoad\n");

	rtsButton = [[[UIBarButtonItem alloc] initWithTitle:@"RTS" style: UIBarButtonItemStyleBordered target:self action:@selector(toggleRTS)] autorelease];
	[rtsButton setEnabled:FALSE];

	dtrButton = [[[UIBarButtonItem alloc] initWithTitle:@"DTR" style: UIBarButtonItemStyleBordered target:self action:@selector(toggleDTR)] autorelease];
	[dtrButton setEnabled:FALSE];

	
	cableState = kCableNotConnected;
	passRequired = NO;
	rscMgr = [[RscMgr alloc] init]; 
	[rscMgr setDelegate:self];
	
	portConfigTableData = [self readPlist:TABLE_DATA_PLIST];
	portConfigKeys = [[portConfigTableData allKeys]
					  sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	[portConfigKeys retain];
	// Create modem status indicators on the toolbar
	NSMutableArray *modemStatusButtons = [[NSMutableArray alloc] init];	
	UIBarButtonItem *barButton;
	
	ctsLabel = [[UILabel alloc] initWithFrame:MODEM_STAT_RECT];
	[ctsLabel setBackgroundColor:[UIColor clearColor]];
	[ctsLabel setTextColor:MODEM_STAT_OFF_COLOR];
	[ctsLabel setTextAlignment:UITextAlignmentCenter];
	ctsLabel.text = @"CTS";
	ctsLabel.font = [UIFont boldSystemFontOfSize:17.0];
	barButton = [[[UIBarButtonItem alloc] initWithCustomView:ctsLabel] autorelease];
	[modemStatusButtons addObject:barButton];
		
	dsrLabel = [[UILabel alloc] initWithFrame:MODEM_STAT_RECT];
	[dsrLabel setBackgroundColor:[UIColor clearColor]];
	[dsrLabel setTextColor:MODEM_STAT_OFF_COLOR];
	[dsrLabel setTextAlignment:UITextAlignmentCenter];
	dsrLabel.text = @"DSR";
	dsrLabel.font = [UIFont boldSystemFontOfSize:17.0];

	barButton = [[[UIBarButtonItem alloc] initWithCustomView:dsrLabel] autorelease];
	[modemStatusButtons addObject:barButton];

	cdLabel = [[UILabel alloc] initWithFrame:MODEM_STAT_RECT];
	[cdLabel setBackgroundColor:[UIColor clearColor]];
	[cdLabel setTextColor:MODEM_STAT_OFF_COLOR];
	[cdLabel setTextAlignment:UITextAlignmentCenter];
	cdLabel.text = @"CD";
	cdLabel.font = [UIFont boldSystemFontOfSize:17.0];

	barButton = [[[UIBarButtonItem alloc] initWithCustomView:cdLabel] autorelease];
	[modemStatusButtons addObject:barButton];

	riLabel = [[UILabel alloc] initWithFrame:MODEM_STAT_RECT];
	[riLabel setBackgroundColor:[UIColor clearColor]];
	[riLabel setTextColor:MODEM_STAT_OFF_COLOR];
	[riLabel setTextAlignment:UITextAlignmentCenter];
	riLabel.text = @"RI";
	riLabel.font = [UIFont boldSystemFontOfSize:17.0];

	barButton = [[[UIBarButtonItem alloc] initWithCustomView:riLabel] autorelease];
	[modemStatusButtons addObject:barButton];
	
	[modemStatusButtons addObject:rtsButton];
	[modemStatusButtons addObject:dtrButton];
	
	
	[self setToolbarItems:modemStatusButtons animated:NO];
	
	[modemStatusButtons release];
	
	self.navigationItem.rightBarButtonItem.target = self;
	self.navigationItem.rightBarButtonItem.action = @selector(doLoopbackTest);
	

	loopbackTestRunning = NO;
	rxCount = 0;
	txCount = 0;

    static bool sparkyInitialized = false;
    
    if (!sparkyInitialized)
    {
        sparkyInitialized = true;
        
        sparkyTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerTicked:) userInfo:nil repeats:YES];
    
        UIApplication *app = [UIApplication sharedApplication];
        
        bgTask = [app beginBackgroundTaskWithExpirationHandler:^{ 
            [app endBackgroundTask:bgTask]; 
            bgTask = UIBackgroundTaskInvalid;
        }];
        
        
        //strcpy(SERVER_NAME,"192.168.1.119sdsdsdss");
        //strcpy(SERVER_NAME,"192.168.1.112");
        strcpy(SERVER_NAME,"johncelenza.com");
        strcpy(USER_NAME,"sally");
        strcpy(PASSWORD,"struthers");
        
    }
    
    //create sparky log
    UITextView * textViewRounded = [[UITextView alloc] initWithFrame:CGRectMake(10, 600, 800, 500)];
    //textViewRounded.borderStyle = UITextBorderStyleRoundedRect;
    textViewRounded.textColor = [UIColor blackColor]; //text color
    textViewRounded.font = [UIFont systemFontOfSize:17.0];  //font size
    textViewRounded.text = @"something to start with";  //place holder
    textViewRounded.backgroundColor = [UIColor whiteColor]; //background color
//    textViewRounded.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
    
   // textViewRounded.keyboardType = UIKeyboardTypeDefault;  // type of the keyboard
   // textViewRounded.returnKeyType = UIReturnKeyDone;  // type of the return key
    
    //textFieldRounded.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
    
    
    
    //textViewRounded.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
    textViewLog = textViewRounded;
    
//    [self addSubview:textViewRounded];
    Rsc_DemoAppDelegate *appDelegate = (Rsc_DemoAppDelegate *)[[UIApplication sharedApplication] delegate];
    textViewRounded.delegate = appDelegate;	// let us be the delegate so we know when the keyboard's "Done" button is pressed

    [appDelegate.window addSubview:textViewLog];
    
    /*
    CGRect myImageRect = CGRectMake(10.0f, 500.0f, 200.0f, 200.0f);
    UIImageView *myImage = [[UIImageView alloc] initWithFrame:myImageRect];
    [myImage setImage:[UIImage imageNamed:@"Roomba.png"]];
    myImage.opaque = YES; // explicitly opaque for performance
    [self.view addSubview:myImage];
    [myImage release]; */

    
}

// reads a plist file from the bundle directory and
// and returns a dictionary with the data
//
// plistName is name of file minus the suffix (i.e. .plist)
- (NSDictionary *)readPlist:(NSString *)plistName
{
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	NSString *commonDictionaryPath;
	NSDictionary *theDictionary = nil;
	
	if ((commonDictionaryPath = [thisBundle pathForResource:plistName ofType:@"plist"]))  {
		theDictionary = [[NSDictionary alloc] initWithContentsOfFile:commonDictionaryPath];
		
		// when completed, it is the caller's responsibility to release theDictionary
	}
	
	if (!theDictionary)
	{
		NSLog(@"readPlist - Unable to load %@", plistName);
	}
	
	return theDictionary;
}



#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	
	if (riLabel) [riLabel release];
	if (dsrLabel) [dsrLabel release];
	if (ctsLabel) [ctsLabel release];
	if (cdLabel) [cdLabel release];
	
	if (portConfigKeys) [portConfigKeys release];
	if (portConfigTableData) [portConfigTableData release];
	
	if (rscMgr) [rscMgr release];
    [super dealloc];
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	int nRows = 0;
	
	switch(section)
	{
		case kSectionCableStatus:
			nRows = kNumCableStatus;
			break;
		case kSectionPortConfig:
			nRows = [[portConfigTableData allKeys] count];
			break;
		case kSectionStats:
			nRows = kNumStats;
			break;
        case kSectionServerName:
            nRows = 4;
            break;
		default:
			nRows = 0;
			break;
	}
	
	return nRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"RscDemoCell";
	NSString *detailText = nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
	
	
    
	if (indexPath.row % 2)
	{
        [cell setBackgroundColor:[UIColor colorWithRed:.51 green:.51 blue:.51 alpha:1]];
	}
	else [cell setBackgroundColor:[UIColor colorWithRed:.61 green:.61 blue:.61 alpha:1]];
	
	// Configure the cell.
	
	switch(indexPath.section)
	{
		case kSectionCableStatus:
			cell.textLabel.text = @"Cable Status";
			cell.detailTextLabel.text = (cableState == kCableConnected) ? @"Connected" : @"Not Connected";
			break;
		case kSectionPortConfig:
			
			cell.textLabel.text = [portConfigKeys objectAtIndex:indexPath.row]; 
			detailText = [self getPortConfigSettingText:indexPath.row];
			cell.detailTextLabel.text = detailText;
			[detailText release];
			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			break;
		case kSectionStats:
			if (indexPath.row == 0) 
			{
				cell.textLabel.text = @"Rx";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", rxCount];
			}
			else 
			{
				cell.textLabel.text = @"Tx";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", txCount];
			}
			break;
        case kSectionServerName:
            if (indexPath.row == 0) 
			{
				cell.textLabel.text = @"Sparky Server Name";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%s", SERVER_NAME];
			}
            else if (indexPath.row == 1)  
            {
                cell.textLabel.text = @"Username";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%s", USER_NAME];

            }
            else if (indexPath.row == 2)  
            {
                cell.textLabel.text = @"Password";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%s", PASSWORD];
                
            }
            else if (indexPath.row == 3)  
            {
                cell.textLabel.text = @"Show Dashboard";
				cell.detailTextLabel.text = [NSString stringWithFormat:@""];
                
            }


            break;
	}
	
	//
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if (currentSelection) [currentSelection release];
	currentSelection = [[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]retain];
	
	switch (indexPath.section)
	{
		case kSectionPortConfig:
		{
			SelectionViewController *detailViewController = [[SelectionViewController alloc] initWithNibName:@"SelectionViewController" bundle:nil];
			detailViewController.tableData =  [portConfigTableData objectForKey:[portConfigKeys objectAtIndex:indexPath.row]];
			detailViewController.selected = [detailViewController.tableData indexOfObject:cell.detailTextLabel.text];
			detailViewController.evenCellColor = [UIColor colorWithRed:.51 green:.51 blue:.51 alpha:1];
			detailViewController.oddCellColor = [UIColor colorWithRed:.61 green:.61 blue:.61 alpha:1];
			[detailViewController setDelegate:self];
			// ...
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:detailViewController animated:YES];
			[detailViewController release];
			break;
		}
        case kSectionServerName:
//            EditFieldViewController *editFieldViewController = NULL;
            //              editFieldViewController.title = [NSString stringWithString:schoolsObj.property];

            break;
		default:
            if (indexPath.section != kSectionServerName)
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
			break;
	}
    
    if (indexPath.section == kSectionServerName)
    {
        bool showEditView = true;
        
        EditFieldViewController *editFieldViewController = [[EditFieldViewController alloc] initWithNibName:@"EditFieldView" bundle:nil];
        if (indexPath.row == 0) {
            editFieldViewController.updateString = [NSString stringWithFormat:@"%s", SERVER_NAME];
                self.updateProperty = [NSString stringWithFormat:@"SERVER_NAME"];
        }
        else if (indexPath.row == 1) {
            editFieldViewController.updateString = [NSString stringWithFormat:@"%s", USER_NAME];
            self.updateProperty = [NSString stringWithFormat:@"USER_NAME"];

        }
        else if (indexPath.row == 2) {
            editFieldViewController.updateString = [NSString stringWithFormat:@"%s", PASSWORD];
            self.updateProperty = [NSString stringWithFormat:@"PASSWORD"];
            
        }
        else if (indexPath.row == 3) {
            showEditView = false;   
            [editFieldViewController release];
            
            //push dashboard view
	   DashViewController *dashboard = [[DashViewController alloc] initWithNibName:@"DashView" bundle:nil];
	   [self.navigationController pushViewController:dashboard animated:YES];
        }


        
        if (showEditView)
        {
            NSLog(@"PUSH!\n");
            editFieldViewController.rootViewController = self;
            [self.navigationController pushViewController:editFieldViewController animated:YES];
            NSLog(@"And, we are back!\n");
            [editFieldViewController release];
        }

        
    }
	 
}

#pragma mark -
#pragma mark SelectionViewController delegate

- (void)selectionController:(SelectionViewController *)selectionController didSelectIndex:(int)index
{
	NSString *temp = [selectionController.tableData objectAtIndex:selectionController.selected];
	
	
	UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:currentSelection];
	currentCell.detailTextLabel.text = temp;
	
	// set port config with new value
	[self setPortConfigSettingFromText:temp WhichSetting:(PortConfigSettingType)currentSelection.row];
	
	
}

#pragma mark -
#pragma mark RSC interface 

- (NSString *)getPortConfigSettingText:(PortConfigSettingType)whichSetting
{
	NSString *temp = nil;
	serialPortConfig portCfg;
	[rscMgr getPortConfig:&portCfg];
	
	NSArray *portConfigValues = [portConfigTableData objectForKey:[portConfigKeys objectAtIndex:whichSetting]];
	int value = 0;
	switch(whichSetting)
	{
		case kBaudIndex:
			// baud
			value = portCfg.baudLo | (portCfg.baudHi << 8);
			temp = [[NSString alloc]initWithFormat:@"%d",value];
			break;
		case kDataBitsIndex:
			value = portCfg.dataLen;
			temp = [[NSString alloc] initWithFormat:@"%d",value];
			break;
		case kParityIndex:
			temp = [[NSString alloc] initWithString:[portConfigValues objectAtIndex:portCfg.parity ]];
			break;
		case kStopBitsIndex:
			value = portCfg.stopBits;
			temp = [[NSString alloc] initWithFormat:@"%d",value];
			break;
        case kServerName:
            [[NSString alloc] initWithFormat:@"%s", SERVER_NAME];
			
	}
	
	
	return temp;
	
}

- (void) setPortConfigSettingFromText:(NSString *)text WhichSetting:(PortConfigSettingType)whichSetting
{
	int value = [text intValue];
	switch(whichSetting)
	{
		case kBaudIndex:
			// baud
			[rscMgr setBaud:value];
			break;
		case kDataBitsIndex:
			[rscMgr setDataSize:(DataSizeType)value];
			break;
		case kParityIndex:
			[rscMgr	setParity:(ParityType)value];
			break;
		case kStopBitsIndex:
			[rscMgr setStopBits:(StopBitsType)value];
			break;
			
	}
}


- (void) toggleRTS
{
	BOOL rtsState = [rscMgr getRts];
	
	rtsState = !rtsState;
	
	if (rtsState) rtsButton.style = UIBarButtonItemStyleDone;
	else rtsButton.style = UIBarButtonItemStyleBordered;
	
	[rscMgr setRts:rtsState];
}

- (void) toggleDTR
{
	BOOL dtrState = [rscMgr getDtr];
	
	dtrState = !dtrState;
	
	if (dtrState) dtrButton.style = UIBarButtonItemStyleDone;
	else dtrButton.style = UIBarButtonItemStyleBordered;
	
	[rscMgr setDtr:dtrState];
}

- (void) doLoopbackTest
{
	int i;
	char c;
		
	for (i = 0; i < LOOPBACK_TEST_LEN; i++)
	{
		if (!(i % 26)) c = 'A';
		txLoopBuff[i] = c++;
	}
	
	loopbackCount = 0;
	loopbackTestRunning = YES;	
	txCount += LOOPBACK_TEST_LEN;
	[rscMgr write:txLoopBuff Length:LOOPBACK_TEST_LEN];
	[self updateStats:kStatTx];
}

- (void) updateStats:(StatType)whichStat 
{
	NSIndexPath *path = [NSIndexPath indexPathForRow:whichStat inSection:kSectionStats];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
	
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (whichStat == kStatRx) ? rxCount : txCount];
}

#pragma mark -
#pragma mark RSC delegate


- (void) cableConnected:(NSString *)protocol
{
	// get cell for device status
	NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:kSectionCableStatus];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
	
	cell.detailTextLabel.text = CABLE_CONNECTED_TEXT;
	
	cableState = kCableConnected;
	
	// We display the serial config options
	// to the user so we assume they've been set already.
	
	// In general, this would be a good place to setBaud, setDataSize, etc...
	// Example
	[rscMgr setBaud:57600];
	
	// Now open the serial communication session using the
	// serial port configuration options we've already set.
	// However, the baud rate, data size, parity, etc....
	// can be changed after calling open if needed.
	[rscMgr open];
		
	// Cable connected so enable dtr and rts toggle buttons
	if (rtsButton != nil)
	{
		[rtsButton setEnabled:TRUE];
		[dtrButton setEnabled:TRUE];
	}
}


- (void) cableDisconnected
{
	// get cell for device status
	NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:kSectionCableStatus];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
	
	cell.detailTextLabel.text = CABLE_NOT_CONNECTED_TEXT;
	
	cableState = kCableNotConnected;
	passRequired = NO;
	
	if (rtsButton != nil)
	{
		[rtsButton setEnabled:FALSE];
		[dtrButton setEnabled:FALSE];
	}

	loopbackTestRunning = NO;
	rxCount = 0;
	txCount = 0;
	[self updateStats:kStatRx];
	[self updateStats:kStatTx];
	
}


- (void) portStatusChanged
{
	int modemStatus = [rscMgr getModemStatus];
	
	[ctsLabel setTextColor:(modemStatus & MODEM_STAT_CTS) ? MODEM_STAT_ON_COLOR : MODEM_STAT_OFF_COLOR];
	[riLabel setTextColor:(modemStatus & MODEM_STAT_RI) ? MODEM_STAT_ON_COLOR : MODEM_STAT_OFF_COLOR];
	[dsrLabel setTextColor:(modemStatus & MODEM_STAT_DSR) ? MODEM_STAT_ON_COLOR : MODEM_STAT_OFF_COLOR];
	[cdLabel setTextColor:(modemStatus & MODEM_STAT_DCD) ? MODEM_STAT_ON_COLOR : MODEM_STAT_OFF_COLOR];

}

- (void) readBytesAvailable:(UInt32)numBytes
{
	int bytesRead; 
    BOOL res = NO;
	
	// Read the data out
	bytesRead = [rscMgr read:(rxLoopBuff+loopbackCount) Length:numBytes];
	rxCount += bytesRead;
	
	if (loopbackTestRunning == YES)
	{
		loopbackCount += bytesRead;
		if (loopbackCount >= LOOPBACK_TEST_LEN)
		{
			loopbackTestRunning = NO;
			if (memcmp(rxLoopBuff, txLoopBuff, LOOPBACK_TEST_LEN) == 0)
			{
				NSLog(@"Loopback test passed\n");
                res = YES;
			}
			else
			{
                res = NO;
                NSLog(@"Loopback test failed\n");
			}
            
            NSString *resultStr = [NSString stringWithString:(res == YES) ? @"Success" : @"Failed"];
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Loop Test" message:resultStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            
            [alert release];

		}
	}
	
	[self updateStats:kStatRx];
}


/* textview utilities */
- (void) tvLog:(NSString *)str
{
    self.textViewLog.text = [NSString stringWithFormat:@"%@%@", str, [self.textViewLog.text substringToIndex:min(500,[self.textViewLog.text length])]];
}

@end

