//
//  FirebaseRequests.swift
//  sidebar test
//
//  Created by alden lamp on 2/3/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import Foundation
import Firebase

struct FirebaseRequests{
    
    static func makeRequest(from selectedPeople: [User], toTeacher: User, reason: String, completion: @escaping (_ title: String, _ message: String, _ buttonTitle: String, _ worked: Bool) -> Void){
        //        let reasoning = self.reasoning.text == "Reason for late pass" ? "" : self.reasoning.text!
        let reasoning = reason
//
        var student = firebaseData.currentUser.userType == .student ? firebaseData.userID! : selectedPeople[0].userStringID!
//            //            self.alert(title: "No Student", message: "Please enter a user as the student", buttonTitle: "Okay")
//            completion("No Student", "Please enter a user as the student", "Okay", false)
//            return
//        }
//
        let origin = firebaseData.currentUser.userType == .student ? selectedPeople[0].userStringID! : firebaseData.userID!
//            //            self.alert(title: "No Origin", message: "Please enter a user as the origin", buttonTitle: "Okay")
//            completion("No Origin", "Please enter a user as the origin", "Okay", false)
//            return
//        }
//
        let dest = toTeacher.userStringID!
//            //            self.alert(title: "No Destination", message: "Please enter a user as the destination", buttonTitle: "Okay")
//            completion("No Destination", "Please enter a user as the destination", "Okay", false)
//            return
//        }
        
        
        
        if firebaseData.currentUser.userType != .student{
            student = "["
            for i in selectedPeople{
                student += "\"\(i.userStringID!)\","
            }
            student = student.substring(to: student.index(before: student.endIndex))
            student += "]"
            print(student)
        }
        
        FIRAuth.auth()!.currentUser!.getTokenForcingRefresh(true, completion: {(token, error) in
            if error == nil{
                
                let requestURL = "https://us-central1-late-pass-lab.cloudfunctions.net/app/request"
                var request = URLRequest(url: URL(string: requestURL)!)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-type")
                request.addValue(token!, forHTTPHeaderField: "Authorization")
                
                //TODO: - Multi Person Pass
                
                
                request.httpBody = "{\"destination\":\"\(dest)\",\"origin\":\"\(origin)\",\"student\":\(firebaseData.currentUser.userType != .student ? "" : "\"")\(student)\(firebaseData.currentUser.userType != .student ? "" : "\""),\"reason\":\"\(reasoning)\"}".data(using: String.Encoding.utf8)
                
//                request.httpBody = "{\"origin\":\"\(origin)\",\"student\":\(firebaseData.currentUser.userType != .student ? "" : "\"")\(student)\(firebaseData.currentUser.userType != .student ? "" : "\""),\"reason\":\"\(reasoning)\"}".data(using: String.Encoding.utf8)
                print(student)
                print(firebaseData.userID)
                
                print(String(data: request.httpBody!, encoding: String.Encoding.utf8)!)
                
                URLSession.shared.dataTask(with: request, completionHandler: {(data, response, _) in
                    
                    let responseMessage: String = String(data: data!, encoding: String.Encoding.utf8)!
                    print("\nData: \(responseMessage) \n\n")
                    
                    if responseMessage != ""{
//                            self?.alert(title: "Request Error: \(responseMessage)", message: "A LatePass Could not Be Created", buttonTitle: "Okay")
                        
                        
                        
                        if let httpResponse = response as? HTTPURLResponse { print("response: \(httpResponse.statusCode)\n") }
                        if let httpResponse = response as? HTTPURLResponse { print("response: \(httpResponse)\n\n") }
                        
                        completion("Request Error: \(responseMessage)", "A LatePass Could not Be Created", "Okay", false)
                    }else{
                        
                        completion("", "", "", true)
//                        firebaseData.reloadHistoryData()
                    }
                }).resume()
            }else{
                print("FIRSTERROR: \(String(describing: error))")
            }
        })
    }
    
    
    
    static func acceptPass(withStatus accepted: Bool, data: HistoryData, completion: @escaping (_ title: String, _ message: String, _ button: String, _ worked: Bool) -> Void){
        
        let rqID = data.ID
        
        FIRAuth.auth()!.currentUser!.getTokenForcingRefresh(true, completion: { (token, error) in
            if error == nil{
                
                let requestURL = "https://us-central1-late-pass-lab.cloudfunctions.net/app/approve"
                var request = URLRequest(url: URL(string: requestURL)!)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-type")
                request.addValue(token!, forHTTPHeaderField: "Authorization")
                
                request.httpBody = "{\"request\":\"\(rqID)\",\"approval\":\(accepted)}".data(using: String.Encoding.utf8)
                
                print(String(data: request.httpBody!, encoding: String.Encoding.utf8)!)
                
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, _) in
                    
                    let responseMessage: String = String(data: data!, encoding: String.Encoding.utf8)!
                    print("\nData: \(responseMessage) \n\n")
                    
                    if responseMessage != ""{
                        //                        self?.alert(title: "Request Error: \(responseMessage)", message: "A LatePass Could not Be Created", buttonTitle: "Okay")
                        
                        
                        if let httpResponse = response as? HTTPURLResponse { print("response: \(httpResponse.statusCode)\n") }
                        if let httpResponse = response as? HTTPURLResponse { print("response: \(httpResponse)\n\n") }
                        
                        completion("Request Error: \(responseMessage)", "A LatePass Could not Be confirmed", "Okay", false)
                        
                    }else{
                        //TODO: - create a notification for updating the tableView in new tableView View
                        //                        (self?.navigationController!.viewControllers[0] as! Home).historyTableView.reloadData()
                        //                        self?.dismiss(animated: true, completion: nil)
                        
                        completion("", "", "", true)
//                        firebaseData.reloadHistoryData()
                    }
                }).resume()
            }else{
                print("FIRSTERROR: \(String(describing: error))")
            }
        })
    }
}
