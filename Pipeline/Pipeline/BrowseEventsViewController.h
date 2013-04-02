//
//  BrowseEventsViewController.h
//  Pipeline
//
//  Created by Jono Matthews on 4/1/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowseEventsViewController : UITableViewController

- (void) addEvent;

@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) UIBarButtonItem *addButton;

@end
