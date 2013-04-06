//
//  GroupQConnection.h
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/4/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupQConnectionDelegate.h"

@interface GroupQConnection : NSObject <NSStreamDelegate>
// Connects to a service
- (void) connectWithService: (NSNetService*) service;

// Connects to a socket handle
- (void) connectWithSocketHandle: (CFSocketNativeHandle) handle;

// Disconnects everything
- (void) disconnectStreams: (BOOL) sendDisconnect;

// Sends text to the other end of the connection
- (void) sendMessage: (NSString*) message withHeader: (NSString*) header;

// The connection's delegate
@property (strong, nonatomic) id<GroupQConnectionDelegate> delegate;

@end
