//
//  SelectTeachers.swift
//  sidebar test
//
//  Created by alden lamp on 9/24/17.
//  Copyright © 2017 alden lamp. All rights reserved.
//

import UIKit
import Firebase


class SelectTeachers: UIViewController, UITableViewDelegate, UITableViewDataSource{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        setUpCancelButton()
        setUpTitle()
        setUpSearchBar()
        setUpTableView()
        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
//        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //Testing Pulling data to reload tableViews and such
//        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "testingReloadTableView"), object: nil, queue: nil) { [weak self] notification in
//            print("TESTINGIGNGINGINGIn")
            //print("\n\n\(String(describing: self?.titleLabel.text))\n\n")
//        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(testingReloadTableview), name: NSNotification.Name(rawValue: "testingReloadTableView"), object: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "testingReloadTableView"), object: nil)
        
        
        //            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "testingReloadTableView"), object: nil)
        
        
    }
    
    
    @objc func testingReloadTableview(){
//        print("TESTINGIGNGINGINGIn")
//        print("\n\n\(String(describing: self.titleLabel.text))\n\n")
    }
    
    func dismissKeyboard() { view.endEditing(true) }
    
    //MARK: - Cancel Button
    
    func setUpCancelButton(){
        let button = UIButton()
        button.image(for: .normal)
        button.setImage(#imageLiteral(resourceName: "icons8-delete_sign_filled"), for: .normal)
        button.frame = CGRect(x: 28, y: 41, width: 21, height: 21)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc private func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("This View has been Dinited")
        
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Title
    
    let titleLabel : UILabel = {
       let label = UILabel()
        label.text = "Select Student" /// TO BE CHANGED WHEN I FIGURE OUT IS STUDENT OR IS TEACHER
        label.font = UIFont(name: "Avenir-Light", size: 22)
        label.textColor = UIColor(hex: "3D4C68", alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        label.widthAnchor.constraint(equalToConstant: 190).isActive = true
        return label
    }()
    
    func setUpTitle(){
        self.view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 73).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
    }
    
    //MARK: - Search Bar
    
    let searchTextField : UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.clear
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.adjustsFontSizeToFitWidth = true
        textField.font = UIFont(name: "Avenir-Medium", size: 15)
        textField.textColor = UIColor(hex: "55596B", alpha: 1)
        
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor(hex: "8290AB", alpha: 1), NSAttributedStringKey.font : UIFont(name: "Avenir-Medium", size: 15)!]
        textField.attributedPlaceholder = NSAttributedString(string: "Search For Student", attributes: attributes) //Change Text Of PlaceHolder
        
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let searchView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let topBoarder = UIView()
        view.addSubview(topBoarder)
        topBoarder.translatesAutoresizingMaskIntoConstraints = false
        topBoarder.backgroundColor = UIColor(hex: "E3E3E3", alpha: 1)
        topBoarder.heightAnchor.constraint(equalToConstant: 1).isActive = true
        topBoarder.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        topBoarder.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        topBoarder.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        
        let bottomBoarder = UIView()
        view.addSubview(bottomBoarder)
        bottomBoarder.translatesAutoresizingMaskIntoConstraints = false
        bottomBoarder.backgroundColor = UIColor(hex: "E3E3E3", alpha: 1)
        bottomBoarder.heightAnchor.constraint(equalToConstant: 1).isActive = true
        bottomBoarder.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        bottomBoarder.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        bottomBoarder.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        
        let imageView = UIImageView()
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "icons8-search_filled")
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 27).isActive = true
        imageView.tag = 9
        
        return view
    }()
    
    func setUpSearchBar(){
        searchView.addSubview(searchTextField)
        searchTextField.heightAnchor.constraint(equalToConstant: 25).isActive = true
        searchTextField.centerYAnchor.constraint(equalTo: searchView.centerYAnchor, constant: 0).isActive = true
        searchTextField.leftAnchor.constraint(equalTo: (searchView.viewWithTag(9)?.rightAnchor)!, constant: 8).isActive = true
        searchTextField.rightAnchor.constraint(equalTo: searchView.rightAnchor, constant: -20).isActive = true
        
        self.view.addSubview(searchView)
        searchView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
        searchView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        searchView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        searchView.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        
    }
    
    
    //MARK: - TableView
    let tableView: UITableView = UITableView()
    
    func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints  = false
        tableView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 0).isActive = true // Change to search bar
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive  = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
    }
    
    
    //MARK: - TableView Functions
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 65 }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 5 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UserCell()
        
        // GET CELLS FROM FIREBASE DATA
        
//        cell.setUpCell(userImage: currentImage!, name: "Alden Lamp", email: "aldenblamp@gmail.com", containsSeparator: indexPath.row != 0, userImageAlpha: 1)
        if indexPath.row != 0{
            cell.contentView.alpha = 0.6
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    
  
//    Things that work when finished
//    func teacherChosen(){
//        selectedPerson = "helpMePlsPLSPLSPLSPLSPLSPLSPLSPLSPLSPLSPLSPLSPLSPLSPLSPLSpl"
//        self.dismiss(animated: true, completion: nil)
//    }
}
