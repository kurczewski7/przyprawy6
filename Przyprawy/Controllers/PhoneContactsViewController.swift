//
//  PhoneContactsViewController.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 28.08.2018.
//  Copyright © 2018 Slawomir Kurczewski. All rights reserved.
//

import UIKit
import Contacts


class PhoneContactsViewController: UIViewController, UITabBarDelegate, UITableViewDataSource {
    
    //var store:CNContactStore?
    var phoneNumbers = [CNContact]()
    var isPicture=true
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //store=CNContactStore()
        //readContacts(from : store!)
        getContacts()
        print("bbbbbbb")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: TableView method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var picture: UIImage?
        let phone = phoneNumbers[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text="\(phoneNumbers[indexPath.row].givenName )"
        cell.detailTextLabel?.text="\(phone.familyName )"
        cell.detailTextLabel?.text="\(phone.phoneNumbers[0].value.stringValue) )"
       
//if
//        let xxx = phone.imageDataAvailable
//        if let pict = phoneNumbers[indexPath.row].imageData
//
//        }
//        else
//        {
//
//        }
        //
        if isPicture
        {
           let pict = phone.imageData
           print("AAAAAAA")
            isPicture = !isPicture
            picture = UIImage(data: pict!)
        }
        else
        {
            print("BBBBBB")
            picture = UIImage(named: "user-male-icon")
        }
        
        
//        if phone.imageDataAvailable {  picture = UIImage(data: phone.imageData!) }
//        else                        {  picture = UIImage(named: "user-male-icon") }
        
        cell.imageView?.image = picture
       
        // Configure the cell...
        
        return cell
    }

    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return phoneNumbers.count
    }
    func getContacts()
    {
        let store=CNContactStore()
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .authorized
        {
            self.readContacts(from : store)
        }
        else if status == .notDetermined
        {
            store.requestAccess(for: .contacts
            , completionHandler: { (autorized, error) in
                if(autorized)
                {
                    self.readContacts(from : store)
                }
           })
        }
    }
    //        let store = CNContactStore()
//        let contacts = try store.unifiedContactsMatchingPredicate(CNContact.predicateForContactsMatchingName("Appleseed"), keysToFetch:[CNContactGivenNameKey, CNContactFamilyNameKey])
//
    

    func readContacts(from store : CNContactStore) {
        do {
            // let groups = try store.groups(matching: nil)
            let predicate=CNContact.predicateForContacts(matchingName: "krzysiu")
            //let predicate = CNContact.predicateForContacts(withIdentifiers: [groups[0].identifier])
            let keyToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey]
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keyToFetch as [CNKeyDescriptor])
            print("Kontakrt zawieraja:\(contacts.count)")
            for contact in contacts
            {
                print("1.\(contact.familyName)")
                print("2.\(contact.givenName)")
                print("3.\(contact.phoneNumbers[0].value.stringValue)")
            }

            self.phoneNumbers=contacts
            print("aaaaaa")
            //self.tableView.reloadData()
        }
        catch {
            print("Nastapil: \(error)")
        }
       print("ooooooooo")
    }
}
