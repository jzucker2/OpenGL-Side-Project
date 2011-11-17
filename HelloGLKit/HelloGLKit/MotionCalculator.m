//
//  MotionCalculator.m
//  iLightShow
//
//  Created by Jordan Zucker on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MotionCalculator.h"

@implementation MotionCalculator
@synthesize motionManager;
@synthesize flashRateArray;

#pragma mark - Lifecycle methods
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        //NSLog(@"motion calculator init");
        [self setUpMotionManager];
        flashRateArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) dealloc
{
    //NSLog(@"motion calculator dealloc");
    //[motionManager stopDeviceMotionUpdates];
    //[motionManager release];
    //[super dealloc];
}

#pragma mark - Motion Manager methods

- (void) setUpMotionManager
{
    //NSLog(@"set up motion manager");
    motionManager = [[CMMotionManager alloc] init];
    // ensure data is available
    if (!motionManager.isDeviceMotionAvailable) {
        //fail gracefully
    }
    
    // set desired update interval (60 Hz in this case)
    motionManager.deviceMotionUpdateInterval = 1/100.0;
    
    // start updates
    [motionManager startDeviceMotionUpdates];
}

- (double) processData
{
    CMDeviceMotion *newestDeviceMotion = motionManager.deviceMotion;
    //NSLog(@"newestDeviceMotion is %@", newestDeviceMotion);
    double userX = newestDeviceMotion.userAcceleration.x;
    double userY = newestDeviceMotion.userAcceleration.y;
    double userZ = newestDeviceMotion.userAcceleration.z;
    //NSLog(@"userX: %f, userY: %f, userZ: %f", userX, userY, userZ);
    double result = sqrt(userX*userX + userY*userY + userZ*userZ);
    //NSLog(@"result is %f", result);
    double flashratesquare = 1/(result*result*result*result*result*result);
    /*
    double flashrate = 1/result;
    if (flashrate>1) {
        flashrate = 0;
    }
     */
    if (flashratesquare>1) {
        flashratesquare = 0;
    }
    /*
    NSLog(@"--------------------------");
    NSLog(@"result is %f", result);
    NSLog(@"flashratesquare is %f", flashratesquare);
    //NSLog(@"flashrate is %f", flashrate);
    NSLog(@"--------------------------");
     */

    
    return flashratesquare;
    
}

- (void) stopMotionManager
{
    [motionManager stopDeviceMotionUpdates];
    motionManager = nil;
}





@end
