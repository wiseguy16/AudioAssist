//
//  ChatViewController.swift
//  TwoCans2
//
//  Created by Gregory Weiss on 9/16/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit
import Firebase


protocol LoginViewControllerDelegate
{
    func didSetSessionID(sessionIDFromLogin: String?)
}

protocol PickMusicianDelegate
{
    func musicianWasChosen(pickedMusician: Musician)
}

class ChatViewController: UIViewController, PickMusicianDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate //, LoginViewControllerDelegate
{
    
    var arrayOfMusicians: [Musician] = []
   // var location = CGPoint(x: 0, y: 0)
    var hasBeenDisplayedOnce = false
    
    @IBOutlet weak var stageBackground: UIImageView!
     var start: CGPoint?
    var newCenter: CGPoint?
    
    @IBOutlet weak var backgroundForMovableIcons: UIView!
    
    @IBOutlet weak var deleteIconsSwitch: UISwitch!
    
    
    @IBOutlet weak var tableviewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lockLabel: UILabel!
    @IBOutlet weak var lockSwitch: UISwitch!
    
    @IBOutlet weak var pianoLabel: UILabel!
    
    @IBOutlet weak var chatTextField: UITextField!
    
    @IBOutlet weak var unlockLabel: UIButton!
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var newLabel2: UILabel!
    
    @IBOutlet weak var newGuitarButton2: UIButton!
    
    @IBOutlet var monkeyPan: UIPanGestureRecognizer!
    @IBOutlet var bananaPan: UIPanGestureRecognizer!
    @IBOutlet var guitarPan: UIPanGestureRecognizer!
    
    @IBOutlet weak var handLeftButton: UIButton!
    
    @IBOutlet weak var drums: UIImageView!
    @IBOutlet weak var elecGuitar: UIImageView!
    @IBOutlet weak var keys: UIImageView!
    @IBOutlet weak var piano: UIImageView!
    @IBOutlet weak var click: UIImageView!
    @IBOutlet weak var acoGuitar: UIImageView!
    
    @IBOutlet weak var handUp: UIImageView!
    @IBOutlet weak var handDown: UIImageView!
    @IBOutlet weak var handLeft: UIImageView!
    @IBOutlet weak var handRight: UIImageView!
    
     @IBOutlet weak var singleTapRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var iconLabel: UILabel!
    var canMoveIcons = false
    var toggledCompletion = false
    var requestsHidden = true
    
    var isChecked = false
    
    
    
   
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ChatViewController.handleRefresh(_:)), forControlEvents: .ValueChanged)
        
        return refreshControl
    }()
    
   
    
    let checkImage = UIImage(named: "checkedRequest.png")
    let unCheckImage = UIImage(named: "uncheckedRequest.png")
    let checkImageName = "checkedRequest.png"
    let unCheckImageName = "uncheckedRequest.png"
    
    //var uniqueSessionID: String = "a"
    
    
    var ref: FIRDatabaseReference!
    var refHandle: FIRDatabaseHandle!
    var messages = Array<FIRDataSnapshot>()
    
    
    var arrayOfMessages: [Message] = []
     var messageRefHandles = Array<FIRDatabaseHandle>()
   
    
    @IBOutlet weak var chattextFieldConstraint: NSLayoutConstraint!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configureDatabase()
        
        configureMusicians()
        
         self.tableview.addSubview(self.refreshControl)
        
       
