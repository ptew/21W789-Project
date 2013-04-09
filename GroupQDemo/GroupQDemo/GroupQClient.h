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
    bool isHost;            // Flag if this client is actually the event host
    
    bool isDJ;              // Flag if this client is a DJ or a listener
    bool isSongPlaying;     // Flag if the music player is currently playing a song
    bool hostHasSpotify;    // Flag if the host has Spotify functionality
    
    float songVolume;       // The song's volume leve
    float songProgress;     // The song's progress
}

// The event service currently being connected to
@property (strong, nonatomic) NSNetService *eventService;
// The name of the event currently being connected to
@property (strong, nonatomic) NSString *eventName;

// The delegate class for the GroupQ Client
@property (strong, nonatomic) id<GroupQClientDelegate> delegate;

// The music queue and library
@property (strong, nonatomic) GroupQQueue *queue;
@property (strong, nonatomic) GroupQMusicCollection *library;

// The current items being picked by the picker
@property (strong, nonatomic) NSMutableArray *pickerSongs;

#pragma mark - Event searching and management
// Start or stop a Bonjour search for events on the network
- (void) startSearchingForEvents;
- (void) stopSearching;
// Connect to a Bonjour service, or disconnect from the currently connected service
- (void) connectToEvent: (NSNetService*) whichEvent;
// Connect as a host
- (void) connectAsHost;
- (void) disconnect;
// Get a list of all of the current Bonjour events
- (NSArray *) getEvents;

#pragma mark - Connection management
// Send text to the current event server
- (void) sendMessage: (NSString *) message withHeader:(NSString *)header;
- (void) sendObject: (id) object withHeader:(NSString *)header;

#pragma mark - Accessors
- (bool) isDJ;
- (void) setDJ:(bool)dj;

- (bool) isHost;
- (bool) isSongPlaying;
- (bool) hostHasSpotify;
- (float) songVolume;

- (float) songProgress;
- (void)  setSongProgress: (float)progress;

#pragma mark - Messages to send to the server
// Client information
- (void) tellServerIfDJ;
- (void) tellServerToSendPlaybackDetail;

// Queue management
- (void) tellServerToAddSongs:(NSArray *)songs;
- (void) tellServerToMoveSongFrom:(int)index To:(int)newIndex;
- (void) tellServerToDeleteSong:(int)index;
- (void) tellServerToPlaySong:(int)index;
- (void) tellServerToaddSpotifySong:(SpotifyQueueItem *)song;

// Playback management
- (void) tellServerToResumeSong;
- (void) tellServerToPauseSong;
- (void) tellServerToSetVolume: (NSNumber *) level;

#pragma mark - Singleton accessor
+ (GroupQClient *) sharedClient;
@end
