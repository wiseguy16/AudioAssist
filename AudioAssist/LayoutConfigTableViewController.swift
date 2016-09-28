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
    var uniqueTagID = arc4random()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMusicianOptions()

        // Uncomment the following line to preserve selection between presentations
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

        // Configure the cell...

        return cell
    }
    
    @IBAction func addMusicianTapped(sender: UIButton)
    {
       // let button = sender as! UIButton
        uniqueTagID = uniqueTagID + 1
        let view = sender.superview
        let cell = view!.superview as! ConfigOptionsCell
        
        let thisIndexPath = self.tableView?.indexPathForCell(cell)
        let aMusician = arrayOfOptions[thisIndexPath!.row]
        aMusician.uniqueID = Int(uniqueTagID)
        delegate!.musicianWasChosen(aMusician)

        
        
        
        
//        let contentView = sender.superview
//        let cell = contentView!.superview as! ConfigOptionsCell
//        let thisIndexPath = self.tableView?.cellForRowAtIndexPath(cell)    //   .indexPathForCell(cell)
//        let aPodcast = podcastItems[thisIndexPath!.row]
//        let theIndex: Int = indexPath.row
//        let theZone = zones[indexPath.row]
//        delegate!.musicianWasChosen(pickedMusician, theIndex: theIndex)
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

    
    
    
//    
//    @IBAction func exitOnTopTapped(sender: UIButton)
//    {
//        self.dismissViewControllerAnimated(true, completion: nil)
//
//        
//    }
// 
//    @IBAction func exitTapped(sender: UIBarButtonItem)
//    {
//       self.dismissViewControllerAnimated(true, completion: nil)
//    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
