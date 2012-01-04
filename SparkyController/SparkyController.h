//
//  SkypeController.h
//  SkypeAPITest
//
//  Created by Janno Teelem on 14/04/2005.
//  Copyright 2005-2006 Skype Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import <Skype/Skype.h>
//#import "Sparky.h"
//#import "KeyReaderView.h"

#import "STJoystick.h"

int bar = 0;

@interface SparkyController : NSObject 
{
    IBOutlet id commandField;
    IBOutlet id usernameField;
    IBOutlet id passwordField;

    IBOutlet id infoView;
	IBOutlet id button_w;
	//Sparky *MySparky;
	IBOutlet id MyKeyReader;
	//KeyReaderView MyKeyReader;
      //  NSMutableString *chat_id;

	int sock;
	IBOutlet id straight0;
	IBOutlet id straight1;
	IBOutlet id reverse0;
	IBOutlet id reverse1;
    
    IBOutlet id maxSpeed;
    IBOutlet id sensitivity;
	
	STJoystick* mJoystick;
	int mLeftJoystickAxis;
	int mRightJoystickAxis;

	NSString *foo;
	
}

- (void)init;
- (IBAction)onConnectBtn:(id)sender;
- (IBAction)onDisconnectBtn:(id)sender;
- (IBAction)onSendBtn:(id)sender;

//for the move buttons
- (IBAction)onMoveLeft:(id)sender;
- (IBAction)onMoveRight:(id)sender;
- (IBAction)onMoveStraight:(id)sender;
- (IBAction)onMoveReverse:(id)sender;

- (IBAction)onMoveLeftSlow:(id)sender;
- (IBAction)onMoveRightSlow:(id)sender;
- (IBAction)onMoveStraightSlow:(id)sender;
- (IBAction)onMoveReverseSlow:(id)sender;


- (void)MoveStraight:(NSString *)attr;
- (void)MoveRight:(NSString *)attr;
- (void)MoveLeft:(NSString *)attr;
- (void)MoveReverse:(NSString *)attr;
- (void)Stop;



- (void)sendCommand: (NSString *)command;
-(NSMutableString *)http_sendMoveCommand:(NSString*)action;
@property(nonatomic, retain) NSString *foo;

@property STJoystick *mJoystick;
@property int mLeftJoystickAxis;
@property int mRightJoystickAxis;
@property(nonatomic, retain) IBOutlet id maxSpeed;
@property(nonatomic, retain) IBOutlet id sensitivity;

@end
