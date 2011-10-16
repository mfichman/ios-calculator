//
//  GraphViewController.h
//  Calculator
//
//  Created by Matthew Fichman on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GraphView.h"


@interface GraphViewController : UIViewController <GraphViewDelegate, UISplitViewControllerDelegate> {
	IBOutlet GraphView *graphView;
	id expression;
}

@property (retain) id expression;

- (IBAction)zoomInPressed:(UIButton *)sender;
- (IBAction)zoomOutPressed:(UIButton *)sender;
- (double)outputForGraphView:(GraphView *)requestor withInput:(double)input;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

- (void)splitViewController:(UISplitViewController *)svc
	 willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)button;

- (void)splitViewController:(UISplitViewController *)svc
	 willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc;

@end
