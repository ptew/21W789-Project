//
//  SpotifyConnectionDelegate.h
//  SpotifyProofOfConcept
//
//  Created by T. S. Cobb on 4/4/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SpotifyConnectionDelegate <NSObject>
- (void) messageFromSpotify:(NSString *) message;
@end
