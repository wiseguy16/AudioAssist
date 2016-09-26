//
//  ConfigOptionsCell.swift
//  TwoCans2
//
//  Created by Gregory Weiss on 9/24/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit

class ConfigOptionsCell: UITableViewCell
{
    
    @IBOutlet weak var musicianImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var positionXTextField: UITextField!
    @IBOutlet weak var positionYTextField: UITextField!
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
