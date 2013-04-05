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
#import "GroupQConnection.h"
#import "GroupQEventDelegate.h"
@interface GroupQEvent : NSObject <NSNetServiceDelegate, GroupQConnectionDelegate>

// Creates an event with a given name
- (void) createEventWithName: (NSString*) name;

// Broadcasts the event
- (void) broadcastEvent;

// Ends the event
- (void) endEvent;

// The event delegate
@property (strong, nonatomic) id<GroupQEventDelegate> delegate;

// A list of all current users
@property (strong, nonatomic) NSMutableArray *userConnections; // List of GroupQConnections

// The event name
@property (strong, nonatomic) NSString *eventName;

+ (GroupQEvent *) sharedEvent;
@end
