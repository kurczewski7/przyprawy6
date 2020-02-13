//
//  FavoriteViewViewController.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 16/01/2020.
//  Copyright © 2020 Slawomir Kurczewski. All rights reserved.
//

import UIKit
import Contacts

class FavoriteContactViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var contacts: [CNContact] = []
    var store = CNContactStore()

    
    
//    struct FavoriteContact {
//        let name: String = "Name"
//    }
    var contactStore = CNContactStore()
    //var contacts = [ContactEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database.loadData(tableNameType: .favoriteContacts)
        loadPreferedContacts()
        getContacts()
    }
    func loadPreferedContacts() {
        for i in 0..<database.favoriteContacts.count {
            loadOneRecord(forNumberRecord: i)
        }
    }
    func loadOneRecord(forNumberRecord num: Int) {
        if num < database.favoriteContacts.count {
            let rec = database.favoriteContacts[num]
            if let key = rec.key {
                let name    = rec.name  ?? "No name"
                let email   = rec.email ?? "No email"
                let phone   = rec.phone ?? "No phone"
                var myContact = Setup.SelectedContact(key: key, name:  name, email: email, phone: phone)
                if let picture = rec.image {
                    myContact.image = UIImage(data: picture)
                }
                else {
                    myContact.image = nil
                }
               
                Setup.preferedContacts.updateValue(myContact, forKey: key)
            }
        }
    }
//        let oneRecord: FavoriteContactsTable = FavoriteContactsTable(context: database.context)
//         for tmpContact in contactList {
//             oneRecord.key   = tmpContact.key
//             oneRecord.name  = tmpContact.name
//             oneRecord.phone = tmpContact.phone
//             oneRecord.email = tmpContact.email
//             oneRecord.image = tmpContact.image?.pngData()
//             database.favoriteContacts.add(value: oneRecord)
//             database.save()
//         }

  //      let myCont1 = Setup.SelectedContact(name: "AAA", email: "bbb", phone: "78788")
  //      let myCont2=Setup.SelectedContact(name: "CCC", email: "ddd", phone: "1234")
  //      Setup.preferedContacts.updateValue(myCont1, forKey: "410FE041-5C4E-48DA-B4DE-04C15EA3DBAC")
  //      Setup.preferedContacts.updateValue(myCont2, forKey: "2E73EE73-C03F-4D5F-B1E8-44E85A70F170")

    func savePreferedContacts() {
        // TODO: savePreferedContacts
//        let cont: CNContact = contacts[0] as CNContact
//        let oneContact = FavoriteContactsTable()
//        oneContact.email = contacts[0].
//
//        let table=database.favoriteContacts[0].email
        print("PREFERED CONTACT SAVED")
    }
    @available (iOS 9.0, *)
    func getContacts() {
        isAccesToContact { (success) in
            self.retriveContacts()
        }
        
        //let  store = CNContactStore()
        //let predicate: NSPredicate = CNContact.predicateForContacts(matchingName: "ku")
        
        //let xxx  = try store.unifiedContactsMatchingPredicate(CNContact.predicateForContactsMatchingName("ku"),
        //                                                                    keysToFetch:[CNContactGivenNameKey, CNContactFamilyNameKey])
        //let yyy = xxx.CNContact[0]
        
    }
    func isAccesToContact(_ completion: @escaping (_ success: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        switch authorizationStatus {
        case .authorized:
            completion(true)
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: .contacts) { (accessGranted, error) in
                completion(accessGranted)
            }
        default:
                completion(false)
         }
    }
    func retriveContacts() {
        let keys  = [CNContactGivenNameKey, CNContactFamilyNameKey,CNContactPhoneNumbersKey,CNContactImageDataKey,CNContactEmailAddressesKey]
//        let predicate = CNContact.predicateForContacts(matchingName: "krzysiu")
//        contacts = try  store.unifiedContacts(matching: predicate, keysToFetch: keys as! [CNKeyDescriptor])
//        catch do {
//            print("Error in store predicate")
//        }


        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        do {
            try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                print("Osoba:")
                print(contact.givenName)
                print(contact.familyName)
                print(contact.phoneNumbers.first?.value.stringValue ?? "brak tel")
                self.contacts.append(contact)
            })
           // let names = ExpandableNames()
        } catch let err {
                print("Failed to enumerate contacts", err)
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    func fullNameContact(forContact cont: CNContact)  -> String{
        return "\(cont.familyName) \(cont.givenName)"
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let pictureOfUser: UIImage?
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as! FavoriteContactTableViewCell
        let cont: CNContact = contacts[indexPath.row] as CNContact
    
        let phoneNumber = cont.phoneNumbers.first?.value.stringValue ?? "brak tel"
        cell.contactPhoneNumberLabel.text = phoneNumber
        cell.contactNameLabel.text = fullNameContact(forContact: cont)
       
        cell.contactImage.image = UIImage(named: "user_male_full")
        cell.contactImage.layer.cornerRadius=cell.contactImage.frame.size.width/2.0
        cell.contactImage.layer.masksToBounds = true
        cell.userKey = cont.identifier
        
        if let pict = cont.imageData  {
            cell.contactImage.image = UIImage(data: pict)
            cell.contactImage.alpha = 1.0
            cell.isUserPicture = true
        }
        else {
            cell.contactImage.image = UIImage(named: "user_male_full")
            cell.contactImage.alpha = 0.2
            cell.isUserPicture = false
        }
        
        if let email = cont.emailAddresses.first {
            let emailValue = String(email.value)
            cell.eMailLabel.text = emailValue
        }
        else {
           cell.eMailLabel.text = "brak email"
        }
        if Setup.currentContactKey?.count == 0 {
            cell.iLikeButton.tintColor = .red
        }
        else
        {
            if let temp = Setup.preferedContacts[cont.identifier]  {
                print("OK temp.name:\(temp.name)")
                 cell.iLikeButton.tintColor = .green
            }
            else {
                cell.iLikeButton.tintColor = .red
            }
        }
        return cell
    }
    



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    deinit {
        savePreferedContacts()
    }

}
