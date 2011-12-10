//
//  KeyReaderView.h
//  SkypeAPITest
//
//  Created by John Celenza on 10/17/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SparkyController.h"

@interface KeyReaderView : NSView {

	SparkyController *MySparkyController;

}

- (void)keyDown:(NSEvent *)theEvent;
- (void)setMySparkyController:(SparkyController *)in_skype;

@end
