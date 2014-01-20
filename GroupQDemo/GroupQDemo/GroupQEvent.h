//
//  GroupQEvent.h
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/4/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#import <MediaPlayer/MediaPlayer.h>

#import "Spotify.h"

#import "GroupQQueue.h"
#import "GroupQConnection.h"
#import "GroupQEventDelegate.h"
#import "GroupQClient.h"
#import "GroupQMusicCollection.h"
#import "GroupQPlaybackDetail.h"

@interface GroupQEvent : NSObject <NSNetServiceDelegate, GroupQConnectionDelegate, SpotifyPlayerDelegate> {
    bool hasSpotify; // Flag if the host has spotify
}

// A list of all current users
@property (strong, nonatomic) NSMutableArray *userConnections; // List of GroupQConnections
// The event name
@property (strong, nonatomic) NSString *eventName;
// The event password
@property (strong, nonatomic) NSString *eventPassword;
// The event service
@property (strong, nonatomic) NSNetService *eventService;
// The event's delegate
@property (strong, nonatomic) id<GroupQEventDelegate> delegate;

#pragma mark - Event management
// Creates an event with a given name
- (void) createEventWithName: (NSString*) name andPassword: (NSString*) password;
// Ends the event
- (void) endEvent;
// Connects the event to spotify
- (void) connectToSpotify;
- (void) pauseEvent;
- (void) resumeEvent;

#pragma mark - Information management
- (void) tellClientsAboutSpotifyStatus;

#pragma mark - Accessors
- (void) setSpotify: (bool) hasSpotify;
- (bool) hasSpotify;


#pragma mark - Singleton accessor
+ (GroupQEvent *) sharedEvent;
@end