//        displayMusiciansFromDatabase()
//        let testMusician = arrayOfMusicians[0]
//        let tButton = UIButton()
//        tButton.frame = CGRect(x: testMusician.positionX, y: testMusician.positionY, width: testMusician.width, height: testMusician.height)
//        tButton.setImage(UIImage(named: testMusician.iconImage), forState: .Normal)
//        tButton.setTitle(testMusician.name, forState: .Normal)
//        self.view.addSubview(tButton)
        
        // This is the default setting but be explicit anyway...
       // new_view.setTranslatesAutoresizingMaskIntoConstraints(true)
        
        //new_view.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin |
         //   UIViewAutoresizing.FlexibleRightMargin
       // new_view.center = CGPointMake(self.view.frame.size.height - 20, view.bounds.midY)
        
        
        let filteredSubviews = self.view.subviews.filter({
            $0.isKindOfClass(UIImageView) })
           // $0.isKindOfClass(UIButton) })
        // 2
        for view in filteredSubviews  {
            // 3
            
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))   //    (target: self, action: #Selector(handleTap))
            // 4
            
            recognizer.delegate = self
            view.addGestureRecognizer(recognizer)
            
            recognizer.requireGestureRecognizerToFail(monkeyPan)
            recognizer.requireGestureRecognizerToFail(bananaPan)
            recognizer.requireGestureRecognizerToFail(guitarPan)
            //TODO: Add a custom gesture recognizer too
        }
        
        
        
        
       // tableview.reloadData()
       // print(self.arrayOfMessages)
      //  NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
      //  NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        reloadMusicians()
    }
    
       func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        for deleteObject in arrayOfMessages
        {
            if deleteObject.completed == true
            {
                deleteObject.ref!.removeValue()
            }
        }
        

        
        self.tableview.reloadData()
        refreshControl.endRefreshing()
    }
    
  
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        if !AppState.sharedInstance.signedIn
        {
            performSegueWithIdentifier("ModalLoginSegue", sender: self)
        }
        
        
        
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func reloadMusicians()
    {
        for item in arrayOfMusicians
        {
            if item.doesExist == false
            {
                let aButton = UIButton()
                aButton.frame = CGRect(x: item.positionX, y: item.positionY, width: item.width + 10, height: item.height)
                aButton.setImage(UIImage(named: item.iconImage), forState: .Normal)
                aButton.setTitle(item.name, forState: .Normal)
                aButton.addTarget(self, action: #selector(buttonPressed), forControlEvents: .TouchUpInside)
                
                aButton.tag = item.uniqueID
                self.view.addSubview(aButton)
                let longPrssGesture = UILongPressGestureRecognizer()
                aButton.addGestureRecognizer(longPrssGesture)
                aButton.addTarget(self, action: #selector(buttonDragged), forControlEvents: .TouchDragInside)
                
                let dubTapGesture = UITapGestureRecognizer()
                dubTapGesture.numberOfTapsRequired = 2
                aButton.addGestureRecognizer(dubTapGesture)
                aButton.addTarget(self, action: #selector(doubleTappedWasInitiated), forControlEvents: .TouchUpInside)
                
                
                let aLabel = UILabel()
                aLabel.frame = CGRect(x: 0, y: -20, width: item.width, height: 15)
                aLabel.text = item.name
                aLabel.textColor = UIColor.blackColor()
                aLabel.sizeToFit()
                aButton.addSubview(aLabel)
                item.doesExist = true
                sendMusicianToFirebase(item)
                print("\(arrayOfMusicians.count)")
            }
        }
    }
    
    
    @IBAction func deleteSwitch(sender: UISwitch)
    {
        
        if deleteIconsSwitch.on
        {
            backgroundForMovableIcons.backgroundColor = UIColor.redColor()
            backgroundForMovableIcons.alpha = 0.2
        }
        else if !deleteIconsSwitch.on
        {
            backgroundForMovableIcons.alpha = 0
        }
    }

    @IBAction func lockToggled(sender: UISwitch)
    {
        
        if lockSwitch.on
        {
            lockLabel.text = "Icons locked"
            backgroundForMovableIcons.alpha = 0
        }
        else if !lockSwitch.on
        {
            lockLabel.text = "Icons unlocked"
            backgroundForMovableIcons.backgroundColor = UIColor.yellowColor()
            backgroundForMovableIcons.alpha = 0.2
        }
    }
    
    
    func buttonPressed(sender: UIButton)
    {
        
        if lockSwitch.on && !deleteIconsSwitch.on
        {
            
        chatTextField.text = chatTextField.text! + " " + sender.currentTitle!
            
        }
    }
    
    func buttonDragged(button: UIButton, event: UIEvent)
    {
        
        
        if !lockSwitch.on
        {
        let touch = event.touchesForView(button)!.first!  //touches(forView: button)!.first!
        // get delta
        let previousLocation = touch.previousLocationInView(button)//    .previousLocation(inView: button)
        let location = touch.locationInView(button)   //.location(inView: button)
        let delta_x: CGFloat = location.x - previousLocation.x
        let delta_y: CGFloat = location.y - previousLocation.y
        // move button
        button.center = CGPoint(x: button.center.x + delta_x, y: button.center.y + delta_y)
            
            
            for thisButton in arrayOfMusicians
            {
                if button.tag == thisButton.uniqueID
                {
                    thisButton.positionX = Int(button.center.x + delta_x - 34)
                    thisButton.positionY = Int(button.center.y + delta_y - 34)
                    let updatedMessage = ["positionX": thisButton.positionX, "positionY": thisButton.positionY]
                    
                    thisButton.ref?.updateChildValues(updatedMessage)
                }
            }
//            let contentView = button.superview
//            //let thisButton = contentView?.superview as! Musician
//            
//            let thisIndexPath = self.arrayOfMusicians.
//            
//            let myDone = arrayOfMessages[thisIndexPath!.row]
//            // var aSnap = messages[thisIndexPath!.row]
        }
        
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ConfigureSegue"
        {
            let pickVC = segue.destinationViewController as! LayoutConfigTableViewController
            pickVC.delegate = self
        }
        
    }
    
    func sendMusicianToFirebase(pickedMusician: Musician)
    {
        
        let musicianData = pickedMusician
        
        ref.child("musicians").childByAutoId().setValue(["name": musicianData.name,
                                                        "iconImage": musicianData.iconImage,
                                                        "titleForLabel": musicianData.titleForLabel,
                                                        "positionX": musicianData.positionX,
                                                        "positionY": musicianData.positionY,
                                                        "width": musicianData.width,
                                                        "height": musicianData.height,
                                                        "uniqueID": musicianData.uniqueID,
                                                        "doesExist": musicianData.doesExist,
                                                        "hasBeenDrawn": musicianData.hasBeenDrawn])
    }
    
    func configureMusicians()
    {
        ref.child("musicians").observeEventType(.Value, withBlock: {
            (snapshot) -> Void in
            var newArrayOfMusicians: [Musician] = []
            for item in snapshot.children
            {
                if let firebaseMusician = Musician.convertSnapshotToMusician(item as! FIRDataSnapshot)
                {
                    newArrayOfMusicians.append(firebaseMusician)
                   // print(firebaseMusician.name)
                    
                }
            }
            self.arrayOfMusicians = newArrayOfMusicians
            print(self.arrayOfMusicians)
            self.displayMusiciansFromDatabase()
           // self.reloadMusicians()
            
            //    self.tableview.insertRowsAtIndexPaths([NSIndexPath(forRow: self.arrayOfMessages.count-1, inSection: 0)], withRowAnimation: .Automatic)
            
        })
        

        
        
    }
    
    func displayMusiciansFromDatabase()
    {
        if hasBeenDisplayedOnce == false
        {
            for item in arrayOfMusicians
            {
                if item.hasBeenDrawn == false || item.doesExist == true
                {
                    let aButton = UIButton()
                    aButton.frame = CGRect(x: item.positionX, y: item.positionY, width: item.width + 10, height: item.height)
                    aButton.setImage(UIImage(named: item.iconImage), forState: .Normal)
                    aButton.setTitle(item.name, forState: .Normal)
                    aButton.addTarget(self, action: #selector(buttonPressed), forControlEvents: .TouchUpInside)
                    
                    aButton.tag = item.uniqueID
                    print(item.uniqueID)
                    self.view.addSubview(aButton)
                    let longPrssGesture = UILongPressGestureRecognizer()
                    aButton.addGestureRecognizer(longPrssGesture)
                    
//                    let dubTapGesture = UITapGestureRecognizer()
//                    dubTapGesture.numberOfTapsRequired = 2
//                    //  panGesture.delegate = self
//                    aButton.addGestureRecognizer(dubTapGesture)
                    
                    aButton.addTarget(self, action: #selector(buttonDragged), forControlEvents: .TouchDragInside)
                    aButton.addTarget(self, action: #selector(doubleTappedWasInitiated), forControlEvents: .TouchUpInside)
                    
                    let aLabel = UILabel()
                    aLabel.frame = CGRect(x: 0, y: -17, width: item.width, height: 15)
                    aLabel.text = item.name
                    aLabel.textColor = UIColor.blackColor()
                    aLabel.sizeToFit()
                    aButton.addSubview(aLabel)
                    item.hasBeenDrawn = true
                    print("\(arrayOfMusicians.count)")
                }
                
            }
            hasBeenDisplayedOnce = true
        }
        /*
        let testMusician = arrayOfMusicians[0]
        let tButton = UIButton()
        tButton.frame = CGRect(x: testMusician.positionX, y: testMusician.positionY, width: testMusician.width, height: testMusician.height)
        tButton.setImage(UIImage(named: testMusician.iconImage), forState: .Normal)
        tButton.setTitle(testMusician.name, forState: .Normal)
        self.view.addSubview(tButton)
        */
        
        
    }



    
    func configureDatabase()
    {
        ref = FIRDatabase.database().reference()
        
        // Listen for new messages from Firebase
        //  refHandle = ref.child(uniqueSessionID).observeEventType(.ChildAdded, withBlock: {
        
        
        ref.child("messages").observeEventType(.Value, withBlock: {
            (snapshot) -> Void in
            var newArrayOfMessages: [Message] = []
            for item in snapshot.children
            {
                if let firebaseMessage = Message.convertSnapshotToMessage(item as! FIRDataSnapshot)
                {
                    newArrayOfMessages.append(firebaseMessage)
                }
            }
            self.arrayOfMessages = newArrayOfMessages
            self.tableview.reloadData()
            self.messages.append(snapshot)
            
        //    self.tableview.insertRowsAtIndexPaths([NSIndexPath(forRow: self.arrayOfMessages.count-1, inSection: 0)], withRowAnimation: .Automatic)
            
        })
        
        
    }
    
    func musicianWasChosen(pickedMusician: Musician)
    {
        // dismiss(animated: true, completion: nil)
        arrayOfMusicians.append(pickedMusician)
        //tableView.reloadData()
    }
    
    func doubleTappedWasInitiated(aButton: UIButton)
    {
        if deleteIconsSwitch.on
        {
            for thisButton in arrayOfMusicians
            {
                if aButton.tag == thisButton.uniqueID
                {
                    aButton.removeFromSuperview()
                    thisButton.ref?.removeValue()
                }
            }

        }
        
    }

    
    
    
    
    
    
    func sendMessage(message: String?)
    {
        let completed: Bool = false
        let removeRequest: Bool = false
        if let msg = message
        {
            if msg.characters.count > 0
               
            {
                if let username = AppState.sharedInstance.displayName
                {
                    let messageData = Message(request: msg, name: username, completed: completed, removeRequest: removeRequest)
                   // let requestRef = self.ref.child("messages").childByAutoId()
                    
                    
                    ref.child("messages").childByAutoId().setValue(["request": msg, "name": username, "completed": completed, "removeRequest": removeRequest])
                    self.arrayOfMessages.append(messageData)
                    self.tableview.insertRowsAtIndexPaths([NSIndexPath(forRow: self.arrayOfMessages.count-1, inSection: 0)], withRowAnimation: .Automatic)
                    
                    //Push to Firebase Database
                    
                    // ref.child(uniqueSessionID).childByAutoId().setValue(messageData)
                   // ref.child("messages").childByAutoId().setValue(messageData)
                    chatTextField.text = ""
                }
            }
        }
    }

    
    // MARK: - Tableview required methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrayOfMessages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
        // Unpack message from Firebase DataSnapshot
        
        let thisRequest = self.arrayOfMessages[indexPath.row]
        
            
        cell.requestLabel.text = thisRequest.request
        
            if thisRequest.completed == true
            {
                cell.checkButton.setImage(checkImage, forState: .Normal)
            }
            else if thisRequest.completed == false
            {
                cell.checkButton.setImage(unCheckImage, forState: .Normal)
            }
        
        return cell
        
        
            
/*
            
            //cell.textLabel?.text = name + ": " + text
            cell.textLabel?.text = text as? String
            
            let fontSized = cell.textLabel?.text?.characters.count
            let tempSize  = CGFloat(40 - fontSized!)
            cell.textLabel?.font = UIFont(name: "Thonburi", size: tempSize)
            
            //            if completed as! Bool == false
            //            {
            //                cell.accessoryType = UITableViewCellAccessoryType.None
            //                cell.textLabel?.textColor = UIColor.blackColor()
            //                cell.detailTextLabel?.textColor = UIColor.blackColor()
            //            } else {
            //
            //                cell.accessoryView?.tintColor = UIColor.greenColor()
            //                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            //
            //                cell.textLabel?.textColor = UIColor.greenColor()
            //                cell.detailTextLabel?.textColor = UIColor.greenColor()
            //            }
 
        
        }
*/

        
        
    }
    

    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // 1
//        let cell = tableView.cellForRowAtIndexPath(indexPath)!
//        
//        var aRequest: Message
//     
//        let snapshotToUpdate = messages[indexPath.row]
//        
       // tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            let reqToDelete = arrayOfMessages[indexPath.row]
           // let refToDelete = messages[indexPath.row]
            reqToDelete.ref!.removeValue()
            
            //            let messageSnapshot = self.messages[indexPath.row]
            //            let message = messageSnapshot.value as! Dictionary<String, String>
            //            refToDelete.ref.updateChildValues(message)
            // messages.removeAtIndex(indexPath.row)
            // tableView.reloadData()
        }
        //   tableView.reloadData()
    }
    
    
   

    func toggleCellCheckbox(cell: UITableViewCell, isCompleted: Bool)
    {
        if !isCompleted {
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.detailTextLabel?.textColor = UIColor.blackColor()
        }
        else
        {
            
            cell.accessoryView?.tintColor = UIColor.greenColor()
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell.textLabel?.textColor = UIColor.greenColor()
            cell.detailTextLabel?.textColor = UIColor.greenColor()
        }
    }
    

    @IBAction func checkTapped(sender: UIButton)
    {
        //isChecked = !isChecked
        let contentView = sender.superview
        let cell = contentView?.superview as! MessageCell
        let thisIndexPath = tableview.indexPathForCell(cell)
        
        let myDone = arrayOfMessages[thisIndexPath!.row]
       // var aSnap = messages[thisIndexPath!.row]
        
       // let aRequest = Message()
        //let updateRequest = aRequest.convertSnapshotToMessage(aSnap)
        
        myDone.completed = !myDone.completed
        if myDone.completed == true
        {
            sender.setImage(checkImage, forState: .Normal)
        }
        else if myDone.completed == false
        {
            sender.setImage(unCheckImage, forState: .Normal)
        }
        let updatedMessage = ["completed": myDone.completed]
        myDone.ref?.updateChildValues(updatedMessage)
        
    }
    
    
    // MARK: - Textfield delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        
        sendMessage(textField.text)
        
        return false
    }
    
    
    
    @IBAction func signOut(sender: UIBarButtonItem)
    {
        do {
            try FIRAuth.auth()?.signOut()
            AppState.sharedInstance.signedIn = false
            print("Sign Out successfull")
            performSegueWithIdentifier("ModalLoginSegue", sender: self)
        } catch let signOutError as NSError
        {
            print("Error signing out: \(signOutError)")
        }
        
    }
    
    
    @IBAction func sendMessageTapped(sender: UIButton)
    {
        sendMessage(chatTextField.text)
        
    }
    
    
    @IBAction func hideTapped(sender: UIButton)
    {
       //self.tableview.alpha = 1   //.animateWithDuration(0.3, animations: .CurveEaseOut)
        requestsHidden = !requestsHidden
        if requestsHidden
        {
            unlockLabel.setTitle("Show Requests", forState: .Normal)
            unlockLabel.setTitleColor(UIColor.redColor(), forState: .Normal)
            tableviewWidthConstraint.constant = 0
            
            
        }
        else
        {
            unlockLabel.setTitle("Hide Requests", forState: .Normal)
            unlockLabel.setTitleColor(UIColor.blackColor(), forState: .Normal)
            tableviewWidthConstraint.constant = (view.bounds.width * 0.4)
        }
        //        if chatTextField.isFirstResponder()
        //        {
        //            chatTextField.resignFirstResponder()
        //        }
        
    }
    
    func keyboardDidShow(notification: NSNotification)
    {
        let height = notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue().height
        chattextFieldConstraint.constant = height! + 4
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        chattextFieldConstraint.constant = 8.0
    }
    
    
    @IBAction func iconPressed(sender: UITapGestureRecognizer)
    {
        let name = iconLabel.text
        setTextFromIcon(name!)
    }
    
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer)
    {
        // if canMoveIcons
        // {
        let translation = recognizer.translationInView(self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
        //  }
        
    }
    
    func setTextFromIcon(name: String)
    {
        chatTextField.text = chatTextField.text! + name
        
    }
    
//    func buttonPressed(sender: UIButton)
//    {
//        
//        chatTextField.text = chatTextField.text! + sender.currentTitle!
//        // print("piano?")
//        
//        
//        
//    }
    
    @IBAction func requestTapped(sender: UIButton)
    {
        chatTextField.text = chatTextField.text! + " " + sender.currentTitle!
        print("piano?")
        
    }
    //    func didSetSessionID(sessionIDFromLogin: String?)
    //    {
    //        if let sessIDFrmLog = sessionIDFromLogin
    //        {
    //            uniqueSessionID = sessIDFrmLog
    //        }
    //    }
    
    
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    //    func ignore(button: UIPress, for event: UIPressesEvent)
    //    {
    //        let myButton = UIPress.self
    //        var newPoint: CGPoint
    //        newPoint = myButton.center
    //
    //        newGuitarButton2.center = newPoint
    //
    //
    //    }
    
    func handleTap(recognizer: UITapGestureRecognizer)
    {
        let myButton = recognizer.view as! UIImageView
        //let myButton = recognizer.view as! UIButton
        var newPoint: CGPoint = (recognizer.view?.center)!
        newPoint = myButton.center
        
        //        newGuitarButton2.center = newPoint
        //
        //        newGuitarButton2.updateConstraints()
        //        newGuitarButton2.center = newPoint// center = newPoint
        //        newLabel2.text = myButton.currentTitle!
        //        let tempString = myButton.currentTitle!
        //        print(tempString)
        
//        let handRight = UIImage(named: "Hand Right-48.png")
//        let handView = UIImageView(image: handRight)
//        handView.frame = CGRect(x: newPoint.x, y: newPoint.y, width: 68, height: 68)
//        self.view.addSubview(handView)
        
        // newLabel2.text = tempString
        
//        myButton.frame = CGRect(x: 40, y: 40, width: 100, height: 100)
//        super.viewWillLayoutSubviews()
//        view.addSubview(myButton)
    }
    

}
    
    
        
//       if let updatedRequest = Message.convertSnapshotToMessage(aSnap)
//       {
//            updatedRequest.completed = !updatedRequest.completed
//            
//        
//            
//            if updatedRequest.completed == true
//            {
//                sender.setImage(checkImage, forState: .Normal)
//                
//            }
//            else if updatedRequest.completed == false
//            {
//                sender.setImage(unCheckImage, forState: .Normal)
//            }
//        
//            var updatedMessage = aSnap.value as! Dictionary<String, AnyObject>
//            let tempBool = updatedRequest.completed
//          
//            updatedMessage = ["completed": tempBool]
//            aSnap.ref.updateChildValues(updatedMessage)
//        }
        
//    }



    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
//    {
//        super.touchesBegan(touches, withEvent: event)
//        for touch in (touches as! Set<UITouch>)
//        {
//            let
//        }
//        let touch = touches.first
//      
//        start = touch!.locationInView(self.view)
//       
//        //location = touch.locationInView(self.view)
//    //    handLeftButton.center = start!
//        
//    }
//
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
//    {
//        super.touchesMoved(touches, withEvent: event)
//        let touch = touches.first
//        let end = touch!.locationInView(view)
//      //  if let start = self.start
//      //  {
//      //      handLeftButton.center = end
//      //  }
//      //  self.start = end
//       // elecGuitar.center = location
//        
//    }
//    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
//    {
//        super.touchesEnded(touches, withEvent: event)
//        let touch = touches.first
//        let end = touch!.locationInView(view)
//   //     newCenter = end
//   //     handLeftButton.center = newCenter!
//  //      print(newCenter)
//    }
    
//    func makeImage() -> UIImage
//    {
//        
//        
//        UIGraphicsBeginImageContext(self.piano.bounds.size)//  .bounds.size)
//        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
//        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return viewImage
//    }
    
    
    //      let imageToConvert = UIImage(named: "piano")
    //      let imageAsData = UIImagePNGRepresentation(imageToConvert!)
    
    // print("the piano data is: \(imageAsData!)")
    //myData = myImageData!
    
    //let myNewImage : UIImage = UIImage(data: imageAsData!)!
    
    //let aString: String = imageAsData.
    
    //        let textViewData : NSData = imageData.dataUsingEncodin(NSNonLossyASCIIStringEncoding)!
    //        let valueUniCode : String = String(data: textViewData, encoding: NSUTF8StringEncoding)!
    //        let emojData : NSData = valueUniCode.dataUsingEncoding(NSUTF8StringEncoding)!
    //        let emojString:String = String(data: emojData, encoding: NSNonLossyASCIIStringEncoding)!
    

    
    
    // MARK: - Firebase methods
    
    // When messages are added, run the withBlock
    
//    func getSessionIDFirst()
//    {
//        uniqueSessionID =
//    }
    
    
    
    
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        // 1
//        ref.observeEventType(.Value, withBlock: { snapshot in
//            
//            // 2
//            var newItems = [GroceryItem]()
//            
//            // 3
//            for item in snapshot.children {
//                
//                // 4
//                let groceryItem = GroceryItem(snapshot: item as! FDataSnapshot)
//                newItems.append(groceryItem)
//            }
//            
//            // 5
//            self.items = newItems
//            self.tableView.reloadData()
//        })
//    }
    
    
    
    

    
    
    
//}

//        /*refHandle =*/

//        ref.child("messages").observeEventType(.ChildRemoved, withBlock: {
//            (snapshot) -> Void in
//
//            var foundMessage: FIRDataSnapshot?
//            for aMessage in self.messages
//            {
//                if aMessage.key == snapshot.key
//                {
//                    foundMessage = aMessage
//                    print("found this snapshot")
//                    break
//                }
//
//            }
//
//            if let index = self.messages.indexOf(foundMessage!)
//            {
//                print("gonna remove it!!")
//                self.messages.removeAtIndex(index)
//                self.tableview.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
//                self.tableview.reloadData()
//            }
//
//
//        })

//        refHandle = ref.child("messages").observeEventType(.ChildChanged, withBlock: {
//            (snapshot) -> Void in
//
//            var foundMessage: FIRDataSnapshot?
//            for aMessage in self.messages
//            {
//                if aMessage.key == snapshot.key
//                {
//                    foundMessage = aMessage
//                    break
//                }
//
//            }
//
//            if let index = self.messages.indexOf(foundMessage!)
//            {
//                print("Make it green!!")
//                self.tableview.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
//                print("reload rows at index")
//
//
//
//                self.tableview.reloadData()
//            }
//
//
//            //            if let index = self.messages.indexOf(snapshot)
//            //            {
//            //                //self.messages.insert(snapshot, atIndex: index)
//            //                //self.messages.removeAtIndex(index + 1)
//            //                self.tableview.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
//            //                //   deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
//            //            }
//
//        })




//    }




