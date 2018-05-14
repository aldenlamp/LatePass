//
//  HistoryStackView.swift
//  sidebar test
//
//  Created by alden lamp on 2/26/18.
//  Copyright © 2018 alden lamp. All rights reserved.
//

import UIKit

protocol HistoryStackViewDelegate: class{
    func didRespondToRequest(title: String, message: String, button: String, worked: Bool)
    func newDataShown(data: HistoryData?)
}

class HistoryStackView: UIView, NotificationDelegate {
    
//    weak var historyStack: Stack! = Stack()
    var historyStack: Stack
    var currentView: NotificationView! = NotificationView()
    
    weak var delegate: HistoryStackViewDelegate?
    
    deinit {
        print("StackView did Deinit")
        historyStack.saveData()
    }
    
    override init(frame: CGRect) {
        historyStack = Stack()
        super.init(frame: frame)
        
        self.addSubview(currentView)
        currentView.translatesAutoresizingMaskIntoConstraints = false
        currentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        currentView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        currentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        currentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        currentView.delegate = self
        let thing: HistoryData? = historyStack.pop()
        showNewView(from: thing, wthDelayOf: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addToStack(data: [HistoryData]){
        historyStack.addToArr(data: data)
        showNewView(from: historyStack.pop(), wthDelayOf: 0.3)
    }
    
    private func showNewView(from data: HistoryData?, wthDelayOf time: Double){
        if time > 0.0{
            currentView.isHidden = true
            currentView.updateViewWith(historyData: data)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { [weak self] in
                self?.currentView.isHidden = false
            })
        }else{
            currentView.updateViewWith(historyData: data)
        }
        delegate?.newDataShown(data: data)
    }
    
    internal func didDissmissView() {
        historyStack.didDismiss()
        showNewView(from: historyStack.pop(), wthDelayOf: 0.3)
    }
    
    internal func didRespondTo(historyData data: HistoryData, with accepted: Bool) {
        historyStack.didDismiss()
        FirebaseRequests.acceptPass(withStatus: accepted, data: data, completion: { [weak self] (title, message, button, worked) in
            self?.delegate?.didRespondToRequest(title: title, message: message, button: button, worked: worked)
        })
    }
    
    
}




class Stack{
    private var stackArr = [HistoryData]()
    private var nonoArr = [HistoryData]()
    private var currentPop: HistoryData!
    private var didLoadUD = false
    
    private func loadUserDefaults(){
        if let arr = UserDefaults.standard.value(forKey: "HistoryNonoArr") as? [String]{
            for i in arr{
                for j in firebaseData.allItems{
                    if j == i{
                        nonoArr.append(j)
                    }
                }
            }
            validateNonoArr()
        }
        
        if let arr = UserDefaults.standard.value(forKey: "HistoryStackData") as? [String]{
            var shortArr = [HistoryData]()
            for i in arr{
                for j in firebaseData.allItems{
                    if j == i{
                        shortArr.append(j)
                    }
                }
            }
            addToArr(data: shortArr)
        }
    }
    
    func saveData(){
        validateData()
        var newNonoArr = [String]()
        for i in nonoArr{
            newNonoArr.append(i.ID)
        }
        UserDefaults.standard.set(newNonoArr, forKey: "HistoryNonoArr")
        
        var newArr = [String]()
        for i in stackArr{
            newArr.append(i.ID)
        }
        UserDefaults.standard.set(newArr, forKey: "HistoryStackData")
    }
    
    func isNewData(data: HistoryData?) -> Bool{
        guard let newData = data else{
            return currentPop == nil
        }
        
        if newData == currentPop{
            return false
        }
        return true
    }
    
    func pop() -> HistoryData?{
        if stackArr.isEmpty{
            currentPop = nil
            return nil
        }
        currentPop = stackArr.last
        return stackArr.removeLast()
    }
    
    func didDismiss(){
        nonoArr.append(currentPop)
        currentPop = nil
        saveData()
    }
    
    func isEmpty() -> Bool{
        return stackArr.isEmpty
    }
    
    func contains(data: HistoryData) -> Bool{
        return stackArr.contains(data)
    }
    
    func addToArr(data: [HistoryData]){
        if !didLoadUD{
            didLoadUD = true
            loadUserDefaults()
        }
        
        for i in data{
            if !contains(data: i) && !nonoArr.contains(i) && i.isWithinTime(){
                stackArr.append(i)
            }
        }
        
        if currentPop != nil && !contains(data: currentPop){
            stackArr.append(currentPop)
        }
        
        validateData()
        
        stackArr.sort(by: {$0.timeStarted < $1.timeStarted})
    }
    
    func validateData(){
        for i in stackArr{
            if !i.isWithinTime(){
                stackArr.remove(at: stackArr.index(of: i)!)
            }
        }
        
        validateNonoArr()
    }
    
    func validateNonoArr(){
        for i in nonoArr{
            if !i.isWithinTime(){
                nonoArr.remove(at: nonoArr.index(of: i)!)
            }
        }
    }
}
