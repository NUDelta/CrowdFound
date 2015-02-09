//
//  AppDelegate.m
//  CrowdFound
//
//  Created by Yongsung on 11/10/14.
//  Copyright (c) 2014 YK. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h> 
#import "MyUser.h"
#import "HelperDetailViewController.h"
#import "HelperMapViewController.h"
NSString *localReceived = @"localReceived";
BOOL gotNotified;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [MyUser registerSubclass];
    [Parse setApplicationId:@"ApbUdbGqhwedB8ypJDu6Gz8cYdqa8H3Gt5JV5Kih"
                  clientKey:@"NAbLVfq8CCKsCFAbVB18LqB8k3dKSh82RraBdQ7Y"];
    
    if([PFUser currentUser]) {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    } else {
        UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SignInViewController"];
        UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
        self.window.rootViewController = navigation;
    }
    
//    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
//        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
//    }
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }

    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
//    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UINavigationController *vc = [[(UITabBarController *)self.window.rootViewController viewControllers] objectAtIndex:0];
//    HelperDetailViewController *hdvc = (HelperDetailViewController *)[mainstoryboard instantiateViewControllerWithIdentifier:@"HelperDetailViewController"];
//    HelperMapViewController *hmvc = (HelperMapViewController *)[mainstoryboard instantiateViewControllerWithIdentifier:@"HelperMapViewController"];
//    [vc setViewControllers:@[hmvc, hdvc]];
//    [[NSNotificationCenter defaultCenter] postNotificationName:localReceived object:self];
    if (application.applicationState == UIApplicationStateInactive) {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];

        //    [application presentLocalNotificationNow:notification];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        HelperMapViewController *hmvc = (HelperMapViewController *)[sb instantiateViewControllerWithIdentifier:@"HelperMapViewController"];
        HelperDetailViewController *hdvc = (HelperDetailViewController *)[sb instantiateViewControllerWithIdentifier:@"HelperDetailViewController"];
        for(NSString *key in notification.userInfo){
            NSLog(@"notification userInfo: %@", [notification.userInfo objectForKey:key]);
            hdvc.objectId = [notification.userInfo objectForKey:key];
        }
        UINavigationController *nav = (UINavigationController *)[[(UITabBarController *)self.window.rootViewController viewControllers] objectAtIndex:0];
        nav.viewControllers = [NSArray arrayWithObjects:hmvc,hdvc, nil];
        [nav popToViewController:hdvc animated:YES];
    }
    application.applicationIconBadgeNumber = notification.applicationIconBadgeNumber - 1;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
