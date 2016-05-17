//
//  AppDelegate.m
//  CSVideo
//
//  Created by qianfeng on 15/10/14.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import "AppDelegate.h"
#import "CSChannelViewController.h"
#import "GameViewController.h"
#import "LiveViewController.h"
#import "MyViewController.h"
#import "LimitDefine.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    CSChannelViewController *channelView = [CSChannelViewController new];
    UINavigationController *channelNav = [[UINavigationController alloc] initWithRootViewController:channelView];
    channelNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"推荐" image:[UIImage imageNamed:@"fire_nomal"] selectedImage:[[UIImage imageNamed:@"fire_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    GameViewController *gameView = [GameViewController new];
    UINavigationController *gameNav = [[UINavigationController alloc] initWithRootViewController:gameView];
    gameNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"栏目" image:[UIImage imageNamed:@"stats-bars_nomal"] selectedImage:[[UIImage imageNamed:@"stats-bars_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    LiveViewController *liveView = [LiveViewController new];
    UINavigationController *liveNav = [[UINavigationController alloc] initWithRootViewController:liveView];
    liveNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"直播" image:[UIImage imageNamed:@"tv_nomal"] selectedImage:[[UIImage imageNamed:@"tv_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    MyViewController *myView = [MyViewController new];
    UINavigationController *myNav = [[UINavigationController alloc] initWithRootViewController:myView];
    myNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"个人中心" image:[UIImage imageNamed:@"user-tie_nomal"] selectedImage:[[UIImage imageNamed:@"user-tie_select"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[channelNav,gameNav,liveNav,myNav];
    
    UIColor *titleHighlightedColor = [UIColor colorWithRed:224/255.0 green:89/255.0 blue:43/255.0 alpha:1];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:titleHighlightedColor,UITextAttributeTextColor,nil] forState:UIControlStateSelected];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:224/255.0 green:89/255.0 blue:43/255.0 alpha:1]];
    
    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
