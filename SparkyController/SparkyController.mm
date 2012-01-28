//
//  SparkyController.mm
//  
//
//  Connect TCP to johnandbrendan.com 9886, send controller commands
//

#import "SparkyController.h"
#import "KeyReaderView.h"
//#import "Sparky.h"
#import "STJoystick.h"

extern "C" {
#include "../sparky_utils.h"
}

extern char SERVER_NAME[1024];

NSString* const cMyApplicationName = @"Drive Sparky";


@implementation SparkyController
@synthesize foo;

@synthesize mJoystick;
@synthesize mLeftJoystickAxis;
@synthesize mRightJoystickAxis;
@synthesize maxSpeed;
@synthesize sensitivity;

///INIT///
- (void)init
{
//	MySparky = [Sparky new];//NULL;
			//[MySparky Debug:@"Hello"];
//	MySparkyController = self;
	//[MyKeyReader setMySparkyController:self];
	
	//[MyKeyReader setMySparkyController:self];
	
	sock = -1;
	mJoystick = NULL;

	
	//bar;
	
}

/////////////////////////////////////////////////////////////////////////////////////
- (void)awakeFromNib
{
	//[SkypeAPI setSkypeDelegate:self];
	[MyKeyReader setMySparkyController:self];
	
	[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(onControlTimer) userInfo:nil repeats:YES];

	
	//MySparkyController = self;
}

/////////////////////////////////////////////////////////////////////////////////////
// required delegate method
- (NSString*)clientApplicationName
{
	return cMyApplicationName;
}


/////////////////////////////////////////////////////////////////////////////////////
- (IBAction)onConnectBtn:(id)sender
{
	[MyKeyReader setMySparkyController:self];
	
	[infoView insertText:[NSString stringWithFormat:@"Trying to connect to johnandbrendand.com %d\n", port_controller]];
	
	if (sock >= 0)
		close(sock);
	
	strcpy(SERVER_NAME, K_SERVER_NAME); 
	
	
	if ([[commandField stringValue] length] > 0)
		sock = connect_server_ex(port_controller, (char *)[[commandField stringValue] UTF8String]);
	else
		sock = connect_server(port_controller);
	
	
	[infoView insertText:[NSString stringWithFormat:@"onConnectBtn:: got sock %d\n", sock]];

	
}

/////////////////////////////////////////////////////////////////////////////////////
- (IBAction)onDisconnectBtn:(id)sender
{
	
	[infoView insertText:[NSString stringWithFormat:@"onDisconnectBtn:: closing sock %d\n", sock]];

	close(sock);
	sock = -1;
}

/////////////////////////////////////////////////////////////////////////////////////
- (IBAction)onSendBtn:(id)sender
{
	[infoView insertText:[commandField stringValue]];
	[infoView insertText:@"\n"];
	
	[self sendCommand:[commandField stringValue]];
	
}

- (void)Debug:(NSString *)line
{
	NSLog(@"Sparky:");
	NSLog(line);
	NSLog(@"\n");
}

/* the simple control buttons on user interface hook here */
- (IBAction)onMoveLeft:(id)sender
{
	NSString *command = [NSString stringWithFormat:@"move_left"];
	
	[self sendCommand:command];
	
}

- (IBAction)onMoveLeftSlow:(id)sender
{
	[self MoveLeft:@"_slow"];
	
	
}

- (IBAction)onMoveRightSlow:(id)sender
{
	[self MoveRight:@"_slow"];
	
	
}

- (IBAction)onMoveStraightSlow:(id)sender
{
	[self MoveStraight:@"_slow"];
	
	
}

- (IBAction)onMoveReverseSlow:(id)sender
{
	[self MoveReverse:@"_slow"];
	
	
}





