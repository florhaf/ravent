//
//  AppDelegate.m
//  ravent
//
//  Created by florian haftman on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "JMC.h"
#import "Store.h"
#import "controllers_events_List_p2p.h"
#import "models_User.h"
#import "GPSManager.h"
#import "GANTracker.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize appController = _appController;

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

@synthesize facebook = _facebook;
@synthesize userPermissions = _userPermissions;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[GPSManager instance] startGps];
    
    [Store instance].managedObjectContext = self.managedObjectContext;
    
    
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-33038234-1"
                                           dispatchPeriod:1
                                                 delegate:nil];

    
    [[JMC sharedInstance] configureJiraConnect:@"https://ravent.atlassian.net/"
                                    projectKey:@"RAV"
                                        apiKey:@"eb74bda1-a5a5-4ac8-80ea-b0ce502c926a"];
    
    
    // Initialize Facebook
    _facebook = [[Facebook alloc] initWithAppId:@"299292173427947" andDelegate:[controllers_Login instance]];
    
    // Check and retrieve authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    // Initialize user permissions
    _userPermissions = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
    
    self.appController = [[controllers_App alloc] init];
    self.window.rootViewController = self.appController;
    
    [self.window makeKeyAndVisible];
    
    
    [self.window setBackgroundColor:[UIColor blackColor]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    [[models_User crtUser] saveToNSUserDefaults];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    [[JMC sharedInstance] ping];
    
    if ([controllers_events_List_p2p isIntanciated]) {
        
     
        NSDate *lastLoadTime = [[controllers_events_List_p2p instance] lastLoadTime];
        NSDateComponents *thirtyMins = [[NSDateComponents alloc] init];
        [thirtyMins setMinute:30];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDate *lastLoadPlus30 = [cal dateByAddingComponents:thirtyMins toDate:lastLoadTime options:0];
        NSDate *now = [NSDate date];
        
        if ([lastLoadPlus30 compare:now] == NSOrderedAscending) {
            
            [[controllers_events_List_p2p instance] loadDataWithSpinner];
        }
    }
        
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [[self facebook] extendAccessTokenIfNeeded];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.facebook handleOpenURL:url];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    [[models_User crtUser] saveToNSUserDefaults];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ravent" withExtension:@"momd"];
    NSLog(@"%@", modelURL);
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSLog(@"%@", [__managedObjectModel entities]);
    
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ravent.sqlite"];
    NSLog(@"%@", storeURL);
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
