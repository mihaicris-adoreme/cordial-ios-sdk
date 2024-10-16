//
//  AppDelegate.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 3/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import IQKeyboardManagerSwift
import CordialSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        
        let (accountKey, channelKey, eventsStreamURL, messageHubURL) = App.getCordialSDKInitParams()
        CordialApiConfiguration.shared.initialize(accountKey: accountKey, channelKey: channelKey, eventsStreamURL: eventsStreamURL, messageHubURL: messageHubURL)
        
        CordialApiConfiguration.shared.initializeLocationManager(desiredAccuracy: kCLLocationAccuracyBest, distanceFilter: kCLDistanceFilterNone)
        CordialApiConfiguration.shared.qtyCachedEventQueue = 100
        CordialApiConfiguration.shared.eventsBulkSize = 3
        CordialApiConfiguration.shared.eventsBulkUploadInterval = 15
        CordialApiConfiguration.shared.loggerManager.setLoggerLevel(.all)
        CordialApiConfiguration.shared.loggerManager.setLoggers(loggers: [FileLogger.shared])
        CordialApiConfiguration.shared.inAppMessageDelayMode.disallowedControllers([ProductViewController.self, CartViewController.self])
        CordialApiConfiguration.shared.pushNotificationDelegate = PushNotificationHandler()
        CordialApiConfiguration.shared.cordialDeepLinksDelegate = CordialDeepLinksHandler()
        CordialApiConfiguration.shared.inAppMessageInputsDelegate = InAppMessageInputsHandler()
        CordialApiConfiguration.shared.inboxMessageDelegate = InboxMessageHandler()
        
        CordialApiConfiguration.shared.inAppMessages.displayDelayInSeconds = 1.5

        CordialApiConfiguration.shared.pushNotificationCategoriesConfiguration = .SDK
        CordialApiConfiguration.shared.pushNotificationCategoriesDelegate = NotificationSettingsHandler()
        
        CordialApiConfiguration.shared.setNotificationCategories([
            PushNotificationCategory(key: "discounts", name: "Discounts", initState: true),
            PushNotificationCategory(key: "new-arrivals", name: "New Arrivals", initState: false),
            PushNotificationCategory(key: "top-products", name: "Top Products", initState: true)
        ])
        CordialApiConfiguration.shared.vanityDomains = ["e.a45.clients.cordialdev.com", "s.cordial.com", "s.a1105.clients.cordialdev.com", "s.a1003.clients.cordialdev.com", "events-handling-svc.stg.cordialdev.com", "events-handling-svc.cordial-core.cp-8305-inapp-link-tracing.cordialdev.com", "e.a1003.clients.cordialdev.com"]
                
        AppNotificationManager.shared.setupCordialSDKObservers()
        AppNotificationManager.shared.setupCordialDemoObservers()
        
        guard #available(iOS 13.0, *) else {
            if App.isUserLogIn() {
                let catalogNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CatalogNavigationController") as! UINavigationController
                self.window?.rootViewController = catalogNavigationController
            }
            
            return true
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CordialDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

