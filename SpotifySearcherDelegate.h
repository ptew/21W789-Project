//
//  SpotifySearcherDelegate.h
//  SpotifyProofOfConcept
//
//  Created by Bradley Gross on 4/5/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>

//This delegate is called whenever the SpotifySearcher returns results.
@protocol SpotifySearcherDelegate <NSObject>
- (void) searchReturnedResults: (NSArray*) results;
- (void) searchResultedInError;
@end
