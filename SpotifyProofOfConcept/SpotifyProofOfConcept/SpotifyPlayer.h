//
//  SpotifyPlayer.h
//  SpotifyProofOfConcept
//
//  Created by T. S. Cobb on 4/4/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaLibSpotify.h"

@interface SpotifyPlayer : NSObject {
    // Public member variables (NOT PROPERTIES)
}

// Public functions and properties

- (IBAction)playTrack:(NSURL *) trackURL;
@end
