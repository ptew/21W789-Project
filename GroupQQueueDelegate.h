//
//  GroupQQueueDelegate.h
//  GroupQDemo
//
//  Created by T. S. Cobb on 4/8/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GroupQQueueDelegate <NSObject>

// Called whenever the queue or 'Now Playing' item changed
- (void) queueDidChange;
@end
