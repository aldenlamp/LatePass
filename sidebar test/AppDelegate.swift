//
//  AppDelegate.swift
//  sidebar test
//
//  Created by alden lamp on 8/21/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import Google
import GoogleSignIn
import GoogleAPIClientForREST

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate{
    
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
        
        //Notifications
//        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
//        let notificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)

    
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FIRMessaging.messaging().remoteMessageDelegate = self
//        let token = FIRMessaging.messaging().fcmToken
//        print("FCM token: \(token ?? "")")
        
        FIRMessaging.messaging().connect { (error) in
            if (error != nil){ print (error!.localizedDescription)}
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshToekn(notification:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        
//        FIRMessaging.messaging().sendMessage(["message": "testing"], to: "eJX2Ky_HUiI:APA91bHW2vYXrEO55lviWa9XiOC3XJ0xVADEpHpp-beQTd94WSxT0Jgh8fdMWYD7pahLj1pQz-rDM8udlXdiLRIpA-zfQn7kNNjyxxW0hGyMevUxUcYGqyn_jQpYYE29piJMq7DNdXTu", withMessageID: "0", timeToLive: 0)
        
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
            
            guard let email = user?.email else {
                NotificationCenter.default.post(Notification(name: logInFailedNotif))
                return
            }
            
            var worked = false
            var didCall = false
            var count = 0
            
            func didFinish(worked: Bool = false){
                if worked{
                    if didCall{
                        return
                    }
                    NotificationCenter.default.post(Notification(name: logInCompleteNotification))
                    didCall = true
                    return
                }
                
                count += 1
                if count == 4{
                    if !didCall{
                        NotificationCenter.default.post(Notification(name: logInFailedNotif))
                    }
                }
            }
            
            let ref = FIRDatabase.database().reference()
            ref.child("potentialStudents").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    let value = snapshot.value! as! [String: String]
                    for (key, _) in value{
                        if key.replacingOccurrences(of: "%2E", with: ".") == email{
                            didFinish(worked: true)
                        }
                    }
                    didFinish()
                }else{
                    didFinish()
                }
            })
            
            ref.child("potentialTeachers").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    let value = snapshot.value! as! [String: String]
                    for (key, _) in value{
                        if key.replacingOccurrences(of: "%2E", with: ".") == email{
                            didFinish(worked: true)
                        }
                    }
                    didFinish()
                }else{
                    didFinish()
                }
            })
            
            ref.child("students").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    let value = snapshot.value! as! [String: Bool]
                    var count = 0
                    for (key, _) in value{
                        ref.child("users").child(key).child("email").observe(.value, with: { (snapshot) in
                            let userEmail = snapshot.value! as! String
                            if userEmail.replacingOccurrences(of: "%2E", with: ".") == email{
                                didFinish(worked: true)
                            }
                            count += 1
                            if count == value.count{
                                didFinish()
                            }
                        })
                    }
                }else{
                    didFinish()
                }
            })
            
            ref.child("teachers").observe(.value, with: { (snapshot) in
                if snapshot.exists(){
                    let value = snapshot.value! as! [String: Bool]
                    var count = 0
                    for (key, _) in value{
                        ref.child("users").child(key).child("email").observe(.value, with: { (snapshot) in
                            let userEmail = snapshot.value! as! String
                            if userEmail.replacingOccurrences(of: "%2E", with: ".") == email{
                                didFinish(worked: true)
                            }
                            count += 1
                            if count == value.count{
                                didFinish()
                            }
                        })
                    }
                }else{
                    didFinish()
                }
            })
        }
        
        //        self.signInButton.isHidden = true
        //        self.output.isHidden = false
//        self.service.authorizer = user.authentication.fetcherAuthorizer()
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    
    
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {

    }
    
    @objc func refreshToekn(notification: NSNotification){
        let refreshToken = FIRInstanceID.instanceID().token()!
        print("\n\n***TOKEN: \(refreshToken)\n\n")
        
    }

//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//
//
//    }



}

