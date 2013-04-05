//
//  GroupQEventDelegate.h
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/4/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GroupQEventDelegate <NSObject>

// Sent when an event was successfully created (not yet broadcasted)
- (void) eventCreated;

// Sent when an event could not be created
- (void) eventNotCreated;

// Sent when the list of users has changed
- (void) userUpdate;

// Sent when a new message from a user is available
- (void) newTextAvailable: (NSString*) message from: (GroupQConnection*) connection;

// Send when an event was ended
- (void) eventEnded;
@end
