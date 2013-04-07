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
@end
