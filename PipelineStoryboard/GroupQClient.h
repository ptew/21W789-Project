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

@interface GroupQClient : NSObject <NSNetServiceBrowserDelegate, GroupQConnectionDelegate>

// The event service currently being connected to
@property (strong, nonatomic) NSNetService *eventService;

// The name of the event currently being connected to
@property (strong, nonatomic) NSString *eventName;

// The delegate class for the GroupQ Client
@property (strong, nonatomic) id<GroupQClientDelegate> delegate;

// Start or stop a Bonjour search for events on the network
- (void) startSearchingForEvents;
- (void) stopSearching;

// Connect to a Bonjour service, or disconnect from the currently connected service
- (void) connectToEvent: (NSNetService*) whichEvent;
- (void) disconnect;

// Send text to the current event server
- (void) sendText: (NSString *) text;

// Get a list of all of the current Bonjour events
- (NSArray *) getEvents;

+ (GroupQClient *) sharedClient;
@end
