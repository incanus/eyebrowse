//
//  EBAppDelegate.m
//  eyebrowse
//
//  Created by Justin R. Miller on 11/4/13.
//  Copyright (c) 2013 Code Sorcery Workshop. All rights reserved.
//

#import "EBAppDelegate.h"

#import "EBViewController.h"

@implementation EBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[EBViewController new]];
    [self.window makeKeyAndVisible];

    return YES;
}
							
@end
