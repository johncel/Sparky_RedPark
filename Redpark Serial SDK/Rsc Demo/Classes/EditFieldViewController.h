//
//  EditFieldViewController.h
//  collegemapp
//
//  Created by John Celenza on 8/24/09.
//  Copyright 2009 John Celenza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EditFieldViewController : UITableViewController <UITextViewDelegate> {
    IBOutlet UITableView *tbView;
    NSString *updateString;
    RootViewController *rootViewController;
}
@property (nonatomic, retain) NSString *updateString;
@property (nonatomic, retain) IBOutlet UITableView *tbView;
@property (nonatomic, retain) RootViewController *rootViewController;

- (void)save:(id)sender;

@end


