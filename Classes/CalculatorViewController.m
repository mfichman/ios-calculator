//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Matthew Fichman on 9/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"

@interface CalculatorViewController ()
@property (retain) IBOutlet UILabel *display;
@end

@implementation CalculatorViewController
@synthesize display;

#define POPOVER_MARGIN 20
#define EXPRESSION_KEY @"CalculatorviewControllerExpression"


- (id)init
{
	if ((self = [super init])) {
		/* Load the previous expression for the user into the model */
		id plist = [[NSUserDefaults standardUserDefaults] objectForKey:EXPRESSION_KEY];
		brain = [[CalculatorBrain alloc] init];
		brain.expression =  [CalculatorBrain expressionForPropertyList:plist];
	}
	return self;
}
- (GraphViewController *)graphViewController
{
	if (!graphViewController) {
		graphViewController = [[GraphViewController alloc] init];
	}
	return graphViewController;
}

- (void)saveDefaults
{
	/* Save the current expression for the user */
	id plist = [CalculatorBrain propertyListForExpression:brain.expression];
	[[NSUserDefaults standardUserDefaults] setObject:plist forKey:EXPRESSION_KEY];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)releaseOutlets
{
	self.display = nil;
}

- (void)viewDidLoad
{
	self.title = @"Calculator";
	
	/* Initialize the display for the calculator */
	if ([CalculatorBrain variablesInExpression:brain.expression]) {
		NSString *description = [CalculatorBrain descriptionOfExpression:brain.expression];
		if (description) {
			self.display.text = description; 	
		}
	} else {
		self.display.text = [NSString stringWithFormat:@"%g", brain.operand];
	}
	
	/* Set up error dialog for divide by zero */
	errorDialog = [[UIAlertView alloc] initWithTitle:@"Error" 
											 message:nil
											delegate:nil
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
}

- (void)viewDidUnload
{
	[self releaseOutlets];
}

- (IBAction)decimalPointPressed:(UIButton *)sender
{
	NSRange range = [display.text rangeOfString:@"."];
	
	/* 
	 * If the user was typing a number that doesn't include '.', then add a '.' 
	 * If the user was not typing, set to '0.' to avoid errors if an operation
	 * is pressed afterwards.
	 */
	if (userIsInTheMiddleOfTypingANumber) {
		if (range.location == NSNotFound) {
			display.text = [display.text stringByAppendingString:@"."];
		}
	} else {
		display.text = @"0.";
		userIsInTheMiddleOfTypingANumber = YES;
	}
}

- (IBAction)digitPressed:(UIButton *)sender 
{
	NSString *digit = sender.titleLabel.text;
	
	if (userIsInTheMiddleOfTypingANumber) {
		display.text = [display.text stringByAppendingString:digit];
	} else {
		display.text = digit;
		userIsInTheMiddleOfTypingANumber = YES;
	}
}

- (IBAction)piPressed:(UIButton *)sender
{
	/* Simply enter digits of PI as if the user had typed them in */
	userIsInTheMiddleOfTypingANumber = YES;
	display.text = [NSString stringWithFormat:@"%g", M_PI];
}


- (IBAction)operationPressed:(UIButton *)sender
{
	/* If the user was typing, save current text as the operand */
	if (userIsInTheMiddleOfTypingANumber) {
		brain.operand = display.text.doubleValue;
		userIsInTheMiddleOfTypingANumber = NO;
	}
	NSString *operation = sender.titleLabel.text;
	double result = [brain performOperation:operation];
	
	/* 
	 * If the expression has a variable, ignore the result and 
	 * display the expression instead. 
	 */
	if ([CalculatorBrain variablesInExpression:brain.expression]) {
		display.text = [CalculatorBrain descriptionOfExpression:brain.expression];
	} else {
		display.text = [NSString stringWithFormat:@"%g", result];
	}
	
	/* If the error is non-nil then show an error dialog */
	NSString *error = brain.error;
	if (error) {
		errorDialog.message = error;
		[errorDialog show];
	}
	
	[self saveDefaults];
}

- (IBAction)variablePressed:(UIButton *)sender
{
	/* Add a variable to the expression */
	if (userIsInTheMiddleOfTypingANumber) {
		userIsInTheMiddleOfTypingANumber = NO;
	}
	
	[brain setVariableAsOperand:sender.titleLabel.text];
	display.text = [CalculatorBrain descriptionOfExpression:brain.expression];
	
	[self saveDefaults];
}

- (IBAction)solvePressed:(UIButton *)sender
{
	/* If the user was typing, save the current text as the operand */
	if (userIsInTheMiddleOfTypingANumber) {
		brain.operand = display.text.doubleValue;
		userIsInTheMiddleOfTypingANumber = NO;
	}
	
	/* Append an '=' if the last character is not an '=' symbol */
	NSString *description = [CalculatorBrain descriptionOfExpression:brain.expression];
	if (description.length != 0 && [description characterAtIndex:description.length-2] != '=') {
		[brain performOperation:@"="];
	}
	
	display.text = [CalculatorBrain descriptionOfExpression:brain.expression];
	
	
	/* Solve the expression with test values */
	NSMutableDictionary *variables = [NSMutableDictionary dictionary];
	[variables setObject:[NSNumber numberWithInt:1] forKey:@"w"];
	[variables setObject:[NSNumber numberWithInt:2] forKey:@"x"];
	[variables setObject:[NSNumber numberWithInt:3] forKey:@"y"];
	[variables setObject:[NSNumber numberWithInt:4] forKey:@"z"];
	
	/* Now evaluate the expression using the helper method */
	double result = [CalculatorBrain evaluateExpression:brain.expression 
									usingVariableValues:variables];
	
	/* Update the display */
	display.text = [NSString stringWithFormat:@"%g", result];
	
	/* If the error is non-nil then show an error dialog */
	NSString *error = brain.error;
	if (error) {
		errorDialog.message = error;
		[errorDialog show];
	}
}

- (IBAction)graphPressed:(UIButton *)sender 
{
	/* If the user was typing, save the current text as the operand */
	if (userIsInTheMiddleOfTypingANumber) {
		brain.operand = display.text.doubleValue;
		userIsInTheMiddleOfTypingANumber = NO;
	}
	
	if ([CalculatorBrain variablesInExpression:brain.expression]) {
	
		/* Append an '=' if the last character is not an '=' symbol */
		NSString *description = [CalculatorBrain descriptionOfExpression:brain.expression];
		if (description.length != 0 && [description characterAtIndex:description.length-2] != '=') {
			[brain performOperation:@"="];
		}
	
		display.text = [CalculatorBrain descriptionOfExpression:brain.expression];
	}
	
	self.graphViewController.expression = brain.expression;
	self.graphViewController.title = @"Graph";
	
	/* Only push the graph view if it's not on screen */
	if (!self.graphViewController.view.window) {
		[self.navigationController pushViewController:self.graphViewController animated:YES];
	}
	
	[self saveDefaults];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	/* 
	 * Only auto-rotate if the graph view is also visible (like on the iPad) 
	 * Otherwise, only auto-rotate to portrait orientations.
	 */
	if (self.graphViewController.view.window) {
		return YES;
	} else if (UIInterfaceOrientationPortrait == interfaceOrientation ||
			   UIInterfaceOrientationPortraitUpsideDown == interfaceOrientation) {
		
		return YES;
	} else {
		return NO;
	}
}

- (CGSize)contentSizeForViewInPopover
{
	/* Find the union of all subview sizes, then add some padding to make it look nice */
	CGRect rect = CGRectZero;
	for (UIView *aView in self.view.subviews) {
		rect = CGRectUnion(rect, aView.frame);
	}
	CGSize size;
	size.width = POPOVER_MARGIN + CGRectGetWidth(rect);
	size.height = POPOVER_MARGIN + CGRectGetHeight(rect);
	return size;
}

- (void)dealloc
{
	[brain release];
	[errorDialog release];
	[graphViewController release];
	[self releaseOutlets];
	[super dealloc];
}

@end
