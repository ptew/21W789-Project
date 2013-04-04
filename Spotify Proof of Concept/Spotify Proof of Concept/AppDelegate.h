//
//  AppDelegate.h
//  Spotify Proof of Concept
//
//  Created by T. S. Cobb on 4/3/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, SPSessionDelegate, SPSessionPlaybackDelegate>
{
    UIViewController *_mainViewController;
    
    SPPlaybackManager *_playbackManager;
    SPTrack *_currentTrack;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UIViewController *mainViewController;

@property (nonatomic, strong) SPTrack *currentTrack;
@property (nonatomic, strong) SPPlaybackManager *playbackManager;

- (IBAction)playTrack:(id)sender;

@end
