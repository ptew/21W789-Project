//
//  RequestsViewController.h
//  GroupQDemo
//
//  Created by Jono Matthews on 4/27/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupQNetworking.h"

@interface RequestsViewController : UITableViewController <GroupQQueueDelegate, GroupQClientDelegate, SpotifyConnectionDelegate, UIActionSheetDelegate>

- (IBAction)eventAction:(UIBarButtonItem *)sender;
@property (strong, nonatomic) SpotifyConnection *loginConnection;
@property (strong, nonatomic) SPLoginViewController *spLoginController;
@end
