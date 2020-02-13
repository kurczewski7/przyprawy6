//
//  InBasketViewController.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 18/01/2019.
//  Copyright © 2019 Slawomir Kurczewski. All rights reserved.
//

import UIKit
import CoreData

class InBasketViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    enum SectionType: Int {
        case ToBuy = 0
        case AlreadyBought = 1
    }
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let context = database.context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToShopProductTable")
        let sort1 = NSSortDescriptor(key: "checked", ascending: true)
        //let sort2=NSSortDescriptor(key: "productName", ascending: true)
        fetchRequest.sortDescriptors = [sort1]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: "checked", //"changeDate", checked
                                                              cacheName: "SectionCache")
        fetchedResultsController.delegate =  self
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            
        }
    }
    override func  viewWillAppear(_ animated: Bool) {
        print("Odświeżenie")
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        self.tableView?.reloadData()
        super.viewWillAppear(animated)
    }
    func numberOfSectionsInTableView
        (tableView: UITableView) -> Int {
        let sectionInfo =  fetchedResultsController.sections![0]
        
        print("======== numberOfSectionsInTableView:")
        print("ind: \(sectionInfo.indexTitle ?? "brak")")
        print("name: \(sectionInfo.name)")
        print("obj: \(sectionInfo.numberOfObjects)")
        print("count: \(sectionInfo.objects?.count ?? -1)")

        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        let sectionInfo =
            fetchedResultsController.sections![section]
        
        return sectionInfo.name
    }
    func tableView(tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
       // let sectionInfo = fetchedResultsController.sections![section]
//            print("numb: \(sectionInfo.numberOfObjects)")
//            print("index: \(sectionInfo.indexTitle)")
//            print("name: \(sectionInfo.name)")
//            print("count: \(sectionInfo.objects?.count)")
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0  //  sections?[section].count  ?? 0  //sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        let sectionCount = fetchedResultsController.sections?.count
        return sectionCount ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InBasketTableViewCell
        let dlugosc = database.product.count
        print("dlugosc \(dlugosc) indexPath.row \(indexPath.row)")
        if let obj=fetchedResultsController.object(at: indexPath) as? ToShopProductTable {
            configureCell(cell: cell, withEntity: obj, at: indexPath)
        }
        return cell
    }
    func configureCell(cell: InBasketTableViewCell, withEntity toShopproduct: ToShopProductTable, at indexPath: IndexPath) {
        //row: Int, section: Int
        let row = indexPath.row
        let section = indexPath.section
        print("aaa\(row),\(section)")
        if let product = toShopproduct.productRelation {
            cell.detailLabel.text = ""
            cell.producentLabel.text = product.producent//"aaa\(row),\(section)"
            //cell.productNameLabel.text="cobj"
            cell.productNameLabel.text = product.productName
            cell.picture.image=UIImage(named: product.pictureName ?? "cameraCanon")
            cell.accessoryType = (toShopproduct.checked ? .checkmark : .none)
        }
        else
        {
            cell.accessoryType = (toShopproduct.checked ? .checkmark : .none)
            cell.detailLabel.text="No product"
        }
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("Move ...items: Any..")
    }
    func saveDataAndReloadView() {
        do {
            try fetchedResultsController.managedObjectContext.save()
        }
        catch  {  print("Error saveing context \(error)")   }
        // tableView?.reloadData()
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Usuń z listy") { (lastAction, view, completionHandler) in
            print("Usuń z listy")
            let toShopProduct = self.fetchedResultsController.object(at: indexPath) as! ToShopProductTable
            if let product = toShopProduct.productRelation {
                database.toShopProduct.checkProduct(forProduct: product, at: indexPath, isSelected: false)
            }                        
            self.fetchedResultsController.managedObjectContext.delete(toShopProduct)
            self.saveDataAndReloadView()
            
//            if let obj=fetchedResultsController.object(at: indexPath) as? ToShopProductTable {
//                configureCell(cell: cell, withEntity: obj, at: indexPath)
//            }
            
            
//            toShopProduct.checked = true
//            database.toShopProduct.toShopProductArray.remove(at: indexPath.row)
//            database.save()
          //  self.tableView?.reloadData()
            completionHandler(true)
        }
        action.backgroundColor = .red
        action.image=UIImage(named: "full_trash_big")
        let swipe = UISwipeActionsConfiguration(actions: [action])
        return swipe
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let sectionType = getSectionType(at: indexPath)
        let buyMessage = Setup.polishLanguage ? "Kup" : "Buy"
        let action1 = UIContextualAction(style: .destructive, title: buyMessage) { (act, view, completionHandler) in
            print("Kup")
            let toShopProduct = self.fetchedResultsController.object(at: indexPath) as! ToShopProductTable
            toShopProduct.checked = true
            self.saveDataAndReloadView()
            completionHandler(true)
        }
        action1.backgroundColor =  #colorLiteral(red: 0.09233232588, green: 0.5611743331, blue: 0.3208354712, alpha: 1)
        action1.image =  UIImage(named: "buy_filled_big2")
        let returnMessage = Setup.polishLanguage ? "Zwróć" : "Give back"
        let action2 = UIContextualAction(style: .destructive, title: returnMessage) { (act, view, completionHandler) in
            print("Zwróć")
            let toShopProduct = self.fetchedResultsController.object(at: indexPath) as! ToShopProductTable
            toShopProduct.checked = false
            self.saveDataAndReloadView()
            completionHandler(true)
        }
        action2.backgroundColor =  #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
        action2.image =  UIImage(named: "return_purchase_filled_big") // return_purchase_filled_big return_purchase_filled
        
        let swipe = UISwipeActionsConfiguration(actions: [sectionType == .ToBuy ?  action1 : action2])
        return swipe
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //var sectionType: SectionType = .ToBuy
        var headers = ["Do kupienia ❓",  "Kupione ✅"]
        let label=UILabel()
        if fetchedResultsController.sections?.count ?? 0 < 2 {
            let indexPath = IndexPath(row: 0, section: section)
            let elem = fetchedResultsController.object(at: indexPath) as! ToShopProductTable
            if elem.checked {
                headers = ["Kupione 👍"]
            }
            else {
                headers = ["Do kupienia 👉🏻"]
            }
        }
        else {
            headers = ["Do kupienia 👉🏻",  "Kupione  👍"]
        }
//------------------
        
        
        let sectionName = headers[section]
        //let secCount = database.category.sectionsData[section].objects.count
        label.text="\(sectionName)"
        label.textAlignment = .center
        label.backgroundColor = ((section == 0) ?  #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1) : #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1))
        label.textColor = ((section != 0) ? UIColor.white : UIColor.black)
        return label
    }
    func getSectionType(at indexPath: IndexPath) -> SectionType {
        let elem = fetchedResultsController.object(at: indexPath) as! ToShopProductTable
        return elem.checked ? SectionType.AlreadyBought : SectionType.ToBuy
    }
    func firstRunSetupSections(forEntityName entityName : String) {
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
       
            //print("Controler: old Indexpath \(indexPath), new Indexpath (\(newIndexPath)")
            self.tableView?.reloadData()
    }
        
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
