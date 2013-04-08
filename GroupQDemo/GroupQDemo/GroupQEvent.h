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

@interface GroupQEvent : NSObject <NSNetServiceDelegate, GroupQConnectionDelegate, SpotifyPlayerDelegate>

// Creates an event with a given name
- (void) createEventWithName: (NSString*) name andPassword: (NSString*) password;

// Broadcasts the event
- (void) broadcastEvent;

// Ends the event
- (void) endEvent;

// A list of all current users
@property (strong, nonatomic) NSMutableArray *userConnections; // List of GroupQConnections

// The event name
@property (strong, nonatomic) NSString *eventName;

// The event password
@property (strong, nonatomic) NSString *eventPassword;

@property (strong, nonatomic) id<GroupQEventDelegate> delegate;

@property (strong, nonatomic) NSNetService *eventService;   // The Bonjour service to broadcast the


// listening socket of the event on

- (void) broadcastMessage: (NSString *) message withHeader: (NSString *) header;
- (void) broadcastObject: (id) object withHeader: (NSString *) header;

+ (GroupQEvent *) sharedEvent;
@end
