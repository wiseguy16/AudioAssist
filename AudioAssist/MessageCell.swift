//
//  MessageCell.swift
//  TwoCans2
//
//  Created by Gregory Weiss on 9/21/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell
{
    
    @IBOutlet weak var requestLabel: UILabel!
    
    @IBOutlet weak var checkButton: UIButton!
    

    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
