//
//  FavoriteContactTableViewCell.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 17/01/2020.
//  Copyright © 2020 Slawomir Kurczewski. All rights reserved.
//

import UIKit

class FavoriteContactTableViewCell: UITableViewCell {
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactPhoneNumberLabel: UILabel!
    @IBOutlet weak var eMailLabel: UILabel!
    @IBOutlet weak var iLikeButton: UIButton!
    
    var userKey: String?
    var isUserPicture: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
//    func findExistElement(forKey key: String) -> Int {
//        let row = database.favoriteContacts.findValue(procedureToCheck: { (contact)  in
//            if let tmpKey = contact?.key {
//                return tmpKey == key
//            } else
//            {
//               return false
//            }
//        })
//        return row
//    }
    @IBAction func iLikeTap(_ sender: UIButton) {
        if sender.tintColor == .red {
            sender.tintColor = .green
            let name  = contactNameLabel.text ?? ""
            let email = eMailLabel.text ?? ""
            let pfone = contactPhoneNumberLabel.text ?? ""
            if let key = userKey {
                var newVal =  Setup.SelectedContact(key: key, name: name, email: email, phone: pfone)
                newVal.image = isUserPicture ? contactImage.image : nil
                Setup.preferedContacts.updateValue(newVal, forKey: key)
                if  database.favoriteContacts.findExistElement(forKey: key) < 0 {
                    let contactRec = FavoriteContactsTable(context: database.context)
                    contactRec.key   = key
                    contactRec.name  = name
                    contactRec.email = email
                    contactRec.phone = pfone
                    contactRec.image = newVal.image?.pngData()
                    _ = database.favoriteContacts.add(value: contactRec)
                    database.save()
                }
            }
        }
        else {
            sender.tintColor = .red
            if let key = userKey {
                Setup.preferedContacts.removeValue(forKey: key)
                let numberToDel = database.favoriteContacts.findExistElement(forKey: key)
                if  numberToDel > -1 {
                    _ = database.favoriteContacts.remove(at: numberToDel)
                    database.save()
                }
            }
        }
    }

//    get {
//        let centerX = origin.x + (size.width / 2)
//        let centerY = origin.y + (size.height / 2)
//        return Point(x: centerX, y: centerY)
//    }
//    set(newCenter) {
//        origin.x = newCenter.x - (size.width / 2)
//        origin.y = newCenter.y - (size.height / 2)
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
