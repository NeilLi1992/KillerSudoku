//
//  AppDelegate.m
//  KillerSudoku
//
//  Created by 李泳 on 14-10-14.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//

#import "AppDelegate.h"
#import "GameBoard.h"
#import "UnionFind.h"

@interface AppDelegate ()
// Declare test methods
+ (void)testGameBoard;
+ (void)testUnionFind;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AppDelegate testGameBoard];
    
    NSMutableArray* keys = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:3],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5], nil];
    NSNumber* sum = [NSNumber numberWithInt:10];
    NSDictionary* testDict = [NSDictionary dictionaryWithObject:sum forKey:keys];
    NSLog(@"%@", testDict);
    
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

#pragma mark Testing methods
+ (void)testGameBoard {
    int GAME1[9][9] = {
        {5,3,4,6,7,8,9,1,2},
        {6,7,2,1,9,5,3,4,8},
        {1,9,8,3,4,2,5,6,7},
        {8,5,9,7,6,1,4,2,3},
        {4,2,6,8,5,3,7,9,1},
        {7,1,3,9,2,4,8,5,6},
        {9,6,1,5,3,7,2,8,4},
        {2,8,7,4,1,9,6,3,5},
        {3,4,5,2,8,6,1,7,9}
    };
    
    int GAME2[9][9] = {
        {5,3,0,0,7,0,0,0,0},
        {6,0,0,1,9,5,0,0,0},
        {0,9,8,0,0,0,0,6,0},
        {8,0,0,0,6,0,0,0,3},
        {4,0,0,8,0,3,0,0,1},
        {7,0,0,0,2,0,0,0,6},
        {0,6,0,0,0,0,2,8,0},
        {0,0,0,4,1,9,0,0,5},
        {0,0,0,0,8,0,0,7,9}
    };
    
    GameBoard* gb = [[GameBoard alloc] initWithIntegerArray:GAME2];
    NSLog(@"%@", [gb cagesArrayDescription]);
}

+ (void)testUnionFind {
    UnionFind* uf = [[UnionFind alloc] initWithCapacity:81];
    [uf connect:5 with:8];
    [uf connect:12 with:8];
    [uf connect:12 with:5];
    
    
//    NSLog(@"%ld", [uf sizeOfComponent:12]);
//    NSLog(@"%ld", [uf count]);
    


    
//    NSLog(@"%d", [uf isConnected:5 with:8]);
//    NSLog(@"%ld", [uf count]);
//    NSLog(@"%ld", [uf find:5]);
//    NSLog(@"%ld", [uf find:8]);
//    
//    NSLog(@"%ld", [uf sizeOfComponent:6]);
//    NSLog(@"%ld", [uf sizeOfComponent:5]);
//    NSLog(@"%ld", [uf sizeOfComponent:8]);
}

@end
