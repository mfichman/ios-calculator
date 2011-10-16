//
//  CalculatorAppDelegate.h
//  Calculator
//
//  Created by Matthew Fichman on 9/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalculatorViewController;

@interface CalculatorAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

