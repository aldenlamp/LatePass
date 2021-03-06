
//
//  ViewController.swift
//  sidebar test
//
//  Created by alden lamp on 8/21/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import UIKit
import Firebase
 
 import Google
 import GoogleSignIn
import GoogleAPIClientForREST
 
var firebaseData: FirebaseDataClass!

//let studentDataLoaded = NSNotification.Name(rawValue: "ReloadStudentData")
//let teacherDataLoaded = NSNotification.Name(rawValue: "ReloadTeacherData")
let userDataLoadedNotification = NSNotification.Name(rawValue: "ReloadUserData")
let WifiDisconectedNotification = NSNotification.Name(rawValue: "WifiDisconectedNotification")
let userDataDidLoadNotif = NSNotification.Name(rawValue: "userDataDidLoad")
let logInFailedNotif = NSNotification.Name(rawValue: "logInFailed")
let GCUsersLoaded = NSNotification.Name(rawValue: "GCUsersLoaded")

var testImage: UIImage?
 let activityIndicator = UIActivityIndicatorView()

class Home: UIViewController, FirebaseProtocol, HistoryTableViewDelegate, HistoryStackViewDelegate, ExpandedViewControllerDelegate{
    
    var sv = UIScrollView()
    
    let historyTableView = HistoryTableView()
    let statView = StudentStatsView()
    let historyStackView = HistoryStackView()
    var withStats: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.984, alpha: 1.00)
        
        expandVC.delegate = self
        
        if firebaseData == nil{
            firebaseData = FirebaseDataClass()
            firebaseData.firebaseDataDelegate = self
            
            initStatViewWith(userType: firebaseData.savedUserType)
            
//            self.addLoadingView(with: "Loading Data")
            
        }else{
            
            firebaseData.firebaseDataDelegate = self
            
            initStatViewWith(userType: firebaseData.currentUser.userType)
            
            var lateCounts = [0, 0, 0]
            for i in firebaseData.allItems{
                if (i.thisCellType == .fromHistory || i.thisCellType == .studentHistory) && i.status != .rejected{
                    switch i.thisTimeFrame{
                    case .thisWeek: lateCounts[0] += 1;
                    case .thisMonth: lateCounts[1] += 1
                    case .thisYear: lateCounts[2] += 1
                    }
                }
            }
            
            if withStats { statView.lateCounts = lateCounts }
            
            
            historyTableView.animateActivityIndicator = false
            historyTableView.infoArray = firebaseData.filteredItems
            historyStackView.addToStack(data: firebaseData.filteredItems)
//            historyStackView.createStack(arr: firebaseData.filteredItems)
            
        }
        
        historyTableView.historyDelegate = self
        
