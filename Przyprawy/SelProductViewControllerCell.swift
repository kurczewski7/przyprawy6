//
//  SelProductViewControllerCell.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 12/08/2019.
//  Copyright © 2019 Slawomir Kurczewski. All rights reserved.
//

import UIKit

class SelProductViewControllerCell: UITableViewCell, ProductProtocol {
    // perform protocol
    @IBOutlet var producentLabel: UILabel!
    @IBOutlet var productLabel: UILabel!
    @IBOutlet var picture: UIImageView!
    // non protocol
    @IBOutlet var detaliLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
