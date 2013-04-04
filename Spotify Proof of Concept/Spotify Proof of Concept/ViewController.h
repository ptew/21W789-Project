//
//  ViewController.h
//  Spotify Proof of Concept
//
//  Created by T. S. Cobb on 4/3/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"

@interface ViewController : UIViewController
{    
    SPPlaybackManager *_playbackManager;
    SPTrack *_currentTrack;
}

@property (nonatomic, strong) SPTrack *currentTrack;

- (IBAction)Track:(UITextField *)sender forEvent:(UIEvent *)event;
- (IBAction)Accept:(UIButton *)sender;

@end
