//
//  GroupQConnectionDelegate.h
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/4/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupQConnection.h"

@class GroupQConnection;

@protocol GroupQConnectionDelegate <NSObject>

// Sent when a connection was successfully established
- (void) connectionDidConnect: (GroupQConnection*) connection;
// Sent when a connection failed
- (void) connectionDidNotConnect: (GroupQConnection*) connection;
// Sent when a connection was lost
- (void) connectionDisconnected: (GroupQConnection*) connection;


// Sent when new objects or text came from the other end of the connection
- (void) connection: (GroupQConnection*) connection receivedMessage: (NSString*) message withHeader: (NSString *) header;
- (void) connection:(GroupQConnection *)connection receivedObject:(NSData *)message withHeader:(NSString *)header;
@end
