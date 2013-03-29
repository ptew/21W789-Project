//
//  Spotify.m
//  GroupQ
//
//  Created by Parker Allen Tew on 3/28/13.
//  Copyright (c) 2013 Parker Allen Tew. All rights reserved.
//

#import "Spotify.h"

@interface Spotify ()

@end

@implementation Spotify

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Spotify", @"Spotify");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
