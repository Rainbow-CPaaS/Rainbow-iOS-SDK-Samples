//
//  AppDelegate.swift
//  Hello World
//
//  Created by Vladimir Vyskocil on 10/10/2023.
//

import UIKit
import Rainbow

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // Rainbow server
    let rainbowServer = "sandbox.openrainbow.com"
    // Fill with your application id
    let appId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    // Fill with your secret key
    let appSecret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    // User login email
    let loginEmail = "user@host"
    // User password
    let password = "xxxxxxxxxxxx"
    
    override init() {
        RainbowUserDefaults.setSuiteName("group.com.alcatellucent.otcl.Hello-World")
        
        LogsRecorder.sharedInstance().startRecord()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let sdkVersion = ServicesManager.version()
        NSLog("Rainbow SDK version: \(sdkVersion)")
        ServicesManager.sharedInstance().setAppID(appId, secretKey: appSecret)
                
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        LogsRecorder.sharedInstance().stopRecord()
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

