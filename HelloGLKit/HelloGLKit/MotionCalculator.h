//
//  MotionCalculator.h
//  iLightShow
//
//  Created by Jordan Zucker on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface MotionCalculator : NSObject
{
    CMMotionManager *motionManager;
    NSMutableArray *flashRateArray;
}

@property (nonatomic, retain) NSMutableArray *flashRateArray;
@property (nonatomic, retain) CMMotionManager *motionManager;

- (void) setUpMotionManager;

- (double) processData;

- (void) stopMotionManager;

@end
