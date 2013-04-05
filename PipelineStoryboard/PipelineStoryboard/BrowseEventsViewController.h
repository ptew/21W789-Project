//
//  ViewController.h
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/1/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupQNetworking.h"
#import "InEventViewController.h"
#import "ActivityViewController.h"

@interface BrowseEventsViewController : UITableViewController <GroupQClientDelegate, UIActionSheetDelegate>

- (void) joinEvent: (NSNetService*) event;
@end
