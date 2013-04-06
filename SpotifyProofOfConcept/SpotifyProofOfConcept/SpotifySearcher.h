//
//  SpotifySearcher.h
//  SpotifyProofOfConcept
//
//  Created by T. S. Cobb on 4/5/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaLibSpotify.h"
#import "SpotifySearcherDelegate.h"
#import "SpotifyQueueItem.h"

@interface SpotifySearcher : NSObject <NSURLConnectionDataDelegate, NSXMLParserDelegate>

@property (strong, nonatomic) NSURL *spotifySearchURL;
@property (strong, nonatomic) id<SpotifySearcherDelegate> delegate;
- (void)search:(NSString*)query;
+ (SpotifySearcher *) sharedSearcher;
@end
