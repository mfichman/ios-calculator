//
//  GraphView.h
//  Calculator
//
//  Created by Matthew Fichman on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDelegate

/* Should return the output for the graph view */
- (double)outputForGraphView:(GraphView *)requestor 
				   withInput:(double)input;
@end

@interface GraphView : UIView {
	id <GraphViewDelegate> delegate;
	double scale;
	CGPoint origin;
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture;
- (void)pan:(UIPanGestureRecognizer *)gesture;
- (void)tap:(UITapGestureRecognizer *)tap;

@property (assign) id <GraphViewDelegate> delegate;
@property double scale;
@property CGPoint origin;

@end