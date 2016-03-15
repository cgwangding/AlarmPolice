

#import "AppDelegate.h"
#import <BaiduMapAPI_Base/BMKMapManager.h>
#import "GuideViewController.h"
#import "CustomTabBarController.h"
#import "CommenInfoViewController.h"
#import "AlarmViewController.h"
#import "AlarmStateManager.h"


@interface AppDelegate ()
{
    BMKMapManager *_mapManger;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //com.alarm.didiAlarm
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    if (default_get_Bool(APNotFirstLaunchKey)) {
        //不是第一次启动
        if ([APUserData sharedUserData].isOnline) {
            
            BaseNavigationController *nav = [[BaseNavigationController alloc]initWithRootViewController:[CustomTabBarController new]];
            self.window.rootViewController = nav;
            
        }else{
            BaseNavigationController *loginNav = MainStoryBoard(@"loginNavIdentifier");
            self.window.rootViewController = loginNav;
        }
    }else{
        //是第一次启动
        GuideViewController *guideVC = [GuideViewController new];
        BaseNavigationController *nav =  [[BaseNavigationController alloc]initWithRootViewController:guideVC];
        self.window.rootViewController = nav;
    }
    
    [self.window makeKeyAndVisible];
    
    [self appearance];
    _mapManger = [[BMKMapManager alloc]init];
    if (_sharedImageArr == nil) {
        _sharedImageArr = [NSMutableArray array];
    }
    
    //已经是正式的地址
    /**
     *  netho_kf@126.com    /     nethodidi
     */
    BOOL ret = [_mapManger start:@"8nf5yzTKK4drp5r6zscPQttS" generalDelegate:nil];
    if (!ret) {
        DDLog(@"百度地图启动失败");
    }
    
    // Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
    
    // Required
    [APService setupWithOption:launchOptions];
    [APService setDebugMode];
    [APService resetBadge];
   
    
    
    application.applicationIconBadgeNumber = 0;
    
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    
    
    return YES;
}

- (void)appearance
{
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [BMKMapView willBackGround];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[AlarmStateManager manager]getAlarmState];
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您有新的报警反馈消息，请查看。" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [BMKMapView didForeGround];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required
    [APService handleRemoteNotification:userInfo];
    //收到通知，处理逻辑
    if (userInfo[@"extra_data"] != nil) {
        [[NSNotificationCenter defaultCenter]postNotificationName:AlarmHadChageStateNotification object:userInfo[@"extra_data"]];
    }
}

//
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // IOS 7 Support Required
    [APService handleRemoteNotification:userInfo];
    //收到通知，处理逻辑
    if (userInfo[@"extra_data"] != nil) {
        [[NSNotificationCenter defaultCenter]postNotificationName:AlarmHadChageStateNotification object:userInfo[@"extra_data"]];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

@end