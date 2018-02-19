 //
//  ViewController.swift
//  sidebar test
//
//  Created by alden lamp on 8/21/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import UIKit
import Firebase

var firebaseData: FirebaseDataClass!

let studentDataLoaded = NSNotification.Name(rawValue: "ReloadStudentData")
let teacherDataLoaded = NSNotification.Name(rawValue: "ReloadTeacherData")
let WifiDisconectedNotification = NSNotification.Name(rawValue: "WifiDisconectedNotification")
var testImage: UIImage?

 class Home: UIViewController, FirebaseProtocol, HistoryTableViewDelegate{
    
    
    let historyTableView = HistoryTableView()
    let statView = StatsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.984, alpha: 1.00)
        
        firebaseData = FirebaseDataClass()
        firebaseData.firebaseDataDelegate = self
        historyTableView.historyDelegate = self
        
        if firebaseData.userID != nil{
            firebaseData.pullingAllData()
        }
        
        //Setting up USER INTERFACE
        setUpNavigation()
        setUpStats()
        setUpTableView()
    }
    
    //MARK: - reloading Data
    
    func historyArrayDidLoad() {
        var lateCounts = [0, 0, 0]
        for i in firebaseData.allItems{
            if (i.thisCellType == .fromHistory || i.thisCellType == .studentHistory) && i.status != .rejected{
                switch i.thisTimeFrame{
                case .thisWeek: lateCounts[0] += 1;
                case .thisMonth: lateCounts[1] += 1
                case .thisYear: lateCounts[2] += 1
                default: break
                }
            }
        }
        statView.lateCounts = lateCounts
        
        historyTableView.infoArray = firebaseData.allItems
        historyTableView.tableViewIsHidden = false
        
        print("\n\nhistory data loaded\n\n")
    }
    
    //MARK: - Stats
    
    func setUpStats(){
        statView.setUpStats()
        self.view.addSubview(statView)
        statView.translatesAutoresizingMaskIntoConstraints = false
        statView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 84).isActive = true
        statView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
        statView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
    }
    
    
    //MARK: - TableView
    
    func setUpTableView(){
        self.view.addSubview(historyTableView)
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        
        historyTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        historyTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        historyTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        historyTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200).isActive = true
        
        historyTableView.tableViewIsHidden = true
        
        historyTableView.infoArray = firebaseData.allItems
        
        historyTableView.start()
        
    }
    
    func historyTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, with historyData: HistoryData) {
        
        let data = firebaseData.allItems[indexPath.row]
        // Creating the new cell with attributes
        let vc = ExpandedCellTeacher()
        vc.historyData = data
        
        
        vc.titleLabel.text = historyData.toStringReadable()
        vc.dateLabel.text = historyData.getDateString()
        self.present(vc, animated: true, completion: nil)
    }
    
    
    //MARK: - Navigation
    
    private func setUpNavigation(){
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.layer.borderColor = UIColor.white.cgColor
        navigationController?.navigationBar.layer.borderWidth = 0
        navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 1, height: 2)
        navigationController?.navigationBar.layer.shadowRadius = 1
        navigationController?.navigationBar.layer.shadowOpacity = 0.3
        
        let titleImage = UIImageView(image: #imageLiteral(resourceName: "Title"))
        
        navigationItem.titleView = titleImage
        
        let menuButton = UIButton(type: .system)
        menuButton.setImage(#imageLiteral(resourceName: "icons8-menu_filled").withRenderingMode(.alwaysOriginal), for: .normal)
        menuButton.frame = CGRect(x: 0, y: 0, width: 20, height: 23)
        menuButton.heightAnchor.constraint(equalToConstant: 23).isActive = true
        menuButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        menuButton.addTarget(self, action: #selector(openSideBar), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        let plusButton = UIButton(type: .system)
        plusButton.setImage(#imageLiteral(resourceName: "icons8-plus_math_filled").withRenderingMode(.alwaysOriginal), for: .normal)
        plusButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        plusButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        plusButton.addTarget(self, action: #selector(Home.openNewRequest), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: plusButton)
    }
    
    @objc private func openSideBar() {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NavigationNotifications.toggleMenu), object: self))
    }
    
    @objc private func openNewRequest(){
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
