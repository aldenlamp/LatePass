//
//  AppDelegate.swift
//  sidebar test
//
//  Created by alden lamp on 8/21/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import UIKit
import Firebase
import Google
import GoogleSignIn
import GoogleAPIClientForREST

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate{

    var window: UIWindow?
    private let scopes = [kGTLRAuthScopeClassroomCoursesReadonly, kGTLRAuthScopeClassroomRostersReadonly, kGTLRAuthScopeClassroomProfileEmails]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let initialViewController = ContainerViewController()
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        FIRApp.configure()
        
        
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signInSilently()
        

        FIRAnalyticsConfiguration.sharedInstance().setAnalyticsCollectionEnabled(false)
        
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        
//        setUpGoogle()
        
//        FIRAuth.auth()?.currentUser?.getTokenWithCompletion({ (lol, errorr) in
//            print(lol)
//        })
        
        
//        GIDSignIn.sharedInstance().signOut()
//        do{
//            try FIRAuth.auth()?.signOut()
//        }catch{
//            
//        }
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        return GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: annotation)
    }
    

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }

    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.

//
//    private let service = GTLRClassroomService()

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
    }


    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if error != nil {
//            showAlert(title: "Authentication Error", message: (error?.localizedDescription)!)
//            self.service.authorizer = nil
            return
        }

        guard let authentication = user.authentication else { return }

        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if error != nil { return }
            NotificationCenter.default.post(Notification(name: logInCompleteNotification))
        }
        //        self.signInButton.isHidden = true
        //        self.output.isHidden = false
//        self.service.authorizer = user.authentication.fetcherAuthorizer()
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
    }


}

