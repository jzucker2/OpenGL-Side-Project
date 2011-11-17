//
//  HelloGLKitViewController.h
//  HelloGLKit
//
//  Created by Jordan Zucker on 11/15/11.
//  Copyright (c) 2011 University of Illinois. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "MotionCalculator.h"

@interface HelloGLKitViewController : GLKViewController
{
    MotionCalculator *motionCalculator;
    double timeSinceBackgroundChange;
}
@property (nonatomic, retain) MotionCalculator *motionCalculator;

@end
