//
//  ViewController.h
//  SpotifyProofOfConcept
//
//  Created by T. S. Cobb on 4/4/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotifyPlayer.h"
#import "SpotifySearcherDelegate.h"

@interface ViewController : UIViewController <UITextFieldDelegate, SpotifySearcherDelegate>{
    
}
@property (strong, nonatomic) SpotifyPlayer* spotifyPlayer;
@property (weak, nonatomic) IBOutlet UITextField *inputText1;
@property (weak, nonatomic) IBOutlet UITextField *inputText2;
- (IBAction)playButton:(UIButton *)sender;
- (IBAction)searchButton:(UIButton *)sender;


@end
