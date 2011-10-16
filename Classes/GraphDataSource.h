//
//  GraphDataSource.h
//  Calculator
//
//  Created by Matthew Fichman on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol GraphViewDelegate

/* 
 * Returns the output of the function for the given input. 
 * In other words, given an X, this function returns the 
 * corresponding Y.
 */
- (double)functionOutputForInput:(double)input;

@end
