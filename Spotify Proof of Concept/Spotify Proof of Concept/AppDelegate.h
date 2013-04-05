//
//  AppDelegate.h
//  Spotify Proof of Concept
//
//  Created by T. S. Cobb on 4/3/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, SPSessionDelegate, SPSessionPlaybackDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) SPPlaybackManager *playbackManager;
- (IBAction)playTrack:(id)sender;

@end
