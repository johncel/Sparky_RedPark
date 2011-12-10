//
//  EditFieldView.m
//  collegemapp
//
//  Created by John Celenza on 8/22/09.
//  Copyright 2009 John Celenza. All rights reserved.
//

#import "EditFieldView.h"

// cell identifier for this custom cell
NSString* kCellTextView_ID = @"CellTextView_ID";

@implementation EditFieldView
@synthesize textView;

//Text View contstants
#define kUITextViewCellRowHeight 150.0

//Helper method to create the workout cell from a nib file...
+ (EditFieldView*) createNewTextCellFromNib { 
	NSLog(@"HERE!\n");
    NSArray* nibContents = [[NSBundle mainBundle] loadNibNamed:@"TextViewCell" owner:self options:nil]; 
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator]; 
    EditFieldView* tCell = nil; 
    NSObject* nibItem = nil; 
    while ( (nibItem = [nibEnumerator nextObject]) != nil) { 
        if ( [nibItem isKindOfClass: [EditFieldView class]]) { 
            tCell = (EditFieldView*) nibItem; 
            if ([tCell.reuseIdentifier isEqualToString: kCellTextView_ID]) 
                break; // we have a winner 
            else 
                tCell = nil; 
        } 
    } 
    return tCell; 
} 

- (void)dealloc
{
  //  [EditFieldView release];
    [super dealloc];
}

@end
