//
//  SparkyController.mm
//  
//
//  Connect TCP to johnandbrendan.com 9886, send controller commands
//

#import "SparkyController.h"
#import "KeyReaderView.h"
//#import "Sparky.h"

#include "../sparky_utils.h"

extern char SERVER_NAME[1024];

NSString* const cMyApplicationName = @"Drive Sparky";


@implementation SparkyController

///INIT///
- (void)init
{
//	MySparky = [Sparky new];//NULL;
			//[MySparky Debug:@"Hello"];
//	MySparkyController = self;
	//[MyKeyReader setMySparkyController:self];
	
	//[MyKeyReader setMySparkyController:self];
	
	sock = -1;
	
	
	
}

/////////////////////////////////////////////////////////////////////////////////////
- (void)awakeFromNib
{
	//[SkypeAPI setSkypeDelegate:self];
	[MyKeyReader setMySparkyController:self];
	
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
	char *command_cstr = [command cString];
		
	sprintf(full_command,"%s|",command_cstr);
	
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



@end
