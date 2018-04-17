//
//  UserData.swift
//  sidebar test
//
//  Created by alden lamp on 11/23/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import Foundation
import UIKit

class User: Hashable{
    
    var hashValue: Int {
        return userEmail.hashValue
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    static func ==(lhs: User, rhs: String) -> Bool{
        return lhs.userStringID == rhs || lhs.userEmail == rhs
    }
    
    
    var userType: userType
    var userName: String
    private var userIDHash: Int{
        willSet{
            User.allUserIds.append(newValue)
        }
    }
    var userEmail: String
    var userImage: UIImage
    var userStringID: String?
    
    private static var allUserIds = [Int]()
    
    deinit {
        User.allUserIds.remove(at: User.allUserIds.index(of: self.userIDHash)!)
    }
    
    init(type: userType, name: String, email: String){
        self.userType = type
        self.userName = name
        self.userEmail = email
        self.userImage = #imageLiteral(resourceName: "BlankUser")
        self.userIDHash = email.hashValue
    }
    
    init(email: String?, type: userType = .student, name: String = "", image: UIImage = #imageLiteral(resourceName: "BlankUser"), stringID: String? = nil){
        self.userEmail = "email"
        if let email = email{
            self.userEmail = email
        }else{
            while(true){
                let id = arc4random_uniform(UInt32.max).hashValue
                if !User.allUserIds.contains(id) {
                    self.userEmail = "\(id)"
                    break
                }
            }
        }
        self.userIDHash = userEmail.hashValue
        self.userType = type
        self.userName = name
        self.userImage = image
        self.userStringID = stringID;
//        self.isChosen = false
    }
}
