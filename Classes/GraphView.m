//
//  GraphView.m
//  Calculator
//
//  Created by Matthew Fichman on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView
@synthesize scale, origin, delegate;

#define DEFAULT_SCALE 32
#define SCALE_KEY @"GraphViewScale"
#define ORIGINX_KEY @"GraphViewOriginX"
#define ORIGINY_KEY @"GraphViewOriginY"

- (void)setup
{

	/* 
	 * If defaults are not set, then this will return 0
	 * and scale will be set to DEFAULT_SCALE 
	 */
	self.scale = [[NSUserDefaults standardUserDefaults] doubleForKey:SCALE_KEY];
	
	/* If defaults are not set, then origin will be set to (0, 0) */
	origin.x = [[NSUserDefaults standardUserDefaults] doubleForKey:ORIGINX_KEY];
	origin.y = [[NSUserDefaults standardUserDefaults] doubleForKey:ORIGINY_KEY];
	self.contentMode = UIViewContentModeRedraw;
	self.backgroundColor = [UIColor whiteColor];
}

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) {
        // Initialization code  
		[self setup];
	}
    return self;
}

- (void)awakeFromNib
{
	[self setup];
}

/* Handles the pinch gesture by scaling the view */
- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
	if (UIGestureRecognizerStateChanged == gesture.state ||
		UIGestureRecognizerStateEnded == gesture.state) {
		
		self.scale *= gesture.scale;
		gesture.scale = 1;
	}
}

/* Handles the pan gesture by moving the graph origin */
- (void)pan:(UIPanGestureRecognizer *)gesture
{
	if (UIGestureRecognizerStateChanged == gesture.state ||
		UIGestureRecognizerStateEnded == gesture.state) {
		
		CGPoint translation = [gesture translationInView:self];
		CGPoint newOrigin;
		newOrigin.x = translation.x / self.scale + self.origin.x;
		newOrigin.y = translation.y / self.scale + self.origin.y;
		self.origin = newOrigin;
		[gesture setTranslation:CGPointZero inView:self];
	}
}

/* Handles a double-tap gesture by setting origin to zero */
- (void)tap:(UITapGestureRecognizer *)gesture
{
	if (UIGestureRecognizerStateChanged == gesture.state ||
		UIGestureRecognizerStateEnded == gesture.state) {
		
		self.origin = CGPointZero;
	}
}

/* Sets the scale, making sure that it is valid, and redraws the view. */
- (void)setScale:(double)aScale
{
	if (aScale > 0) {
		if (scale != aScale) {
			scale = aScale;
		
			/* By saving the scale default here, whenever the scale changes, it is saved */
			[[NSUserDefaults standardUserDefaults] setDouble: aScale forKey:SCALE_KEY];
			[[NSUserDefaults standardUserDefaults] synchronize];
			[self setNeedsDisplay];
		}
	} else {
		scale = DEFAULT_SCALE;
	}
}

/* Sets the origin and redraws the view. */
- (void)setOrigin:(CGPoint)anOrigin
{
	if (origin.x != anOrigin.x || origin.y != anOrigin.y) {
		origin = anOrigin;
		
		/* By saving the origin default here, whenever the origin changes, it is saved */
		[[NSUserDefaults standardUserDefaults] setDouble: origin.x forKey:ORIGINX_KEY];
		[[NSUserDefaults standardUserDefaults] setDouble: origin.y forKey:ORIGINY_KEY];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self setNeedsDisplay];
	}
}

/* 
 * Returns the y-coordinate in screen space for the given X with the
 * given scale and origin.
 */
- (CGFloat)yCoordFor:(CGFloat)viewX withOrigin:(CGPoint)anOrigin
{
	double x = (viewX - anOrigin.x) / self.scale;
	double y = [delegate outputForGraphView:self withInput: x];
	CGFloat viewY = -y * self.scale + anOrigin.y;
	
	return viewY;
}

/* Draws the axes and plots the graph */
- (void)drawRect:(CGRect)rect 
{
	
	/* Get and save the current context */
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
	
	/* Set the origin to the center of the clipping rectangle */
	CGPoint anOrigin;
	anOrigin.x = origin.x * scale + rect.origin.x + rect.size.width/2.0;
	anOrigin.y = origin.y * scale + rect.origin.y + rect.size.height/2.0;
	
	/* Draw the axes in black */
	[[UIColor blackColor] setStroke];
	[AxesDrawer drawAxesInRect:rect originAtPoint:anOrigin scale:self.scale];
	
	/* Plot the graph using CGContextAddLineToPoint */
	CGFloat minX = 0;
	CGFloat maxX = rect.size.width;
	CGContextBeginPath(context);
	
	CGFloat viewX = minX;
	CGFloat viewY = [self yCoordFor: viewX withOrigin: anOrigin];
	CGContextMoveToPoint(context, viewX, viewY); /* Move to the first point */
	BOOL discontinuity = false;
	
	while (viewX < maxX) {
		
		if ([self respondsToSelector:@selector(contentScaleFactor)]) {
			viewX += 1.0 /self.contentScaleFactor; /* Advance by 1 pixel */
		} else {
			viewX += 1.0;
		}
		viewY = [self yCoordFor: viewX withOrigin: anOrigin];
		
		/* Skip any values that are NAN... */
		if (viewY == NAN) {
			discontinuity = true;
		} else if (discontinuity) {
			discontinuity = false;
			CGContextMoveToPoint(context, viewX, viewY);
		} else {
			CGContextAddLineToPoint(context, viewX, viewY);
		}
	}
	
	/* Now actually draw the line in blue */
	[[UIColor blueColor] setStroke];
	CGContextDrawPath(context, kCGPathStroke);
	
	/* Reset the graphics context */
	UIGraphicsPopContext();
}


- (void)dealloc 
{
    [super dealloc];
}


@end
