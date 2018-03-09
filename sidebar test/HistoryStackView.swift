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
}

class HistoryStackView: UIView, NotificationDelegate {
    
    var historyStack = Stack()
    var currentView = NotificationView()
    
    weak var delegate: HistoryStackViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
            
        self.addSubview(currentView)
        currentView.translatesAutoresizingMaskIntoConstraints = false
        currentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        currentView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        currentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        currentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        currentView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createStack(arr: [HistoryData]){
        historyStack.clear()
        if arr.isEmpty{
            showNewView(from: nil)
            return
        }
        
        for i in arr.reversed(){
            if Int(Date().timeIntervalSince1970) - i.timeStarted < (45 * 60){
                historyStack.push(historyItem: i)
            }
        }
        
        if historyStack.isEmpty(){
            showNewView(from: nil)
            return
        }
        
        showNewView(from: historyStack.pop())
    }
    
    private func showNewView(from data: HistoryData?){
        currentView.updateViewWith(historyData: data)
    }
    
    internal func didDissmissView() {
        currentView.isHidden = true
        showNewView(from: historyStack.pop())
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { [weak self] in
            self?.currentView.isHidden = false
        })
    }
    
    internal func didRespondTo(historyData data: HistoryData, with accepted: Bool) {
        FirebaseRequests.acceptPass(withStatus: accepted, data: data, completion: delegate.didRespondToRequest(title:message:button:worked:))
    }
    
    
}




struct Stack{
    private var arr = [HistoryData]()
    mutating func push(historyItem data: HistoryData){
        arr.append(data)
    }
    
    mutating func pop() -> HistoryData?{
        if arr.isEmpty{
            return nil
        }
        return arr.removeLast()
    }
    
    mutating func clear(){
        arr.removeAll()
    }
    
    func isEmpty() -> Bool{
        return arr.isEmpty
    }
}
