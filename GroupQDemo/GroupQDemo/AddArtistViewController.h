//
//  AddArtistViewController.h
//  GroupQDemo
//
//  Created by Parker Allen Tew on 4/7/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupQNetworking.h"
#import <MediaPlayer/MPMediaQuery.h>


@interface AddArtistViewController : UIViewController<UITableViewDelegate>
- (IBAction)donePressed:(UIBarButtonItem *)sender;
- (IBAction)cancelPressed:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UITableView *pickerTableView;

@end
