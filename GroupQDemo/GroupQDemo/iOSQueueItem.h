//
//  iOSQueueItem.h
//  GroupQDemo
//
//  Created by Jono Matthews on 4/8/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>

// Represents a queue item on the host iOS device.
@interface iOSQueueItem : NSObject <NSCoding>
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *album;
@property (strong, nonatomic) NSString *artist;
@property (strong, nonatomic) NSNumber *playbackDuration;
@property (strong, nonatomic) NSNumber *persistentID;
@end
