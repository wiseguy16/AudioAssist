//
//  Message.swift
//  TwoCans2
//
//  Created by Gregory Weiss on 9/19/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//
// CURRENT WORKING VERSION!!!!!!!!!!!!!!!!!!!!!!!!!! Sept 26th! 2016


import Foundation
import Firebase


class Message
{
    var request: String = ""
    var name: String = ""
    var completed: Bool = false
    var removeRequest: Bool = false
    var ref: FIRDatabaseReference?
   
    
    init(request: String = "", name: String = "", completed: Bool = false, removeRequest: Bool = false)
    {
        self.request = request
        self.name = name
        self.completed = completed
        self.removeRequest = removeRequest
        self.ref = nil
    }
 
    
    func convertMessageToSnapshot(aMsg: Message) -> [String: AnyObject]
    {
        
        let name = aMsg.name
        let request = aMsg.request
        let completed = aMsg.completed
        let removeRequest = aMsg.removeRequest
        
        let messageData = ["name": name, "request": request, "completed": completed, "removeRequest": removeRequest]
        
        return messageData as! [String : AnyObject]
        
    }
    
    
    
    
  static func convertSnapshotToMessage(aSnap: FIRDataSnapshot) -> Message?
    {
        
        var message = aSnap.value as! Dictionary<String, AnyObject>
        if let request = message["request"], let name = message["name"], let completed = message["completed"], let removeRequest = message["removeRequest"]
        {
            var aMessage = Message(request: request as! String, name: name as! String, completed: completed as! Bool, removeRequest: removeRequest as! Bool)
            aMessage.ref = aSnap.ref
            
            return aMessage
        }
        return nil
    }


    
}


//    func convertMessageToFIRData() -> [String: AnyObject]
//    {
//        return ["name": name, "request": request, "completed": completed, "removeRequest": removeRequest]
//    }
