//
//  BrowseEventsViewController.h
//  GroupQDemo
//
//  Created by Jono Matthews on 4/6/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupQNetworking.h"
#import "ActivityViewController.h"
#import "AppDelegate.h"

@interface BrowseEventsViewController : UITableViewController <GroupQClientDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@end
