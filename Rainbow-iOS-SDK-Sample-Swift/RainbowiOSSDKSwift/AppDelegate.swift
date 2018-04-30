/*
 * Rainbow SDK sample
 *
 * Copyright (c) 2018, ALE International
 * All rights reserved.
 *
 * ALE International Proprietary Information
 *
 * Contains proprietary/trade secret information which is the property of
 * ALE International and must not be made available to, or copied or used by
 * anyone outside ALE International without its written authorization
 *
 * Not to be disclosed or used except in accordance with applicable agreements.
 */

import UIKit
import Rainbow

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let appID = ""
    let secretKey = ""
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        ServicesManager.sharedInstance().setAppID(appID, secretKey: secretKey)
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        ServicesManager.sharedInstance().loginManager.disconnect()
        ServicesManager.sharedInstance().loginManager.resetAllCredentials()
    }


}

