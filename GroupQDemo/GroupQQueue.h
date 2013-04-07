//
//  GroupQQueue.h
//  GroupQDemo
//
//  Created by Jono Matthews on 4/7/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupQQueue : NSObject <NSCoding>
@property (strong, nonatomic) id nowPlaying;
@property (strong, nonatomic) NSMutableArray *queuedSongs;
@end
