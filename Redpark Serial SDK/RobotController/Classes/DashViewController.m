//
//  DashViewController.m
//  Rsc Demo
//
//  Copyright © 2011 John Celenza
//

#import "DashViewController.h"
#import "RootViewController.h"

@implementation DashViewController
@synthesize roombaImage;
@synthesize velocityLabel;
@synthesize radiusLabel;
@synthesize leftAxisLabel;
@synthesize rightAxisLabel;
@synthesize speedimages;
@synthesize radiusimage;

static NSTimer *dashTimer = NULL;


- (void)init
{
    
    [super init];
}

- (void)viewWillAppear:(BOOL)animated
{
}

- (UIImageView *) addImage:(NSString *)filename rect:(CGRect)_rect {
    UIImageView *myImage = [[UIImageView alloc] initWithFrame:_rect];
    [myImage setImage:[UIImage imageNamed:filename]];
    //myImage.opaque = YES; // explicitly opaque for performance
    [self.view addSubview:myImage];
    return myImage;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"ViewDidLoad\n");

    CGRect myImageRect = CGRectMake(10.0f, 10.0f, 200.0f, 200.0f);
    UIImageView *myImage = [[UIImageView alloc] initWithFrame:myImageRect];
    self.roombaImage = myImage;
    [myImage setImage:[UIImage imageNamed:@"Roomba.png"]];
    self.roombaImage.opaque = YES; // explicitly opaque for performance
    [self.view addSubview:self.roombaImage];
    [myImage release];
    
    myImageRect = CGRectMake(0,0,320,480);
    [self addImage:@"sparky_dashboard_bg.png" rect:myImageRect];
    
    self.speedimages = [[NSMutableArray alloc] initWithCapacity:7];
    for (int i = -3; i < 4; i++)
    {
        myImageRect = CGRectMake(0,0,320,480);
        NSString *filename = [NSString stringWithFormat:@"sparky_dashboard_speed%d", i];
        UIImageView *thisimage = [self addImage:filename rect:myImageRect];        
        thisimage.hidden = true;
        [self.speedimages insertObject:thisimage atIndex:i+3];
    }
    
    myImageRect = CGRectMake(150, 240, 23, 107);
    self.radiusimage = [self addImage:@"indicator.png" rect:myImageRect];
    
    //add text to display velocity and radius
    CGRect rect = CGRectMake(10 , 20, 120.0f, 45.0f);
    self.velocityLabel = [[UILabel alloc]initWithFrame:rect];
    [self.view addSubview:self.velocityLabel];

    rect = CGRectMake(10 , 60, 120.0f, 45.0f);
    self.radiusLabel = [[UILabel alloc]initWithFrame:rect];
    [self.view addSubview:self.radiusLabel];
    
    rect = CGRectMake(10 , 100, 120.0f, 45.0f);
    self.leftAxisLabel = [[UILabel alloc]initWithFrame:rect];
    [self.view addSubview:self.leftAxisLabel];

    rect = CGRectMake(10 , 140, 120.0f, 45.0f);
    self.rightAxisLabel = [[UILabel alloc]initWithFrame:rect];
    [self.view addSubview:self.rightAxisLabel];

    
    dashTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerTicked:) userInfo:nil repeats:YES];
    
    
}

- (void)timerTicked:(NSTimer*)timer {
    this_roomba = [RootViewController getRoomba];
    //static int fakeVelocity = 0;
    //fakeVelocity++;
    NSString *textString = [NSString stringWithFormat:@"velocity: %d",this_roomba.velocity];
    self.velocityLabel.text = textString;
    
    textString = [NSString stringWithFormat:@"radius: %d",this_roomba.radius];
    self.radiusLabel.text = textString;
    
    textString = [NSString stringWithFormat:@"leftAxis: %d",this_roomba.slider0  ];
    self.leftAxisLabel.text = textString;
    textString = [NSString stringWithFormat:@"rightAxis: %d",this_roomba.slider1  ];
    self.rightAxisLabel.text = textString;

    int speed_index = 0;
    speed_index = this_roomba.velocity/100;
    if (speed_index > 3)
        speed_index = 3;
    else if (speed_index < -3)
        speed_index = -3;
    for (int i = -3; i < 4; i++)
    {
        UIImageView *thisimage = [self.speedimages objectAtIndex:i+3];
        thisimage.hidden = true;
    }
    UIImageView *thisimage = [self.speedimages objectAtIndex:speed_index+3];
    thisimage.hidden = false;
    
    static float last_rotate_radius = 0;
    self.radiusimage.transform = CGAffineTransformMakeRotation(-last_rotate_radius); //rotation in radians
    float rotate_radians = ((this_roomba.radius)/1000.0)*90*3.14159/180.0;
    self.radiusimage.transform = CGAffineTransformMakeRotation(-rotate_radians); //rotation in 
    last_rotate_radius  = rotate_radians;
    
    NSLog(@"dashViewController:: TimerTicked:: velocity:%d speed_index:%d radius:%d\n", this_roomba.velocity,speed_index,this_roomba.radius);
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
	
    [super dealloc];
}

@end

