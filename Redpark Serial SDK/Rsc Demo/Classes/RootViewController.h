//
//  RootViewController.h
//  Rsc Demo
//
//  Copyright © 2011 Redpark  All Rights Reserved
//

#import <UIKit/UIKit.h>
#import "SelectionViewController.h"
//#import "EditFieldViewController.h"
#import "RscMgr.h"

#define LOOPBACK_TEST_LEN 128

typedef enum CableConnectState
{
	kCableNotConnected,
	kCableConnected,
	kCableRequiresPasscode

} CableConnectState;

typedef enum  
{
	kBaudIndex = 0,
	kDataBitsIndex = 1,
	kParityIndex = 2,
	kStopBitsIndex = 3,
    kServerName = 4
	
} PortConfigSettingType;


struct roomba_drive_info {
	int velocity;
	int radius;
	int leftmotor;
	int slider0;
	int slider1;
};




typedef enum
{
	kStatRx = 0,
	kStatTx = 1,
} StatType;

@interface RootViewController : UITableViewController < RscMgrDelegate, SelectionViewControllerDelegate, UITextViewDelegate> {
	UILabel *ctsLabel;
	UILabel *dsrLabel;
	UILabel *cdLabel;
	UILabel *riLabel;
	UIBarButtonItem *rtsButton;
	UIBarButtonItem *dtrButton;
	
	NSDictionary *portConfigTableData;
	NSArray *portConfigKeys;
	
	RscMgr *rscMgr;
	
	NSIndexPath *currentSelection;
	
	CableConnectState cableState;
	BOOL passRequired;
	
	BOOL loopbackTestRunning;
	int loopbackCount;
	
	int rxCount;
	int txCount;
	
	UInt8 rxLoopBuff[LOOPBACK_TEST_LEN];
	UInt8 txLoopBuff[LOOPBACK_TEST_LEN];
    
    UIBackgroundTaskIdentifier bgTask;
    UIBackgroundTaskIdentifier bgTaskNew;
    
    NSString *updateString;
    NSString *updateProperty;
    UITextView *textViewLog;
    
}

- (NSString *)getPortConfigSettingText:(PortConfigSettingType)whichSetting;
- (void) setPortConfigSettingFromText:(NSString *)text WhichSetting:(PortConfigSettingType)whichSetting;
- (NSDictionary *)readPlist:(NSString *)plistName;
- (void) updateStats:(StatType)whichStat;
- (void) tvLog:(NSString *)str;
+(struct roomba_drive_info) getRoomba;


@property (nonatomic, retain) NSString *updateString;
@property (nonatomic, retain) NSString *updateProperty;

@property (nonatomic, retain) UITextView *textViewLog;

@end
