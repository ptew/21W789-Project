//
//  ActivityViewController.m
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/4/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "ActivityViewController.h"

@interface ActivityViewController () {
    int counter;
}
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *activityText;
@property (strong, nonatomic) NSTimer *animationTimer;
@end

@implementation ActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (ActivityViewController *) initWithActivityText:(NSString *)text {
    self = [super init];
    self.text = text;
    counter = 0;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateText) userInfo:nil repeats:YES];
    //[self updateText];
}

- (void) viewDidAppear:(BOOL)animated {
    NSLog(@"View appeared.");
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.animationTimer invalidate];
}

- (void)updateText {
    if (counter > 5)
        counter = 0;
    NSMutableString *newString = [[NSMutableString alloc] initWithString:self.text];
    for (int i=0; i<counter; i++) {
         [newString appendString:@"."];
    }
    counter++;
    self.activityText.text = [NSString stringWithString:newString];
}

@end
