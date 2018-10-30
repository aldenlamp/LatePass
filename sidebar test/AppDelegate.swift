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
import FirebaseFunctions
import Google
import GoogleSignIn
import GoogleAPIClientForREST

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate, MessagingDelegate{
    
    var window: UIWindow?
    private let scopes = [kGTLRAuthScopeClassroomCoursesReadonly, kGTLRAuthScopeClassroomRostersReadonly, kGTLRAuthScopeClassroomProfileEmails]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.©
        
        FirebaseApp.configure()
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
//        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let initialViewController = ContainerViewController()
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        

        
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().hostedDomain = "millburn.org"
        GIDSignIn.sharedInstance().signInSilently()
        

        AnalyticsConfiguration.shared().setAnalyticsCollectionEnabled(false)
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
        
        Messaging.messaging().delegate = self
        //        let token = FIRMessaging.messaging().fcmToken
        //        print("FCM token: \(token ?? "")")
        
        
        
        Messaging.messaging().connect { (error) in
            if (error != nil){ print (error!.localizedDescription)}
        }
        
        
        
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshToekn(notification:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        
//        FIRMessaging.messaging().sendMessage(["message": "testing"], to: "eJX2Ky_HUiI:APA91bHW2vYXrEO55lviWa9XiOC3XJ0xVADEpHpp-beQTd94WSxT0Jgh8fdMWYD7pahLj1pQz-rDM8udlXdiLRIpA-zfQn7kNNjyxxW0hGyMevUxUcYGqyn_jQpYYE29piJMq7DNdXTu", withMessageID: "0", timeToLive: 0)
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if let refreshedToken = InstanceID.instanceID().token() {
            print("***InstanceID token: \(refreshedToken)")
//            print("AUTH: \((Auth.auth().currentUser?.uid)!)")
            let ref = Database.database().reference()
            if let id = Auth.auth().currentUser?.uid{
                ref.child("users").child(id).child("regTokens").observe(.value) { (snapshot) in
                    if snapshot.exists(){
                        let vals = snapshot.value! as! [String : Any]
                        print("VALS: \(vals)")
                        
                    }else{
                        print("ReEE")
                        var functions = Functions.functions()
                        
                        guard let id = InstanceID.instanceID().token() else{
                            return
                        }
                        
//                        var jsonArray = try? JSONSerialization.jsonObject(with: id, options: .mutableContainers)  as! [String:AnyObject]
//                        JSONSerialization.jsonObject(with: , options: .allowFragments)
                        
//                        guard let json = try? JSONSerialization.jsonObject(with: , options: .allowFragments) else{
//                            print("error FAILED")
//                            return
//                        }
                        
                        func json(from object:Any) -> String? {
                            guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
                                return nil
                            }
                            return String(data: data, encoding: String.Encoding.utf8)
                        }
                        
                        guard let ree = try? JSONSerialization.data(withJSONObject: ["token": id], options: []) else{
                            print("error REEEE")
                            return
                        }
                        print(ree)
//                        print("\(json(from:array as Any))")
//                        )
//                        let array = [ "token": id ]
//                        var tryData = try? JSONSerialization.data(withJSONObject: array, options: JSONSerialization.WritingOptions)
//                        let data = NSJSONSerialization.dataWithJSONObject(array, options: nil, error: nil)
//                        let string = NSString(data: tryData!, encoding: String.Encoding.utf8.rawValue)
//
                        
                        functions.httpsCallable("notifReg").call(["token":id]) { (result, error) in
                            if let error = error as NSError? {
                                if error.domain == FunctionsErrorDomain {

                                    let code = FIRFunctionsErrorCode(rawValue: error.code)
                                    let message = error.localizedDescription
                                    let details = error.userInfo[FunctionsErrorDetailsKey]
                                    print("code \(code)")
                                    print(message)
                                    print(details)
                                }else{
                                    print("Error: \(error)")
                                }
                                // ...
                            }
                            print("result \(result?.data)")
//                            if let text = (result?.data as? [String: Any])?["text"] as? String {
//                                self.resultField.text = text
//                            }
                        }
//
//
//                        functions.httpsCallable("regTokens").call(["token" : id]) { (result, error) in
//                            print("error \(error)")
//                            print("result \(result)")
//                        }
                    }
                }
            }
            
        }
    }
    
    
    
//
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//        print("Firebase registration token: \(fcmToken)")
//
//        let dataDict:[String: String] = ["token": fcmToken]
//        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
//        // TODO: If necessary send token to application server.
//        // Note: This callback is fired at each app startup and whenever a new token is generated.
//    }
    
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

        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil { return }
            
            guard let userID = user?.uid else{
                NotificationCenter.default.post(Notification(name: logInFailedNotif))
                return
            }
            
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
                        
                        
//                        do{
//                            try Auth.auth().signOut()
//                            GIDSignIn.sharedInstance().signOut()
//                        }catch{
//                            assert(true, "loging out failed")
//                        }
//
//                     
//                        failedObserver = NotificationCenter.default.addObserver(forName: logInFailedNotif, object: nil, queue: nil, using: { [weak self] (notif) in
//                            print("Log in failed")
//                            self?.alert(title: "Log In Failed", message: "Could not log in under this account. Make sure you are using you Millburn.org email account", buttonTitle: "Okay")
//
//                            do{
//                                try Auth.auth().signOut()
//                                GIDSignIn.sharedInstance().signOut()
//                            }catch{
//                                assert(true, "loging out failed")
//                            }
//                            
//                        })
                    
                        
                        
                        
                    }
                }
            }
            
            let ref = Database.database().reference()
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
                    for (key, _) in value{
                        if key == userID{
                            didFinish(worked: true)
                        }
                    }
                    didFinish()
                }else{
                    didFinish()
                }
            })
            
            ref.child("teachers").observe(.value, with: { (snapshot) in
                if snapshot.exists(){
                    let value = snapshot.value! as! [String: Bool]
                    for (key, _) in value{
                        if key == userID{
                            didFinish(worked: true)
                        }
                    }
                    didFinish()
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
    
    
    
//    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
//
//    }
    
//    @objc func refreshToekn(notification: NSNotification){
//        let refreshToken = FIRInstanceID.instanceID().token()!
//        print("\n\n***TOKEN: \(refreshToken)\n\n")
//
//    }

//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//
//
//    }



}

