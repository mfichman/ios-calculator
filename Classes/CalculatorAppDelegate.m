//
//  CalculatorAppDelegate.m
//  Calculator
//
//  Created by Matthew Fichman on 9/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CalculatorAppDelegate.h"
#import "CalculatorViewController.h"

@implementation CalculatorAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)iPad
{
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    /* Override point for customization after application launch.*/
	UINavigationController *mainNav = [[UINavigationController alloc] init];
	CalculatorViewController *calc = [[CalculatorViewController alloc] init];
	[mainNav pushViewController:calc animated:NO];
	
	/* If using iPad, then set up a split view controller, otherwise default to other behavior */
	if (self.iPad) {
		UISplitViewController *split = [[UISplitViewController alloc] init];
		UINavigationController *rightNav = [[UINavigationController alloc] init];
		[rightNav pushViewController:calc.graphViewController animated:NO];
		split.viewControllers = [NSArray arrayWithObjects:mainNav, rightNav, nil];
		split.delegate = calc.graphViewController;
		
		[mainNav release];
		[rightNav release];
		[window addSubview:split.view];
	} else {
		
		/* Add the view controller's view to the window and display. */
		[window addSubview:mainNav.view];
	}
	
	[calc release];
    [window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
