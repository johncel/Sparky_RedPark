//
//  EditFieldView.h
//  collegemapp
//
//  Created by John Celenza on 8/22/09.
//  Copyright 2009 John Celenza. All rights reserved.
//

#import <Foundation/Foundation.h>


// cell identifier for this custom cell
extern NSString *kCellTextView_ID;

@interface EditFieldView: UITableViewCell {
    IBOutlet UITextView *textView;
	
}

+ (EditFieldView*) createNewTextCellFromNib;

@property (nonatomic, retain) UITextView *textView;

@end