- (void)MoveLeft:(NSString *)attr
{
	NSString *command = NULL;
	NSString *motor_str = [NSString stringWithFormat:@"_slider0_%d_slider1_%d",[reverse0 intValue], [reverse1 intValue]];

	
	if (attr)
	{
		command = [NSString stringWithFormat:@"move_left%@%@",motor_str,attr];
	}
	else
	{
		command = [NSString stringWithFormat:@"move_left%@",motor_str];
	}
	NSLog(@"MoveLeft");
	NSLog(command);
	
	[self sendCommand:command];
	
	
}

- (void)MoveRight:(NSString *)attr
{
	NSString *command = NULL;
	NSString *motor_str = [NSString stringWithFormat:@"_slider0_%d_slider1_%d",[reverse0 intValue], [reverse1 intValue]];

	
	if (attr)
	{
		command = [NSString stringWithFormat:@"move_right%@%@",motor_str,attr];
	}
	else
	{
		command = [NSString stringWithFormat:@"move_right%@",motor_str];
	}
	NSLog(@"MoveRight");
	NSLog(command);
	
	[self sendCommand:command];
	
}

- (void)MoveStraight:(NSString *)attr
{
	NSString *command = NULL;
	NSString *motor_str = [NSString stringWithFormat:@"_straight0_%d_straight1_%d",[straight0 intValue], [straight1 intValue]];
	
	if (attr)
	{
		command = [NSString stringWithFormat:@"move_straight%@%@",attr,motor_str];
	}
	else
	{
		command = [NSString stringWithFormat:@"move_straight%@",motor_str];
	}
	NSLog(@"MoveStraight");
	NSLog(command);
	
	[self sendCommand:command];
	
}

- (void)MoveReverse:(NSString *)attr
{
	NSString *command = NULL;
	NSString *motor_str = [NSString stringWithFormat:@"_reverse0_%d_reverse1_%d",[reverse0 intValue], [reverse1 intValue]];
	
	if (attr)
	{
		command = [NSString stringWithFormat:@"move_reverse%@%@",attr,motor_str];
	}
	else
	{
		command = [NSString stringWithFormat:@"move_reverse%@",motor_str];
	}
	NSLog(@"MoveReverse");
	NSLog(command);
	
	[self sendCommand:command];
	
}

- (void)Stop
{
	NSString *command = [NSString stringWithFormat:@"stop"];
	
	NSLog(@"Stop");
	NSLog(command);
	
	[self sendCommand:command];
	
}


- (IBAction)onMoveRight:(id)sender
{
	NSString *command = [NSString stringWithFormat:@"move_right"];
	//NSString *command = [NSString stringWithString:@"booboo"];
	NSLog(@"onMoveRight");
	NSLog(command);
		
	[self sendCommand:command];
}

- (IBAction)onMoveStraight:(id)sender
{
/*
	NSString *command = [NSString stringWithFormat:@"move_straight"];
	NSLog(@"onMoveStraight");
	NSLog(command);
	
	[self sendCommand:command];
*/

    [self MoveStraight:@""];
}

- (IBAction)onMoveReverse:(id)sender
{
/*
	NSString *command = [NSString stringWithFormat:@"move_reverse"];
	NSLog(@"onMoveReverse");
	NSLog(command);
	
	[self sendCommand:command];
*/	
	[self MoveReverse:@""];
}


//- (void)keyDown:(NSEvent *)theEvent
//{
 ///   NSString *keyChar = [theEvent characters];
    //if ( [keyChar isEqualToString:@”c”] ) {
      //  [path removeAllPoints];
        //[self setNeedsDisplay:YES];
    //}
	//NSLog(keyChar);
//}

//- (BOOL)acceptsFirstResponder
//{
 //   return YES;
//}

/////////////////////////////////////////////////////////////////////////////////////

- (void)sendCommand: (NSString *)command
{
	char full_command[1024];
	char *command_cstr = (char *)[command cString];
		
	sprintf(full_command,"username:%s,password:%s|%s|",[[usernameField stringValue] UTF8String],[[passwordField stringValue] UTF8String],  command_cstr);
	NSLog(@"Full command:%s", full_command);
	write(sock,full_command,strlen(full_command));

	return;
}

