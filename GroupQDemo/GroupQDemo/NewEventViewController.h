//
//  NewEventViewController.h
//  GroupQDemo
//
//  Created by Jono Matthews on 4/6/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupQNetworking.h"
#import "ActivityViewController.h"
#import "Spotify.h"

@interface NewEventViewController : UITableViewController <UITextFieldDelegate, GroupQEventDelegate, SpotifyConnectionDelegate, GroupQClientDelegate>

// Outlets
@property (weak, nonatomic) IBOutlet UILabel *spotifyConnectedLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *connectedLabelCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *spotifyLoginButton;
@property (weak, nonatomic) IBOutlet UILabel *spotifyLoginLabel;

@end
