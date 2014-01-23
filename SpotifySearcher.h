//
//  SpotifySearcher.h
//  SpotifyProofOfConcept
//
//  Created by Bradley Gross on 4/5/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaLibSpotify.h"
#import "SpotifySearcherDelegate.h"
#import "SpotifyQueueItem.h"

@interface SpotifySearcher : NSObject <NSURLConnectionDataDelegate, NSXMLParserDelegate>

/*
 Various parser states that refer to which tag has been read so the parser knows which end
 tag to look for
 */
typedef enum parserStateTaypes{
    NONE,
    ALBUM,
    ARTIST,
    TRACK,
    LENGTH,
} ParserState;

//Singleton class which is used to query searches
+ (SpotifySearcher *) sharedSearcher;

//Delegate which informs when search results are found.
@property (strong, nonatomic) id<SpotifySearcherDelegate> delegate;

/*
 Performs an asyncronous search on the spotify library using their web based search api. The
 search is performed using http requests LOOKING FOR TRACKS. This does not require a SPSession
 to perform. The data is then parsed out of the returned xml and added to SpotifyQueueItems. Once
 all of the data has been parsed, the searchReturnedResults method is fired in the Spotify
 Searcher Delegate.
 */
- (void)search:(NSString*)query;

@end
