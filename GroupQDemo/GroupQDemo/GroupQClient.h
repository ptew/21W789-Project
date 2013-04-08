//
//  GroupQClient.h
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/4/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupQConnection.h"
#import "GroupQConnectionDelegate.h"
#import "GroupQClientDelegate.h"
#import "GroupQQueue.h"
#import "GroupQEvent.h"
#import "GroupQMusicCollection.h"

@interface GroupQClient : NSObject <NSNetServiceBrowserDelegate, GroupQConnectionDelegate> {
    bool isDJ;
    bool isHost;
    bool isSongPlaying;
    float songVolume;
    float songProgress;
}
- (void) tellServerToAddSongs:(NSArray *)songs;
- (void) tellServerToMoveSongFrom:(int)index To:(int)newIndex;
- (void) tellServerToDeleteSong:(int)index;
- (void) tellServerToPlaySong:(int)index;
- (void) tellServerToaddSpotifySong:(SpotifyQueueItem *)song;

// The event service currently being connected to
@property (strong, nonatomic) NSNetService *eventService;

// The name of the event currently being connected to
@property (strong, nonatomic) NSString *eventName;

// The delegate class for the GroupQ Client
@property (strong, nonatomic) id<GroupQClientDelegate> delegate;

@property (strong, nonatomic) GroupQQueue *queue;
@property (strong, nonatomic) GroupQMusicCollection *library;
@property (strong, nonatomic) NSMutableArray *pickerSongs;

// Start or stop a Bonjour search for events on the network
- (void) startSearchingForEvents;
- (void) stopSearching;

// Connect to a Bonjour service, or disconnect from the currently connected service
- (void) connectToEvent: (NSNetService*) whichEvent;
- (void) disconnect;

// Send text to the current event server
- (void) sendMessage: (NSString *) message withHeader:(NSString *)header;

- (void) sendObject: (id) object withHeader:(NSString *)header;

- (void) connectAsHost;

// Get a list of all of the current Bonjour events
- (NSArray *) getEvents;

- (bool) isDJ;
- (void) setDJ:(bool)dj;

- (bool) isHost;
- (void) setHost:(bool)isHost;

+ (GroupQClient *) sharedClient;
@end
