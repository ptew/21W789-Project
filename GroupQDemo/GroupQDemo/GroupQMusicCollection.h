//
//  GroupQMusicCollection.h
//  GroupQDemo
//
//  Created by Jono Matthews on 4/8/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface GroupQMusicCollection : NSObject <NSCoding>
- (GroupQMusicCollection *) initWithSongs:(MPMediaQuery*) songs artists: (MPMediaQuery *) artists albums: (MPMediaQuery *) albums playlists: (MPMediaQuery *) playlists;

@property (strong, nonatomic) NSArray *songSectionNames;
@property (strong, nonatomic) NSArray *artistSectionNames;
@property (strong, nonatomic) NSArray *albumSectionNames;
@property (strong, nonatomic) NSArray *playlistSectionNames;
@property (strong, nonatomic) NSArray *songCollection;
@property (strong, nonatomic) NSArray *artistCollection;
@property (strong, nonatomic) NSArray *albumCollection;
@property (strong, nonatomic) NSArray *playlistCollection;
@end
