//
//  Musician.swift
//  TwoCans2
//
//  Created by Gregory Weiss on 9/22/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import Foundation
import Firebase

class Musician
{
    var name: String
    var iconImage: String
    var titleForLabel: String
    var positionX: Int
    var positionY: Int
    var width: Int
    var height: Int
    var uniqueID: Int
    var doesExist: Bool
    var hasBeenDrawn: Bool
    var ref: FIRDatabaseReference?
    
    init(myDictionary: [String: AnyObject])
    {
        
        name = myDictionary["name"] as! String
        iconImage = myDictionary["iconImage"] as! String
        titleForLabel = myDictionary["titleForLabel"] as! String
        positionX = myDictionary["positionX"] as! Int
        positionY = myDictionary["positionY"] as! Int
        width = myDictionary["width"] as! Int
        height = myDictionary["height"] as! Int
        uniqueID = myDictionary["uniqueID"] as! Int
        doesExist = myDictionary["doesExist"] as! Bool
        hasBeenDrawn = myDictionary["hasBeenDrawn"] as! Bool
    }

    
    init(name: String = "", iconImage: String = "", titleForLabel: String = "", positionX: Int = 0, positionY: Int = 0, width: Int = 0, height: Int = 0, uniqueID: Int = 0, doesExist: Bool = false, hasBeenDrawn: Bool = false)
    {
        self.name = name
        self.iconImage = iconImage
        self.titleForLabel = titleForLabel
        self.positionX = positionX
        self.positionY = positionY
        self.width = width
        self.height = height
        self.uniqueID = uniqueID
        self.doesExist = doesExist
        self.hasBeenDrawn = hasBeenDrawn
        self.ref = nil
    }
    
    static func convertSnapshotToMusician(aSnap: FIRDataSnapshot) -> Musician?
    {
       var musician = aSnap.value as! Dictionary<String, AnyObject>
        if let name = musician["name"], let iconImage = musician["iconImage"], let titleForLabel = musician["titleForLabel"], let positionX = musician["positionX"], let positionY = musician["positionY"], let width = musician["width"], let height = musician["height"], let uniqueID = musician["uniqueID"], let doesExist = musician["doesExist"], let hasBeenDrawn = musician["hasBeenDrawn"]
        {
            let aMusician = Musician(name: name as! String, iconImage: iconImage as! String, titleForLabel: titleForLabel as! String, positionX: positionX as! Int, positionY: positionY as! Int, width: width as! Int, height: height as! Int, uniqueID: uniqueID as! Int, doesExist: doesExist as! Bool, hasBeenDrawn: hasBeenDrawn as! Bool)
            aMusician.ref = aSnap.ref
            return aMusician
        }
        return nil
    }
    
        

    
}


/*
 
 var pianoButton = UIButton()
 pianoButton.frame = CGRect(x: 70, y: 70, width: 68, height: 68)
 pianoButton.setImage(UIImage(named: "piano.png"), forState: .Normal)
 pianoButton.setTitle("fred", forState: .Normal)
 pianoButton.addTarget(self, action: #selector(buttonPressed), forControlEvents: .TouchUpInside)
 

 */