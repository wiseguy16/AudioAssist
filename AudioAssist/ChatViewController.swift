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
    func musicianWasChosen(pickedMusicians: [Musician])
}

class ChatViewController: UIViewController, PickMusicianDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate //, LoginViewControllerDelegate
{
    
    @IBOutlet weak var incomingNoteImage: UIImageView!
    @IBOutlet weak var flagOutlet: UIButton!
    
    
    var arrayOfMusicians: [Musician] = []
    var hasBeenDisplayedOnce = false
    
    @IBOutlet weak var stageBackground: UIImageView!
     var start: CGPoint?
    var newCenter: CGPoint?
    
    @IBOutlet weak var backgroundForMovableIcons: UIView!
    @IBOutlet weak var coverUpPortraitView: UIView!
    
    @IBOutlet weak var deleteIconsSwitch: UISwitch!
    @IBOutlet weak var deleteLabel: UILabel!
    
    @IBOutlet weak var coverUpLandscapeView: UIView!
    
    
    @IBOutlet weak var lockLabel: UILabel!
    @IBOutlet weak var lockSwitch: UISwitch!
    
    
    @IBOutlet weak var chatTextField: UITextField!
    
    @IBOutlet weak var unlockLabel: UIButton!
    
    @IBOutlet weak var newLabel2: UILabel!
    
    
    
     @IBOutlet weak var singleTapRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var iconLabel: UILabel!
    
    var canMoveIcons = false
    var toggledCompletion = false
    var requestsHidden = true
    var isChecked = false
    var ref: FIRDatabaseReference!
    var refHandle: FIRDatabaseHandle!
    var messages = Array<FIRDataSnapshot>()
    var arrayOfMessages: [Message] = []
    var messageRefHandles = Array<FIRDatabaseHandle>()
    
    
    enum UIUserInterfaceIdiom : Int {
        case Unspecified
        case Phone // iPhone and iPod touch style UI
        case Pad // iPad style UI
    }

    
    
   
   
    
    @IBOutlet weak var chattextFieldConstraint: NSLayoutConstraint!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configureDatabase()
        
        configureMusicians()
        
       // checkDevice()
        
        
        
