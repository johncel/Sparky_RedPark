//
//  DashViewController.h
//  Rsc Demo
//
//  Copyright © 2011 Redpark  All Rights Reserved
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

struct roomba_drive_info;

@interface DashViewController : UIViewController  {
    struct roomba_drive_info this_roomba;
    UIImageView *roombaImage;
    IBOutlet UIView *view;
    
    UILabel *velocityLabel;
    UILabel *radiusLabel;
    UILabel *leftAxisLabel;
    UILabel *rightAxisLabel;
    
    NSMutableArray *speedimages;
    
    UIImageView *radiusimage;

    
}
@property (nonatomic) struct roomba_drive_info *roomba;
@property (nonatomic, retain) UIImageView *roombaImage;
@property (nonatomic, retain) UILabel *velocityLabel;
@property (nonatomic, retain) UILabel *radiusLabel;
@property (nonatomic, retain) UILabel *leftAxisLabel;
@property (nonatomic, retain) UILabel *rightAxisLabel;
@property (nonatomic, retain) NSMutableArray *speedimages;
@property (nonatomic, retain) UIImageView *radiusimage;


@end
