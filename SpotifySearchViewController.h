//
//  SpotifySearchViewController.h
//  GroupQDemo
//
//  Created by T. S. Cobb on 4/7/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Spotify.h"
#import "GroupQClient.h"

@interface SpotifySearchViewController : UITableViewController <SpotifySearcherDelegate, UIActionSheetDelegate, UISearchBarDelegate>
@property (strong, nonatomic) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet UISearchBar *searchText;

@end
