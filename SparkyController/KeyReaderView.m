//
//  KeyReaderView.m
//  SkypeAPITest
//
//  Created by John Celenza on 10/17/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "KeyReaderView.h"
#import "SparkyController.h"



@implementation KeyReaderView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		
		//MySparkyController = [SparkyController new];
    }
    return self;
}

//- (void)destroy {
//  /* Release the pool */
//  RELEASE(pool);
//}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)awakeFromNib
{
	//[SkypeAPI setSkypeDelegate:self];
	
}

- (void)keyDown:(NSEvent *)theEvent
{
    NSString *keyChar = [theEvent charactersIgnoringModifiers];
	const char *keyString = [keyChar cString];
	
	
	
	
//    if ( [keyChar isEqualToString:@"c"] ) {
//	[path removeAllPoints];
//	[self setNeedsDisplay:YES];
//    }
	fprintf(stderr,"pressed %s MySparkyController:%x\n",[keyChar cString],MySparkyController);
	
	if (MySparkyController)
	{
		if (!strcmp(keyString,"w"))
		{
			SparkyController *test = MySparkyController;
		
			[MySparkyController MoveStraight:NULL];
		
			fprintf(stderr,"test:%x\n",test);
		}
		else if (!strcmp(keyString,"a"))
		{
			SparkyController *test = MySparkyController;
		
			[MySparkyController MoveLeft:NULL];
		
			fprintf(stderr,"test:%x\n",test);
		}
		else if (!strcmp(keyString,"s"))
		{
			SparkyController *test = MySparkyController;
		
			[MySparkyController MoveReverse:NULL];
		
			fprintf(stderr,"test:%x\n",test);
		}
		else if (!strcmp(keyString,"d"))
		{
			SparkyController *test = MySparkyController;
		
			[MySparkyController MoveRight:NULL];
		
			fprintf(stderr,"test:%x\n",test);
		}
		
		if (!strcmp(keyString,"i"))
		{
			SparkyController *test = MySparkyController;
		
			[MySparkyController MoveStraight:@"_slow"];
		
			fprintf(stderr,"test:%x\n",test);
		}
		else if (!strcmp(keyString,"j"))
		{
			SparkyController *test = MySparkyController;
		
			[MySparkyController MoveLeft:@"_slow"];
		
			fprintf(stderr,"test:%x\n",test);
		}
		else if (!strcmp(keyString,"k"))
		{
			SparkyController *test = MySparkyController;
		
			[MySparkyController MoveReverse:@"_slow"];
		
			fprintf(stderr,"test:%x\n",test);
		}
		else if (!strcmp(keyString,"l"))
		{
			SparkyController *test = MySparkyController;
		
			[MySparkyController MoveRight:@"_slow"];
		
			fprintf(stderr,"test:%x\n",test);
		}
		else if (keyString[0] > '0' && keyString[0] <= '5')
		{
			SparkyController *test = MySparkyController;
		
			[MySparkyController MoveStraight:[NSString stringWithFormat:@"_time_%s",keyString]];
		
			fprintf(stderr,"test:%x\n",test);

		}


	}
}

- (void)setMySparkyController:(SparkyController *)in_skype
{
	MySparkyController = in_skype;
}


@end
