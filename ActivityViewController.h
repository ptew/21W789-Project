//
//  ActivityViewController.h
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/4/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityViewController : UIViewController
@property (strong, nonatomic) NSString *text;

- (ActivityViewController *) initWithActivityText:(NSString *) text;
@end
