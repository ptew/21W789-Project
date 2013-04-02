//
//  NewEventViewController.m
//  Pipeline
//
//  Created by Jono Matthews on 4/1/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "NewEventViewController.h"

@interface NewEventViewController ()

@end

@implementation NewEventViewController

- (id) init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Create an Event";
    
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    doneButton.titleLabel.text = @"Done!";
    self.tableView.tableFooterView = doneButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    else if (section == 1) {
        return 3;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *returnCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (returnCell == nil) {
        returnCell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    }
    
    returnCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITextField *inputField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
    inputField.adjustsFontSizeToFitWidth = TRUE;
    inputField.textColor = [UIColor blackColor];
    inputField.backgroundColor = [UIColor clearColor];
    inputField.textAlignment = NSTextAlignmentLeft;
    inputField.tag = 0;
    inputField.delegate = self;
    [inputField setEnabled:TRUE];
    if (indexPath.section == 0) {
        if(indexPath.row == 0) {
            returnCell.textLabel.text = @"Name";
            inputField.placeholder = @"My Event Name";
            inputField.returnKeyType = UIReturnKeyNext;
            [inputField becomeFirstResponder];
        }
        if(indexPath.row == 1) {
            returnCell.textLabel.text = @"Password";
            inputField.placeholder = @"Optional";
            inputField.returnKeyType = UIReturnKeyDone;
            inputField.secureTextEntry = TRUE;
        }
        [returnCell.contentView addSubview:inputField];
    }
    else if (indexPath.section == 1) {
        returnCell.textLabel.text = @"Nothing yet...";
    }
    else {
        returnCell.textLabel.text = @"other..";
    }
    return returnCell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return @"Event Information";
    else if (section == 1)
        return @"Connect To Spotify";
    else
        return nil;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Test: %@", self.tableView.tableFooterView);
    if ([textField.placeholder isEqualToString:@"My Event Name"]) {
        [[[[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection: 0]] contentView] subviews]lastObject] becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
