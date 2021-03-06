//
//  ToShopTableViewController.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 20/11/2018.
//  Copyright © 2018 Slawomir Kurczewski. All rights reserved.
//

import UIKit

class ToShopTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
    var keyboarActive = false
    
    @IBOutlet var tabView: UITableView!
    @IBOutlet var searchedBar: UISearchBar!
    var currentCheckList = 0
    let card = ProductList(pictureName: "zakupy.jpg")

    override func viewDidLoad() {
        super.viewDidLoad()
        database.loadData(tableNameType: .toShop)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        let longTap:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(goToNextViwecontroller))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(longTap)
        
        
        registerSettingBundle()
        NotificationCenter.default.addObserver(self, selector: #selector(ToShopTableViewController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
     @objc func hideKeyboard() {
        print("keyboarActive \(keyboarActive), view.isFocused \(view.isFocused),isFirstResponder \(view.isFirstResponder) ")
        view.endEditing(true)
    }
    @objc func goToNextViwecontroller() {
        print("goToNextViwecontroller")
    }
    func registerSettingBundle() {
        let appDefaults = [String : AnyObject]()
        UserDefaults.standard.register(defaults:appDefaults)
    }
    @objc func defaultsChanged() {
        if UserDefaults.standard.bool(forKey: "red_theme_key") {
            self.view.backgroundColor = .red 
            print("RedThemeKey")
        }
        else {
            self.view.backgroundColor = .white
            print("whiteThemaKey")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        let numList=Setup.currentListNumber+1
        database.loadData(tableNameType: .toShop)
        database.category.crateCategoryGroups(forToShopProduct: database.toShopProduct.array)
        self.title=cards[0].getName()+" \(numList)"
        //database.category.createSectionsData()
        tabView.reloadData()
        print("viewWillAppear")
    }
    @IBAction func addNewListToBay(_ sender: UIBarButtonItem) {
        
    }
    @IBAction func changeList(_ sender: UIBarButtonItem) {
        
    }    
    // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return database.category.sectionsData.count
     }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return   database.category.getCurrentSectionCount(forSection: section)
    }
    func getToShopProduct(indexPath: IndexPath) -> ProductTable?  {
        let prodNumber=database.category.sectionsData[indexPath.section].objects[indexPath.row]
        let  xxx = prodNumber < database.toShopProduct.count ? prodNumber : database.toShopProduct.count-1
        let toShopProduct = database.toShopProduct[xxx].productRelation
        return toShopProduct
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as! ToShopTableViewCell
        let toShop=getToShopProduct(indexPath: indexPath)
        if toShop != nil {
            cell.producentLabel.text = toShop?.producent
            cell.productNameLabel.text = toShop?.productName
            cell.accessoryType = .detailButton
            let grams="\(toShop?.weight ?? 0)g"
            cell.detailLabel.text = grams.count==2 ? "" : grams
            if let img=toShop?.fullPicture {
                cell.picture.image = UIImage(data: img)
            }
            else {
                cell.picture.image = UIImage(named: "question-mark")
            }
        }
        else {
            cell.producentLabel.text="Brak produktu"
            cell.picture.image=nil
        }
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label=UILabel()
        let sectionName = database.category.getCategorySectionHeader(forSection: section)
        let secCount = database.category.sectionsData[section].objects.count
        label.text="\(sectionName)"
        label.textAlignment = .center
        
        label.backgroundColor = ((secCount == 0) ? UIColor.white : UIColor.lightGray)
        label.textColor = ((secCount == 0) ? UIColor.white : UIColor.black)
        return label
    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let checkAction=UITableViewRowAction(style: .default, title: "🛍\nKup") { (action, indexPath) in
//        }
//        let uncheckAction=UITableViewRowAction(style: .default, title: "🗑\nZwróć") { (action, indexPath) in
//        }
//        checkAction.backgroundColor=UIColor.green
//        uncheckAction.backgroundColor=UIColor.red
//        return [checkAction,uncheckAction]
//    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            let prodNumber=database.category.sectionsData[indexPath.section].objects[indexPath.row]
            database.category.deleteElement(forIndexpath: indexPath)
            database.uncheckOne(withToShopRec: prodNumber)
            database.deleteOne(withToShopRec: prodNumber)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt")
        //tap.cancelsTouchesInView = true
        if !keyboarActive {
            print("GO TO ...")
        }
        else {
            print("No to GO ...")
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    
    // Override to support rearranging the table view.
    //     func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    //    }
    


    // Override to support conditional rearranging of the table view.
    //     func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
    //        return true
    //    }
 

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
 // Serach bar delegate
    //searchBarTextDidBeginEditin
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //database.filterData(searchText: searchBar.text!, searchTable: .products, searchField: (self.selectedSegmentIndex==0 ? .Product : .Producent))
        DispatchQueue.main.async {
            self.searchedBar.resignFirstResponder()
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //database.filterData(searchText: searchBar.text!, searchTable: .products, searchField: (self.selectedSegmentIndex==0 ? .Product : .Producent))
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        keyboarActive = true
    }
//    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
//        keyboarActive = false
//        print("searchBarShouldEndEditing \(keyboarActive)")
//        return true
//    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        keyboarActive = false
        view.endEditing(true)
        //view.resignFirstResponder()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
