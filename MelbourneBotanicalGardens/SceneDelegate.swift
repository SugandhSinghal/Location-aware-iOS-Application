//
//  SceneDelegate.swift
//  MelbourneBotanicalGardens
//
//  Created by Sugandh Singhal on 6/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    let locationManager:CLLocationManager = CLLocationManager()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // For adding Geofencing
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        // Override point for customization after application launch.
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        UNUserNotificationCenter.current()
            .requestAuthorization(options: options) { success, error in
                if let error = error {
                    print("Error: \(error)")
                }
        }
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // Added the code for split screen
        let splitViewController = window?.rootViewController as! UISplitViewController
        splitViewController.preferredDisplayMode = .allVisible
        let navigationController = splitViewController.viewControllers.first as!
        UINavigationController
        let exhibitionTableViewController = navigationController.viewControllers.first as!
        ExhibitionTableViewController
        let homeScreenViewController = splitViewController.viewControllers.last as! HomeScreenViewController
        
        exhibitionTableViewController.homeScreenViewController = homeScreenViewController}
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    //Reference: https://www.raywenderlich.com/5470-geofencing-with-core-location-getting-started
    // Adding the code for notification
    func handleEvent(for region: CLRegion!, type: String) {
        // Show an alert if application is active
        if UIApplication.shared.applicationState == .active {
            guard (region?.identifier) != nil else { return }
            let alert = UIAlertController(title: "Notification", message: "\(type)) ", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OKAY", style: .default, handler: nil))
            window?.rootViewController?.show(alert, sender: self)
        } else {
            // Otherwise present a local notification
            guard let body =  region?.identifier else { return }
            let notificationContent = UNMutableNotificationContent()
            notificationContent.body = body
            notificationContent.sound = .default
            notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "location_change",
                                                content: notificationContent,
                                                trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error: \(error)")
                }
            }
        }
    }
    
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    // Code when user enter the location and when user exit the location.
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered: \(region.identifier)")
        if region is CLCircularRegion{
            handleEvent(for: region, type: "Entered: \(region.identifier)")
        }}
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited: \(region.identifier)")
        if region is CLCircularRegion{
            handleEvent(for: region, type: "Exited: \(region.identifier)")}
    }
}

