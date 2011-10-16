//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Matthew Fichman on 9/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalculatorViewController : UIViewController {
	IBOutlet UILabel *display;
	UIAlertView *errorDialog;
	GraphViewController *graphViewController;
	CalculatorBrain *brain;
	BOOL userIsInTheMiddleOfTypingANumber;
}

@property (readonly) GraphViewController *graphViewController;
- (IBAction)decimalPointPressed:(UIButton *)sender;
- (IBAction)piPressed:(UIButton *)sender;
- (IBAction)digitPressed:(UIButton *)sender;
- (IBAction)operationPressed:(UIButton *)sender;
- (IBAction)variablePressed:(UIButton *)sender;
- (IBAction)solvePressed:(UIButton *)sender;
- (IBAction)graphPressed:(UIButton *)sender;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (CGSize)contentSizeForViewInPopover;


@end