//        print(firebaseData.savedUserType.rawValue)
        setUpNavigation()
    }
    
    deinit{
        print("Home View Controller did Deinit")
//        UserDefaults.standard.set(nil, forKey: "userType")
    }
    
    
    //MARK: - reloading Data
    
    internal func historyArrayDidLoad() {
        
//        self.removeLoadingView()
        
        var lateCounts = [0, 0, 0]
        for i in firebaseData.allItems{
            if (i.thisCellType == .fromHistory || i.thisCellType == .studentHistory) && i.status != .rejected{
                switch i.thisTimeFrame{
                case .thisWeek: lateCounts[0] += 1;
                case .thisMonth: lateCounts[1] += 1
                case .thisYear: lateCounts[2] += 1
                }
            }
        }
        
        if withStats { statView.lateCounts = lateCounts }
        
        
        historyTableView.animateActivityIndicator = false
        historyTableView.infoArray = firebaseData.filteredItems
//        print("\n\nAllowed highlight: \(historyTableView.highlightObject(data: historyTableView.infoArray[0]))\n\n")
        
//        historyStackView.createStack(arr: firebaseData.filteredItems)
        historyStackView.addToStack(data: firebaseData.filteredItems)
        
        print("\n\nhistory data loaded\n\n")
    }
    
    private func printArr(i : [AnyObject]){
        for j in i{
            print(j)
        }
    }
    
    private func initStatViewWith(userType: userType?) {
        
        if let userType = userType{
            //call a function that sets up the respective view
//            setUpStats(andShow: userType == .student)
            withStats = userType == .student
            setUpTableView(withStats: withStats)
        }else{
            //Call a function that shows an activity signal on whole screen until user loads
            if !activityIndicator.isAnimating{
                activityIndicator.startAnimating()
            }
        }
    }
    
    internal func userDataDidLoad() {
        //Stop Acticator Signal if it was on
        if activityIndicator.isAnimating{
            activityIndicator.stopAnimating()
            initStatViewWith(userType: firebaseData.currentUser.userType)
        }
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "setUpUserAttributesSideBar")))
    }
    
    private func setUpActivityIndicator(){
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor(hex: "55596B", alpha: 1)
        activityIndicator.isHidden = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicator)
        activityIndicator.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
    }
    
    //MARK: - Stats
    
    private func setUpStats(){
        statView.setUpStats()
        self.view.addSubview(statView)
        statView.translatesAutoresizingMaskIntoConstraints = false
//        statView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 84).isActive = true
        statView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        statView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
        statView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
    }
    
    //MARK: - HistoryStackView
    
    func setUpStackView(){
//        historyStackView.createStack(arr: firebaseData.filteredItems)
        historyStackView.addToStack(data: firebaseData.filteredItems)
    }
    
    func setUpNotificationView(){
        historyStackView.delegate = self
        self.view.addSubview(historyStackView)
        historyStackView.translatesAutoresizingMaskIntoConstraints = false
        historyStackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: navigationController!.navigationBar.frame.height + 13).isActive = true
        historyStackView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
        historyStackView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        historyStackView.bottomAnchor.constraint(equalTo: self.historyTableView.topAnchor, constant: 0).isActive = true
    }
    
    func didRespondToRequest(title: String, message: String, button: String, worked: Bool) {
        if !worked{
            self.alert(title: title, message: message, buttonTitle: button)
        }
    }
    
    func newDataShown(data: HistoryData?) {
        guard let highlighData = data else {
            historyTableView.clearHighlights()
            return
        }
        print("\n\nHighlight of data: \(highlighData)\t\t\(historyTableView.highlightObject(data: highlighData))")
    }
    
    //MARK: - TableView
    
    let expandVC = ExpandedCellTeacher()
    
    private func setUpTableView(withStats stats: Bool){
       
        
        self.view.addSubview(historyTableView)
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        
        historyTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        historyTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        historyTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        historyTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: stats ? 200 : 250).isActive = true//stats ? 200 : navigationController!.navigationBar.frame.height + 19.5).isActive = true
        
        historyTableView.tableViewIsHidden = true
        
        if stats {
            setUpStats()
        }else{
            setUpNotificationView()
        }
        
    }
    
    var isExpanded = false
    
    internal func historyTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, with historyData: HistoryData) {
        
//        let data = firebaseData.allItems[indexPath.row]
        // Creating the new cell with attributes
        
        expandVC.update(from: historyData)
        print("ExpandedCellID: \(historyData.ID)")
        
        if !isExpanded{
            self.present(expandVC, animated: true, completion: nil)
            isExpanded = true
        }
    }
    
    func willDismiss() {
        isExpanded = false
    }
    
    func searchDidFinish(withCount count: Int) {
        //Just to satisfy the delegate
    }
    
    
    
    //MARK: - Navigation
//
    private func setUpNavigation(){
        
        guard let navController = navigationController as? MainNavigationViewController else{
            print("THings got messed up")
            return
        }
        
        let titleImage = UIImageView(image: #imageLiteral(resourceName: "Title"))
        navigationItem.titleView = titleImage
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navController.rightRequestButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navController.leftMenuButton)
        
        navController.rightRequestButton.addTarget(self, action: #selector(openNewRequest), for: .touchUpInside)
        
        navController.plusButtonIsHidden = false
    }
    
    @objc func openNewRequest(){
        if firebaseData.currentUser != nil{
            let requestViewController = Request() as UIViewController
            self.present(requestViewController, animated: true, completion: nil)
        }else{
            alert(title: "No Wifi", message: "Please Connect to WIFI", buttonTitle: "Okay")
        }
    }
}


extension UIColor{
    convenience init (hex: String, alpha: CGFloat){
        let cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if ((cString.count) != 6) {  }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: alpha)
    }
}
 
 
 
 extension UIViewController{
    
    func alert(title: String, message: String, buttonTitle: String = "Done"){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: buttonTitle, style: .default, handler: {(handler) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
 }

extension Array where Element:User {
    func excluding(user email: String) -> [User] {
        var arr = [User]()
        print(self)
        print(self[0].userEmail)
        for i in 0..<self.count{
            if self[i].userEmail != email{
                arr.append(self[i])
            }
        }
//        for i in self{
//            if i.userEmail != email{
//                arr.append(i)
//            }
//        }
        return arr
    }
}


extension UIColor{
    static var textColor = UIColor(hex: "3D4C68", alpha: 1)
}
