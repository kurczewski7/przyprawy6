//
//  AddedContactTableViewCell.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 20/01/2020.
//  Copyright © 2020 Slawomir Kurczewski. All rights reserved.
//

import UIKit

class AddedContactTableViewCell: UITableViewCell {
    @IBOutlet weak var contactImage: UIImageView!
    
    @IBOutlet weak var contactNameLabel: UILabel!
    
    @IBOutlet weak var contactPhoneNumberLabel: UILabel!
    
    @IBOutlet weak var eMailLabel: UILabel!
    
    
    @IBOutlet weak var iLikeButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