      //  NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
      //  NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if self.checkDevice() == true
        {
        reloadMusicians()
        }
        
    }
    
    
    
    
  
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        //checkDevice()
//        if !AppState.sharedInstance.signedIn
//        {
//            performSegueWithIdentifier("ModalLoginSegue", sender: self)
//        }
        
        
        
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func checkDevice() -> Bool
    {
        switch UIDevice.currentDevice().userInterfaceIdiom
        {
        case .Phone:
                        view.bringSubviewToFront(coverUpPortraitView)
                        view.bringSubviewToFront(coverUpLandscapeView)
                        return false
        // It's an iPhone
            
        case .Pad:
                        return true
        // It's an iPad
            
        case .Unspecified:
                            return false
            
        // Uh, oh! What could it be?
        default:
                        return false
        }
    }
    
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
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
                
                
                let aLabel = makeLabel(item)
                
                aButton.addSubview(aLabel)
                
                
                item.doesExist = true
                sendMusicianToFirebase(item)
                print("\(arrayOfMusicians.count)")
            }
        }
    }
    
    func makeLabel(aMusician: Musician) -> UILabel
    {
        let aLabel = UILabel()
        aLabel.frame = CGRect(x: 0, y: -17, width: aMusician.width, height: 15)
        aLabel.text = aMusician.name
        aLabel.textColor = UIColor.whiteColor()
        aLabel.font = UIFont(name: "Helvetica Neue", size: 14)
        aLabel.sizeToFit()
        
        return aLabel
    }
    
    func refreshPositions()
    {
        
        let filteredSubviews = self.view.subviews.filter({
            $0.isKindOfClass(UIButton) })
              for view in filteredSubviews  {
            if view.tag > 2
            {
              view.removeFromSuperview()
            }
            
        }
        for item in arrayOfMusicians
            {
                
                
    //            if item.doesExist == false
    //            {
                    let tempID = item.uniqueID
                
                    let aButton = UIButton()
                    aButton.frame = CGRect(x: item.positionX, y: item.positionY, width: item.width + 10, height: item.height)
                    aButton.setImage(UIImage(named: item.iconImage), forState: .Normal)
                    aButton.setTitle(item.name, forState: .Normal)
                    aButton.addTarget(self, action: #selector(buttonPressed), forControlEvents: .TouchUpInside)
                    
                    aButton.tag = tempID
                    self.view.addSubview(aButton)
                    let longPrssGesture = UILongPressGestureRecognizer()
                    aButton.addGestureRecognizer(longPrssGesture)
                    aButton.addTarget(self, action: #selector(buttonDragged), forControlEvents: .TouchDragInside)
                    
                    let dubTapGesture = UITapGestureRecognizer()
                    dubTapGesture.numberOfTapsRequired = 2
                    aButton.addGestureRecognizer(dubTapGesture)
                    aButton.addTarget(self, action: #selector(doubleTappedWasInitiated), forControlEvents: .TouchUpInside)
                    
                    
                    let aLabel = makeLabel(item)

                    aButton.addSubview(aLabel)
                
                
                   // item.doesExist = true
                   // sendMusicianToFirebase(item)
                  //  print("\(arrayOfMusicians.count)")
                //}
            }
    }

    
    @IBAction func deleteSwitch(sender: UISwitch)
    {
        
        if deleteIconsSwitch.on
        {
            deleteLabel.text = "Delete is ON"
            backgroundForMovableIcons.backgroundColor = UIColor.redColor()
            backgroundForMovableIcons.alpha = 0.15
        }
        else if !deleteIconsSwitch.on
        {
            deleteLabel.text = "Delete Icons"
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
            lockLabel.text = "Move Icons!!"
            backgroundForMovableIcons.backgroundColor = UIColor.greenColor()
            backgroundForMovableIcons.alpha = 0.1
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
        }
        
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ConfigureSegue"
        {
            let navVC = segue.destinationViewController as! UINavigationController
            let pickVC = navVC.viewControllers[0] as! LayoutConfigTableViewController
            pickVC.delegate = self
        }
        else if segue.identifier == "popoverSegue"
        {
            let popoverViewController = segue.destinationViewController as! PopoverViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
        }

        
    }
    
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "popoverSegue" {
//            let popoverViewController = segue.destinationViewController as! ChatViewController
//            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
//            popoverViewController.popoverPresentationController!.delegate = self
//        }
//    }

    
    
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
           // print("line 383")
            if self.checkDevice() == true
            {
            self.displayMusiciansFromDatabase()
            }
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
                    self.view.addSubview(aButton)
                    let longPrssGesture = UILongPressGestureRecognizer()
                    aButton.addGestureRecognizer(longPrssGesture)
                    
//                    let dubTapGesture = UITapGestureRecognizer()
//                    dubTapGesture.numberOfTapsRequired = 2
//                    //  panGesture.delegate = self
//                    aButton.addGestureRecognizer(dubTapGesture)
                    
                    aButton.addTarget(self, action: #selector(buttonDragged), forControlEvents: .TouchDragInside)
                    aButton.addTarget(self, action: #selector(doubleTappedWasInitiated), forControlEvents: .TouchUpInside)
                    
                    let aLabel = makeLabel(item)
                    
                    aButton.addSubview(aLabel)
                    
                    item.hasBeenDrawn = true
                    print("\(arrayOfMusicians.count)")
                }
                
            }
            hasBeenDisplayedOnce = true
        }
        
    }



    
    func configureDatabase()
    {
        ref = FIRDatabase.database().reference()
        
        // Listen for new messages from Firebase
        
        ref.child("messages").observeEventType(.Value, withBlock: {
            (snapshot) -> Void in
            var newArrayOfMessages: [Message] = []
            for item in snapshot.children
            {
                if let firebaseMessage = Message.convertSnapshotToMessage(item as! FIRDataSnapshot)
                {
                    newArrayOfMessages.append(firebaseMessage)
                    self.checkForNotes(firebaseMessage)
                }
            }
            self.arrayOfMessages = newArrayOfMessages
           // self.messages.append(snapshot)
            
        })
        
    }
    
    func checkForNotes(request: Message)
    {
        let wordArray = request.request.componentsSeparatedByString(" ")
        
        if wordArray.contains("note") || wordArray.contains("Note")
        {
            flagOutlet.alpha = 1
            flagOutlet.enabled = true
          //  incomingNoteImage.alpha = 1
            // turn on Mail light
        }
        else
        {
            flagOutlet.alpha = 0
            flagOutlet.enabled = false
          //  incomingNoteImage.alpha = 0
        }
        
    }

    
    
    func musicianWasChosen(pickedMusicians: [Musician])
    {
        // dismiss(animated: true, completion: nil)
        arrayOfMusicians.appendContentsOf(pickedMusicians)
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
                    //Push to Firebase Database
                    
                    chatTextField.text = ""
                }
            }
        }
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
           //This is the REFRESH ICONS Button action
           refreshPositions()
            
    }
    
    // MARK: textfield helper methods
    
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
    
    
    @IBAction func requestTapped(sender: UIButton)
    {
        chatTextField.text = chatTextField.text! + " " + sender.currentTitle!
    
        
    }
    
    
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    

}
    
    