//:r Sparky.m

		//[chat_id init];
-(NSMutableString *)http_sendMoveCommand:(NSString*)action
{
	NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];

    // config
    [request setHTTPMethod:@"POST"];
    [request setURL:[NSURL URLWithString:@"http://localhost/~Sparky/control.php"]];
   
    // set the headers
    [request addValue:@"localhost" forHTTPHeaderField:@"Host"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"en" forHTTPHeaderField:@"Accept-Language"];
    //[request addValue:@@"gzip, deflate" forHTTPHeaderField:@@"Accept-Encoding"];
    //[request addValue:@@"http://www.wunderground.com/" forHTTPHeaderField:@@"Referer"];
    //[request addValue:@@"Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en) AppleWebKit/522.11 (KHTML, like Gecko) Version/3.0.2 Safari/522.12" forHTTPHeaderField:@@"User-Agent"];
    //[request addValue:@@"keep-alive" forHTTPHeaderField:@@"Connection"];
    //[request addValue:@@"text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5" forHTTPHeaderField:@@"Accept"];

    // set the body and Content-Length header
    //NSString * body = @@"";
    NSString * body = [NSString stringWithFormat: @"action=%@", action];
    //NSLog(@@"request body: %@@", body);
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request addValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];

    // make the actual request
    NSURLResponse *resp = nil;
    NSError *err = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
}


