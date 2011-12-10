//
//  EditFieldViewController.m
//  collegemapp
//
//  Created by John Celenza on 8/24/09.
//  Copyright 2009 John Celenza. All rights reserved.
//

#import "RootViewController.h"
#import "EditFieldViewController.h"
#import "EditFieldView.h"

//Text View contstants
#define kUITextViewCellRowHeight 150.0

EditFieldView *gtextViewCell = nil;


@implementation EditFieldViewController
@synthesize updateString;
@synthesize tbView;
@synthesize rootViewController;


#define COLLEGE_CATEGORIES_NAVIGATION_OFFSET 2

- (void)save:(id)sender
{
    /*
     Save data from the text view to the variable and then pop back to the root view.
     Normally , this is where I would save data to the database. To keep the example simple
     I am simply setting the variable in the root controller to match that of my note.
	 */
	
    EditFieldView *cell = (EditFieldView *) [tbView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    self.updateString = [cell.textView text];
 	
    NSLog(@"self.updateString:%@\n",self.updateString);

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // provide a Save button to dismiss the keyboard
    UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveItem;
    [saveItem release];
	
	gtextViewCell = [EditFieldView createNewTextCellFromNib];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark CollegeCategories methods
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result;
    result = kUITextViewCellRowHeight;    
    return result;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    //EditFieldView *cell = (EditFieldView *) [tableView dequeueReusableCellWithIdentifier:kCellTextView_ID];
    EditFieldView *cell = [EditFieldView createNewTextCellFromNib];
	//EditFieldView *cell = gtextViewCell;
	
//    if (cell == nil) {
//        cell = [EditFieldView createNewTextCellFromNib];
//    }
	
    // Set up the cell...
//    cell.textView.text = self.updateString;
//    cell.textView.text = [NSString stringWithFormat:@"HA"];
#if 1
    [cell.textView becomeFirstResponder];
    cell.textView.delegate = self;
//	cell.textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
//	cell.textView.autocorrectionType = UITextAutocorrectionTypeYes;
//	cell.textView.dataDetectorTypes = UIDataDetectorTypeAll;
//	NSLog([NSString stringWithFormat:@"schoolsObjectType:%@",schoolsObjectType]);
		cell.textView.text = @"";
		cell.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
		cell.textView.dataDetectorTypes = UIDataDetectorTypeNone;
		cell.textView.autocorrectionType = UITextAutocorrectionTypeNo;

/*
	NSRange range = [schoolsObjectType rangeOfString:@"PASSWORD"];
    if (range.location != NSNotFound)
	{
		cell.textView.text = @"";
		cell.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
		cell.textView.dataDetectorTypes = UIDataDetectorTypeNone;
		cell.textView.autocorrectionType = UITextAutocorrectionTypeNo;
//		cell.textView.secureTextEntry = TRUE;

	}
	
	range = [schoolsObjectType rangeOfString:@"URL"];
    if (range.location != NSNotFound)
	{
		cell.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
		cell.textView.dataDetectorTypes = UIDataDetectorTypeNone;
		cell.textView.autocorrectionType = UITextAutocorrectionTypeNo;
	}
	
		
*/
#endif
    return cell;
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.rootViewController.updateString = self.updateString;
}

//text view delegate stuff
- (void)textViewDidChange:(UITextView *)textView
{
}


@end
