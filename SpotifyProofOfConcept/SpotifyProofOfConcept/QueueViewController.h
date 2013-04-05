//
//  QueueViewController.h
//  GroupMusic
//
//  Created by Parker Allen Tew on 4/2/13.
//  Copyright (c) 2013 Parker Allen Tew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface QueueViewController : UITableViewController<MPMediaPickerControllerDelegate,UIActionSheetDelegate>{
MPMediaItemCollection		*userMediaItemCollection;
MPMusicPlayerController		*musicPlayer;
IBOutlet UITableView *queueTableView;
}

@property (nonatomic, retain)	MPMusicPlayerController	*myPlayer;
@property (nonatomic, retain)	MPMediaItemCollection	*userMediaItemCollection;
@property (nonatomic, weak) UIActionSheet *songActionSheet;
@property (nonatomic, weak) UIActionSheet *mediaActionSheet;
@property (nonatomic) NSIndexPath *currentlySelectedSong;
@property (nonatomic, retain) IBOutlet UITableView *queueTableView;
@property (nonatomic) BOOL *firstLoad;

@end
