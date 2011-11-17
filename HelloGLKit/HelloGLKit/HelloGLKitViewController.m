//
//  HelloGLKitViewController.m
//  HelloGLKit
//
//  Created by Jordan Zucker on 11/15/11.
//  Copyright (c) 2011 University of Illinois. All rights reserved.
//

#import "HelloGLKitViewController.h"

#define ARC4RANDOM_MAX      0x100000000

typedef struct
{
    float Position[3];
    float Color[4];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}}
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

@interface HelloGLKitViewController () {
    float _curRed;
    float _curBlue;
    float _curGreen;
    float _curX;
    float _curY;
    float _curZ;
    BOOL _increasing;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    float _rotation;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@end

@implementation HelloGLKitViewController

@synthesize context = _context;
@synthesize effect = _effect;
@synthesize motionCalculator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //motionCalculator = [[MotionCalculator alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void) setupGL {
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
}

- (void) tearDownGL {
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteBuffers(1, &_indexBuffer);
    
    self.effect = nil;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    timeSinceBackgroundChange = 0;
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    //[self setPreferredFramesPerSecond:4];
    
    //[motionCalculator setUpMotionManager];
    self.motionCalculator = [[MotionCalculator alloc] init];
    
    [self setupGL];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
    
    [motionCalculator stopMotionManager];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - GLKViewDelegate

- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
    //glClearColor(_curRed, 0.0, 0.0, 1.0);
    glClearColor(_curRed, _curGreen, _curBlue, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));
    
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
}

#pragma mark - GLKViewControllerDelegate

- (void) update
{
    double flashRate = [self.motionCalculator processData];
    //NSLog(@"flashRate is %f", flashRate);
    //NSLog(@"timeSinceBackgroundChange is %f", timeSinceBackgroundChange);
    //NSLog(@"timeSinceLastUpdate is %f", self.timeSinceLastUpdate);
    if (flashRate <= timeSinceBackgroundChange && flashRate != 0) {
        //NSLog(@"generate random colors for background");
        _curBlue = ((float)arc4random() / ARC4RANDOM_MAX);
        _curGreen = ((float)arc4random() / ARC4RANDOM_MAX);
        _curRed = ((float)arc4random() / ARC4RANDOM_MAX);
        timeSinceBackgroundChange = 0;
    }
    else
    {
        //NSLog(@"increase background change time");
        timeSinceBackgroundChange += self.timeSinceLastUpdate;
    }
    
    NSLog(@"_cur(x,y,z) = (%f, %f, %f)", _curX, _curY, _curZ);
    //self.view.bounds.size.width
    NSLog(@"width:%f, height:%f", self.view.bounds.size.width, self.view.bounds.size.height);
    if (_curX < self.view.bounds.size.width) {
        _curX -= self.motionCalculator.motionManager.deviceMotion.userAcceleration.x;
    }
    else
    {
        //_curX -= self.motionCalculator.motionManager.deviceMotion.userAcceleration.x;
        NSLog(@"do nothing");
    }
    if (_curY < self.view.bounds.size.height) {
        _curY -= self.motionCalculator.motionManager.deviceMotion.userAcceleration.y;
    }
    else
    {
        //_curY -= self.motionCalculator.motionManager.deviceMotion.userAcceleration.y;
        NSLog(@"do nothing");
    }
    //_curX += self.motionCalculator.motionManager.deviceMotion.userAcceleration.x;
    //_curY += self.motionCalculator.motionManager.deviceMotion.userAcceleration.y;
    //_curZ += self.motionCalculator.motionManager.deviceMotion.userAcceleration.z;

    
    //timeSinceBackgroundChange += self.timeSinceLastUpdate;
    //double flashRate = [self.motionCalculator processData];
    
    /*
    NSLog(@"flashRate is %f", flashRate);
    NSLog(@"timeSinceLastUpdate is %f", self.timeSinceLastUpdate);
    
    if (_increasing)
    {
        _curRed += 1.0 * self.timeSinceLastUpdate;
    }
    else
    {
        _curRed -= 1.0 * self.timeSinceLastUpdate;
    }
    if (_curRed >= 1.0) {
        _curRed = 1.0;
        _increasing = NO;
    }
    if (_curRed <= 0.0) {
        _curRed = 0.0;
        _increasing = YES;
    }
    
    
    _curBlue = ((float)arc4random() / ARC4RANDOM_MAX);
    _curGreen = ((float)arc4random() / ARC4RANDOM_MAX);
    
    //double val = ((double)arc4random() / ARC4RANDOM_MAX);
    
    NSLog(@"R:%f, G:%f, B:%f", _curRed, _curGreen, _curBlue);
     */
    
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 4.0f, 10.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
    _rotation += 90 * self.timeSinceLastUpdate;
    //modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation), 0, 0, 1);
    //modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, motionCalculator.motionManager.deviceMotion.userAcceleration.x, motionCalculator.motionManager.deviceMotion.userAcceleration.y, motionCalculator.motionManager.deviceMotion.userAcceleration.z);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, _curX, _curY, _curZ);
    //modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation), 1, 1, 1);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    //modelViewMatrixTransform = GLKMatrix4Translate(mod, <#float tx#>, <#float ty#>, <#float tz#>)
    
    
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*
    NSLog(@"++++++++++++++++++++++++++++");
    NSLog(@"timeSinceLastUpdate: %f", self.timeSinceLastUpdate);
    NSLog(@"timeSinceLastDraw: %f", self.timeSinceLastDraw);
    NSLog(@"timeSinceFirstResume: %f", self.timeSinceFirstResume);
    NSLog(@"timeSinceLastResume: %f", self.timeSinceLastResume);
    NSLog(@"++++++++++++++++++++++++++++");
     */

    if (self.paused == YES) {
        self.paused = NO;
        NSLog(@"hide menu");
    }
    else
    {
        NSLog(@"display menu");
        self.paused = YES;
    }
    //self.paused = !self.paused;
}

@end
