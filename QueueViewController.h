//
//  QueueViewController.h
//  GroupMusic
//
//  Created by Parker Allen Tew on 4/2/13.
//  Copyright (c) 2013 Parker Allen Tew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "GroupQNetworking.h"
#import "Spotify.h"

@interface QueueViewController : UITableViewController<UIActionSheetDelegate, GroupQClientDelegate, GroupQQueueDelegate, SpotifyConnectionDelegate>
@end
