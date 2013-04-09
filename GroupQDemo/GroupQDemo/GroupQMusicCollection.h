//
//  GroupQMusicCollection.h
//  GroupQDemo
//
//  Created by Jono Matthews on 4/8/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "iOSQueueItem.h"

// Holds a group of iOS Queue Items, sorted by various items
@interface GroupQMusicCollection : NSObject <NSCoding>

// Build the songs list from querying the device's media library
- (GroupQMusicCollection *) initWithSongs:(MPMediaQuery*) songs artists: (MPMediaQuery *) artists albums: (MPMediaQuery *) albums playlists: (MPMediaQuery *) playlists;

@property (strong, nonatomic) NSMutableArray *songSectionNames;
@property (strong, nonatomic) NSMutableArray *artistSectionNames;
@property (strong, nonatomic) NSMutableArray *albumSectionNames;

@property (strong, nonatomic) NSMutableArray *songCollection;
@property (strong, nonatomic) NSMutableArray *artistCollection;
@property (strong, nonatomic) NSMutableArray *albumCollection;
@property (strong, nonatomic) NSMutableDictionary *playlistCollection;
@end