-(void) onControlTimer {
	//printf("CONTROL TIMER\n");
	//if (infoView)
	//      [infoView insertText:@"CONTROL TIMERe\n"];
	if (!mJoystick)
		[self initializeSparkyJoystick:@"FROM control timer\n"];
	
	if (mJoystick)
	{
		static char *lastCommand = NULL;
		static time_t time_command = time(NULL);
		static char command[1024];
		int timeElapsed = time(NULL) - time_command;
		
		if (!lastCommand)
		{
			lastCommand = (char *)calloc(1, 1024);
			strcpy(lastCommand,"foo");
			strcpy(command,"stop");
		}
		
		mJoystick->Update();
		float leftPercent = -(mJoystick->GetAxis(mLeftJoystickAxis) - 128.0) / 128.0;
		float rightPercent = (mJoystick->GetAxis(mRightJoystickAxis) - 128.0) / 128.0;
        
        //trying out one stick
        leftPercent = sqrt(pow(mJoystick->GetAxis(0)-128.0,2) + pow(mJoystick->GetAxis(1)-128.0,2))/128.0;
        if (mJoystick->GetAxis(1)-128.0 > 100) //only go backward if the joystick is mostly backward.
            leftPercent = -leftPercent;
        int rightPercentSign = (mJoystick->GetAxis(0) - 128.0);
        if (rightPercentSign < 0)
            rightPercentSign = -1;
        else
            rightPercentSign = 1;
        rightPercent = pow(fabs(mJoystick->GetAxis(0) - 128.0) / 128.0,1)*rightPercentSign;
		
		//left
		if ((leftPercent - rightPercent) < -0.5)
		{
			strcpy(command,"move_left");
		}
		//right
		else if ((leftPercent - rightPercent) > 0.5)
		{
			strcpy(command,"move_right");
		}
		//straight
		else if (leftPercent > 0.25 && rightPercent > 0.25)
		{
			strcpy(command,"move_straight");
		}
		//reverse
		else if (leftPercent < -0.25  && rightPercent < -0.25)
		{
			strcpy(command,"move_reverse");
		}
		else if (timeElapsed > 1)
		{
			strcpy(command,"stop");
		}
		else
		{
			char ckey[1024], cvalue[1024];
			//parse the speed off the last command if it has a speed
			if (sscanf(lastCommand,"%[^_]_%[^_]", ckey, cvalue)==2)
			{
				sprintf(command,"%s_%s",ckey, cvalue);
			}
			
		}
		
		//if the command is not stop, append the left/right axis percentage
		if (strcmp(command,"stop"))
		{
			char new_command[1024];
			int leftPercentInt = leftPercent*100.0;
			int rightPercentInt = rightPercent*100.0;
			
			leftPercentInt -= leftPercentInt % 10;
			rightPercentInt -= rightPercentInt % 10;
            
			
			//to be friendlier on chattiness, quantize the percentages
			//sprintf(new_command,"%s_L_%.2f_R_%.2f",   command, leftPercentInt/100.0, rightPercentInt/100.0);
			//sprintf(new_command,"_slider0_%.0f_slider1_%.0f",  leftPercentInt/100.0*(float)[reverse0 intValue], rightPercentInt/100.0*[reverse1 intValue]);
            
            //create the command string
            //supports the new maxSpeed and sensitivity control 
            // these values are used as follows:
            /*
                maxSpeed is the largest value that will be sent for slider0 (vertical axis)
                such that speed = min(speed, maxSpeed)
             
             */
            
            int max_speed = [maxSpeed intValue];
            
            //scan buttons, if one pressed, 2x speed
            for (int i = 0; i < mJoystick->NumButtons();i++)
            {
                unsigned char b = mJoystick->GetButton(i);
                if (b)
                {
                    max_speed *= 2;
                    NSLog(@"button %d has value %u\n", i, (unsigned int)b);
                }
            }
            
            float speed = leftPercentInt/100.0*(float)[reverse0 intValue];
            if (speed > (float)max_speed)
                speed = max_speed;
            if (speed < -(float)max_speed)
                speed = -max_speed;
            sprintf(new_command,"_slider0_%.0f_slider1_%.0f",  speed, rightPercentInt/100.0*[reverse1 intValue]);

			//
//			NSString *motor_str = [NSString stringWithFormat:@"_slider0_%d_slider1_%d",[reverse0 intValue], [reverse1 intValue]];

			sprintf(command,"move_velocityradius");
			strcat(command, new_command);
		}
		
		//new code
		
		//- (void)sendCommand: (NSString *)command
		[self sendCommand:[NSString stringWithUTF8String:command]];

		
		NSLog(@"onControlTimer:: command:%s\n",command);
		
/*
		if (strcmp(lastCommand, command) || (strcmp(command, "stop") && timeElapsed > 1))
		{
			NSString *skype_command = [NSString stringWithFormat:@"CHATMESSAGE %@ :%s",[MySparky getChatID],command];
			NSLog(skype_command);
			[infoView insertText:[NSString stringWithFormat:@"%@\n", skype_command]];
			
			[SkypeAPI sendSkypeCommand:skype_command];
			time_command = time(NULL);
			strcpy(lastCommand, command);
		}
 */
		
	}
}

//// initialize a joystick using Stanford's STJoystick library
- (void)initializeSparkyJoystick:(NSString *)foo
{
	STJoystick::Initialize();
	printf("There are %d joystick(s) attached to the system\n",STJoystick::NumJoysticks());
	/*
	if (STJoystick::NumJoysticks() > 0)
	{
		int i = 0;
		while (!mJoystick && i < 100)
		{
			mJoystick = STJoystick::OpenJoystick(i);
			NSLog(@"trying joystick %d\n", i);
			i++;
		}
	}
	 */
	if (STJoystick::NumJoysticks() > 0)
		mJoystick = STJoystick::OpenJoystick(STJoystick::NumJoysticks()-1);
	NSLog(@"trying joystick %d\n", STJoystick::NumJoysticks()-1);
	

		
	mLeftJoystickAxis = 1;
	mRightJoystickAxis = 2;
	
	//      mJoystick->Update();
	//for (int a=0; a < mJoystick->NumAxes(); a++)
	//{
	//              printf("Axis:%d is at:%d\n",a, mJoystick->GetAxis(a));
	//      }
	
}




@end
