//
//  GraphViewController.m
//  Calculator
//
//  Created by Matthew Fichman on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorBrain.h"

#define EXPRESSION_KEY @"GraphViewControllerExpression"

@interface GraphViewController() 
@property (retain) IBOutlet GraphView *graphView;
@end


@implementation GraphViewController
@synthesize expression, graphView;

- (id)init {
	if ((self = [super init])) {
		self.title = @"Graph";
	}
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)loadView {
	/* Load the expression model from the file */
	id plist = [[NSUserDefaults standardUserDefaults] objectForKey:EXPRESSION_KEY];
	self.expression = [CalculatorBrain expressionForPropertyList:plist];
	
	self.graphView = [[GraphView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.view = graphView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	/* Sign up as the delegate for our graph view */
	self.graphView.delegate = self;
	
	/* Set up gesture recognizers for the graph view */
	UIGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]
		initWithTarget:self.graphView
				action:@selector(pinch:)];
	
	UIGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] 
		initWithTarget:self.graphView
				action:@selector(pan:)];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
		initWithTarget:self.graphView
				action:@selector(tap:)];
	
	tap.numberOfTapsRequired = 2;
	
	[self.graphView addGestureRecognizer:pinch];
	[self.graphView addGestureRecognizer:pan];
	[self.graphView addGestureRecognizer:tap];
	[pinch release];
	[pan release];
	[tap release];
}

- (void)viewDidUnload 
{
	/* Release outlets */
	self.graphView = nil;
    [super viewDidUnload];
}

- (void)setExpression:(id)anExpression
{
	expression = anExpression;
	[expression retain];
	
	id plist = [CalculatorBrain propertyListForExpression:anExpression];
	[[NSUserDefaults standardUserDefaults] setObject:plist forKey:EXPRESSION_KEY];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self.graphView setNeedsDisplay];
}


- (IBAction)zoomInPressed:(UIButton *)sender 
{
	/* Set the new scale, then redraw the view */
	self.graphView.scale *= 2.0;
}

- (IBAction)zoomOutPressed:(UIButton *)sender 
{
	/* Set the new scale, then redraw the view */
	self.graphView.scale /= 2.0;
}

- (double)outputForGraphView:(GraphView *)requestor withInput:(double)input 
{
	/* Set up the variable mapping for x.  This will be autoreleased */
	NSMutableDictionary *variables = [NSMutableDictionary dictionary];
	[variables setObject:[NSNumber numberWithDouble:input] forKey:@"x"];
	
	/* Now evaluate the expression using the helper method */
	return [CalculatorBrain evaluateExpression:self.expression 
						   usingVariableValues:variables];
}

- (void)splitViewController:(UISplitViewController *)svc
	 willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)button
{
	/* Remove the bar button item from navigation item */
	self.navigationItem.leftBarButtonItem = nil;
	
}

- (void)splitViewController:(UISplitViewController *)svc
	 willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
	/* Set the bar button item for the popover */
	barButtonItem.title = viewController.title;
	self.navigationItem.leftBarButtonItem = barButtonItem;
	
}

- (void)dealloc
{
	[expression release];
	[graphView release];
    [super dealloc];
}


@end
