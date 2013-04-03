//
//  UsersViewController.h
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/1/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UsersViewController : UITableViewController <NSNetServiceDelegate>
@property (strong, nonatomic) NSString *eventName;
@end
