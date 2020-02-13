//
//  AddedContactTableViewCell.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 20/01/2020.
//  Copyright © 2020 Slawomir Kurczewski. All rights reserved.
//

import UIKit

class AddedContactTableView: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var contactList: [Setup.SelectedContact] = []
    // let xxx=database.favoriteContacts.array
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editModeButtonOutlet: UIBarButtonItem!
    
    @IBAction func editModeBarButton(_ sender: UIBarButtonItem) {
        var ikonName: String = ""
        let statusOn = self.tableView.isEditing
        self.tableView.isEditing = !statusOn
        ikonName = statusOn ? "unlock" : "lock"
        let image = UIImage(named: ikonName)
        navigationItem.rightBarButtonItem?.image = image
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //database.delTable(dbTableName: .favoriteContacts)
        //database.favoriteContacts.deleteAll()
        self.tableView.isEditing = true
        
        print("-----------")
        for (tmpKey, tmpContact) in Setup.preferedContacts {
            print("KKKKey name:\(tmpKey): \(tmpContact.name) \(tmpContact.phone) \(tmpContact.email)")
            self.contactList.append(tmpContact)
        }
    }
    func savePreferedContacts() {
        for tmpContact in contactList {
            saveOneContact(forContact: tmpContact)
        }
    }
    func saveOneContact(forContact contact: Setup.SelectedContact) {
        let oneRecord: FavoriteContactsTable = FavoriteContactsTable(context: database.context)
        oneRecord.key   = contact.key
        oneRecord.name  = contact.name
        oneRecord.phone = contact.phone
        oneRecord.email = contact.email
        oneRecord.image = contact.image?.pngData()
        _ = database.favoriteContacts.add(value: oneRecord)
        print("Saved contact")
        print("key:\(oneRecord.key),name:\(oneRecord.name),\(oneRecord.phone),\(oneRecord.email)")
        database.save()
    }
    // Deleate UITableViewDelegate and UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell=UITableViewCell()
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as! AddedContactTableViewCell
        let tmpContact = contactList[indexPath.row]
        cell.contactNameLabel.text = tmpContact.name
        cell.contactPhoneNumberLabel.text = tmpContact.phone
        cell.eMailLabel.text = tmpContact.email

        if let pict = tmpContact.image  {
            cell.contactImage.image = pict
            cell.contactImage.alpha = 1.0
            cell.contactImage.layer.cornerRadius=cell.contactImage.frame.size.width/2.0
            cell.contactImage.layer.masksToBounds = true
        }
        else {
            cell.contactImage.image = UIImage(named: "user_male_full")
            cell.contactImage.alpha = 0.2
        }
        return cell
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let objectToMove = contactList[sourceIndexPath.row]
        contactList.remove(at: sourceIndexPath.row)
        contactList.insert(objectToMove, at: destinationIndexPath.row)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.backgroundColor = .green
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    deinit {
        savePreferedContacts()
    }

    //    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    //        let movedObject = self.headlines[sourceIndexPath.row]
    //        headlines.remove(at: sourceIndexPath.row)
    //        headlines.insert(movedObject, at: destinationIndexPath.row)
    //    }

    //    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
}
