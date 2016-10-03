//
//  LayoutConfigTableViewController.swift
//  TwoCans2
//
//  Created by Gregory Weiss on 9/24/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit

class LayoutConfigTableViewController: UITableViewController, UITextFieldDelegate {
    
      var delegate: PickMusicianDelegate?
    
    var arrayOfOptions = [Musician]()
    var uniqueTagID = Int(arc4random_uniform(999999))
    var wasAdded = false
    
    var toBeAddedMusicians: [Musician] = []
    
    let addImage = UIImage(named: "EmptyAdd_icon")
    let addedImage = UIImage(named: "AddedFull_icon")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMusicianOptions()
        uniqueTagID = uniqueTagID + 1
         //uniqueTagID = Int(arc4random_uniform(9999))
        //var uniqueTagID = Int(uniqueTagIDtemp)
      //  var uniqueTagID = arc4random_uniform(9999) % 10

        // Uncomment the following line to preserve selection between presentations tiny change
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return arrayOfOptions.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ConfigOptionsCell", forIndexPath: indexPath) as! ConfigOptionsCell
        
        let aMusician = arrayOfOptions[indexPath.row]
        cell.nameTextField.text = aMusician.name
        cell.positionXTextField.text = "\(aMusician.positionX)"
        cell.positionYTextField.text = "\(aMusician.positionY)"
        cell.musicianImageView.image = UIImage(named: aMusician.iconImage)
        
        
        let matchesFound = toBeAddedMusicians.filter { $0.uniqueID == aMusician.uniqueID }
        
            if matchesFound.count > 0
            {
                cell.addMusicianButton.setImage(addedImage, forState: .Normal)
            }
            else
            {
              cell.addMusicianButton.setImage(addImage, forState: .Normal)
            }
        
        return cell
    }
    
    @IBAction func addMusicianTapped(sender: UIButton)
    {
        uniqueTagID = uniqueTagID + 1
        let view = sender.superview
        let cell = view!.superview as! ConfigOptionsCell
        
        let thisIndexPath = self.tableView?.indexPathForCell(cell)
        let aMusician = arrayOfOptions[thisIndexPath!.row]
        aMusician.uniqueID = uniqueTagID  //Int(uniqueTagID)
        
            if sender.imageView?.image == addedImage
        {
            // cell is already selected, unselect it
            sender.setImage(addImage, forState: .Normal)
            if toBeAddedMusicians.count > 0
            {
                var myIndex = 0
                for thisMusician in toBeAddedMusicians
                {
                    if thisMusician.uniqueID == aMusician.uniqueID
                    {
                        toBeAddedMusicians.removeAtIndex(myIndex)
                        break
                    }
                    else
                    {
                        myIndex = myIndex + 1
                    }
                }
            }
        }
        else if sender.imageView?.image == addImage
        {
            // cell is not selected, select it
            sender.setImage(addedImage, forState: .Normal)
            toBeAddedMusicians.append(aMusician)
        }
        
        
    }
    
    func loadMusicianOptions()
    {
        
        
        let filePath = NSBundle.mainBundle().pathForResource("musicianOptions", ofType: "json")
        let dataFromFile2 = NSData(contentsOfFile: filePath!)
        do
        {
            
            let jsonData = try NSJSONSerialization.JSONObjectWithData(dataFromFile2!, options: [])
            
            guard let jsonDict = jsonData as? [String: AnyObject],
                let itemsArray = jsonDict["items"] as? [[String: AnyObject]]
                
                else
            {
                return
            }
            
            for aMusDict in itemsArray
            {
                let aMusician = Musician(myDictionary: aMusDict)
                arrayOfOptions.append(aMusician)
            }
            
        }
        catch let error as NSError {
            print(error)
        }
    }

    @IBAction func exitOnLeftTapped(sender: UIBarButtonItem)
    {
        // put delegate stuff here
        
        delegate?.musicianWasChosen(toBeAddedMusicians)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        let view = textField.superview
        let cell = view!.superview as! ConfigOptionsCell
        
        let thisIndexPath = self.tableView?.indexPathForCell(cell)
        let aMusician = arrayOfOptions[thisIndexPath!.row]

        print(aMusician)
       if textField == cell.nameTextField
       {
        aMusician.name = textField.text!
        cell.positionXTextField.becomeFirstResponder()
        }
        else if textField == cell.positionXTextField
       {
        aMusician.positionX = Int(textField.text!)!
        cell.positionYTextField.becomeFirstResponder()
        }
        else if textField == cell.positionYTextField
       {
        aMusician.positionY = Int(textField.text!)!
        resignFirstResponder()
        }
        
        tableView.reloadData()
        return true
    }

    
    
    

}
