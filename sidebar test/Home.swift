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

class Home: UIViewController, UITableViewDelegate, UITableViewDataSource, FirebaseProtocol{
    

    //INDEX 0: this week, 1: this month, 2: this year
    var lateCounts = [0, 0, 0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.984, alpha: 1.00)
        
        firebaseData = FirebaseDataClass()
        firebaseData.firebaseDataDelegate = self
        if firebaseData.userID != nil{ firebaseData.pullingAllData() }
        
        //Setting up USER INTERFACE
        setUpNavigation()
        setUpStats()
        setUpKey()
        setUpTableView()
    }
    
    //MARK: - reloading Data
    // FirebaseDataDelegae functions
    func uesrDataDidLoad() {
        print("\n\nuser data loaded\n\n")
    }
    
    func historyArrayDidLoad() {
        firebaseData.allItems += firebaseData.historyItems
        historyQuickSort(lowerIndex: 0, higherIndex: firebaseData.allItems.count - 1)
        historyTableView.reloadData()
        tableViewExists()
        
        //this is for the numbers and statistics on the top
        for i in firebaseData.allItems{
            if (i.thisCellType! == .fromHistory || i.thisCellType == .studentHistory) && i.status! != .rejected{
                switch i.thisTimeFrame!{
                case .thisWeek: lateCounts[0] += 1;
                case .thisMonth: lateCounts[1] += 1
                case .thisYear: lateCounts[2] += 1
                }
            }
        }
        
        updateStatView()
        firebaseData.calcBoth = false
        print("\n\nhistory data loaded\n\n")
    }
    
    func requestArrayDidLoad() {
        firebaseData.allItems += firebaseData.requestItems
        historyQuickSort(lowerIndex: 0, higherIndex: firebaseData.allItems.count - 1)
        historyTableView.reloadData()
        tableViewExists()
        firebaseData.calcBoth = false
        print("\n\nrequest data loaded\n\n")
    }
    
    //quick sort for sorting the history items by time
    func historyQuickSort(lowerIndex: Int, higherIndex: Int){
        var lower = lowerIndex
        var higher = higherIndex
        let pivot = firebaseData.allItems[lower + (higher - lower) / 2].timeStarted!
        while(lower <= higher){
            while(firebaseData.allItems[lower].timeStarted! > pivot){ lower += 1 }
            while(firebaseData.allItems[higher].timeStarted! < pivot){ higher -= 1 }
            if lower <= higher{
                exchangeNumbers(lower: lower, higher: higher)
                lower += 1
                higher -= 1
            }
        }
        if lowerIndex < higher{ historyQuickSort(lowerIndex: lowerIndex, higherIndex: higher) }
        if lower < higherIndex{ historyQuickSort(lowerIndex: lower, higherIndex: higherIndex) }
    }
    
    func exchangeNumbers(lower: Int, higher: Int){
        let temp = firebaseData.allItems[lower]
        firebaseData.allItems[lower] = firebaseData.allItems[higher]
        firebaseData.allItems[higher] = temp
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
    
    //MARK: - Stats
    
    var statArr = [UIView]()
    
    private func setUpStats(){
        statArr.append(createStatView(name: "This Year", count: lateCounts[2], index: 0))
        statArr.append(createStatView(name: "This Month", count: lateCounts[1], index: 1))
        statArr.append(createStatView(name: "This Week", count: lateCounts[0], index: 2))
        
        let stackView = UIStackView(arrangedSubviews: statArr)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 84).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
    }
    
    private func createStatView(name: String, count: Int, index: Int) -> UIView{
        let numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 90, height: 70))
        numberLabel.text = "\(count)"
        numberLabel.textAlignment = .center
        numberLabel.font = UIFont(name: "Avenir-Heavy", size: 51)
        numberLabel.tag = 1
        switch index {
        case 0: numberLabel.textColor = UIColor(hex: "8FB3FB", alpha: 1)
        case 1: numberLabel.textColor = UIColor(hex: "BB8FF1", alpha: 1)
        case 2: numberLabel.textColor = UIColor(hex: "79D6DC", alpha: 1)
        default: break
        }
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 90, height: 23))
        titleLabel.text = name
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "Avenir-Medium", size: 15.75)
        titleLabel.textColor = UIColor(hex: "798CAD", alpha: 1)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 93))
        containerView.backgroundColor = UIColor.clear
        
        containerView.addSubview(numberLabel)
        containerView.addSubview(titleLabel)
        
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: numberLabel, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: numberLabel, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: numberLabel, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: numberLabel, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
        return containerView
    }
    
    private func updateStatView(){
        for i in 0...2{
            (statArr[2-i].viewWithTag(1) as! UILabel).text = String(lateCounts[i])
        }
    }
    
    //MARK: - Key
    
    let keyView = UIView()
    
    func setUpKey(){
        keyView.frame = CGRect(x: 0, y: 230, width: self.view.frame.width, height: 50)
        
        self.view.addSubview(keyView)
        
        keyView.backgroundColor = UIColor.white
        
        keyView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 230).isActive = true
        keyView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        keyView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        keyView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        keyView.translatesAutoresizingMaskIntoConstraints = false
        
        keyView.layer.borderColor = UIColor.white.cgColor
        keyView.layer.borderWidth = 0
        keyView.layer.shadowColor = UIColor.lightGray.cgColor
        keyView.layer.shadowOffset = CGSize(width: 1, height: -2)
        keyView.layer.shadowRadius = 1
        keyView.layer.shadowOpacity = 0.3
        
        let approved = makeKeyView(key: 0)
        approved.tag = 0
        let pending = makeKeyView(key: 1)
        let declined = makeKeyView(key: 2)
        
        let stackView = UIStackView(arrangedSubviews: [approved, pending, declined])
        stackView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        keyView.addSubview(stackView)
        stackView.leftAnchor.constraint(equalTo: keyView.leftAnchor, constant: 20).isActive = true
        stackView.rightAnchor.constraint(equalTo: keyView.rightAnchor, constant: -20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: keyView.bottomAnchor, constant: -15).isActive = true
        stackView.topAnchor.constraint(equalTo: keyView.topAnchor, constant: 15).isActive = true
    }
    
    func makeKeyView(key: Int) -> UIView{
        let imageView = UIImageView()
        let title = UILabel()
        
        switch(key){
        case 0:
            imageView.image = #imageLiteral(resourceName: "approved-lightGrey")
            title.text = "Approved"
        case 1:
            imageView.image = #imageLiteral(resourceName: "pending-grey")
            title.text = "Pending"
        case 2:
            imageView.image = #imageLiteral(resourceName: "rejected-grey")
            title.text = "Declined"
        default: break
        }
        
        let view = UIView(frame: CGRect(x: 200, y: 210, width: 95, height: 20))
        view.addSubview(imageView)
        view.addSubview(title)
        
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        title.adjustsFontSizeToFitWidth = true 
        title.frame = CGRect(x: 0, y: 0, width: 61, height: 20)
        title.font = UIFont(name: "Avenir-Medium", size: 14)
        title.textColor = UIColor(hex: "435575", alpha: 1)
        title.textAlignment = .left
        
        title.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        title.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        title.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        title.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        
        NSLayoutConstraint(item: title, attribute: .leading, relatedBy: .equal, toItem: imageView, attribute: .trailing, multiplier: 1.0, constant: 10.0).isActive = true
        
        return view
    }
    
    //MARK: - TableView
    
    let historyTableView = UITableView()
    let shadowView = UIView()
    
    var historyTopAnchor = NSLayoutConstraint()
    var historyBottomAnchor = NSLayoutConstraint()
    var historyLeftAnchor = NSLayoutConstraint()
    var historyRightAnchor = NSLayoutConstraint()
    
    func setHistoryAnchors(to value: Bool){
        historyTopAnchor.isActive = value
        historyBottomAnchor.isActive = value
        historyRightAnchor.isActive = value
        historyLeftAnchor.isActive = value
    }
    
    func setUpTableView(){
        shadowView.addSubview(historyTableView)
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
        shadowView.backgroundColor = UIColor.white
        shadowView.layer.borderColor = UIColor.white.cgColor
        shadowView.layer.borderWidth = 0
        shadowView.layer.shadowColor = UIColor.lightGray.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 1, height: -2)
        shadowView.layer.shadowRadius = 1
        shadowView.layer.shadowOpacity = 0.3
        
        self.view.addSubview(shadowView)
        
        shadowView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        shadowView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        shadowView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        NSLayoutConstraint(item: shadowView, attribute: .top, relatedBy: .equal, toItem: keyView, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
        historyTopAnchor = historyTableView.topAnchor.constraint(equalTo: shadowView.topAnchor, constant: 0)
        historyBottomAnchor = historyTableView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor, constant: 0)
        historyLeftAnchor = historyTableView.leftAnchor.constraint(equalTo: shadowView.leftAnchor, constant: 0)
        historyRightAnchor = historyTableView.rightAnchor.constraint(equalTo: shadowView.rightAnchor, constant: 0)
        
        
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        
        historyTableView.register(HistoryCell.self, forCellReuseIdentifier: "Cell")
        
        historyTableView.removeFromSuperview()
    }
    
    var tableViewIsShown = false
    
    func tableViewExists(){
        if !tableViewIsShown && firebaseData.allItems.count > 0{
            
            shadowView.addSubview(historyTableView)
            setHistoryAnchors(to: true)
            
            tableViewIsShown = !tableViewIsShown
        }else if tableViewIsShown && firebaseData.allItems.count == 0{
            
            setHistoryAnchors(to: false)
            historyTableView.removeFromSuperview()
            tableViewIsShown = !tableViewIsShown
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firebaseData.allItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 90 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HistoryCell
        
        let historyData = firebaseData.allItems[indexPath.row]
        cell.updateWithHistoryData(data: historyData)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        let cell = tableView.cellForRow(at: indexPath) as! HistoryCell
        cell.setSelected(false, animated: true)
        
        let data = firebaseData.allItems[indexPath.row]
        
        
        // Creating the new cell with attributes
        let vc = ExpandedCell()
        vc.historyData = data
        vc.titleLabel.text = cell.titleLabel.text
        vc.dateLabel.text = cell.dateLabel.text
        
        self.present(vc, animated: true, completion: nil)
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
