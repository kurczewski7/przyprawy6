//
//  SelProductViewController.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 12/08/2019.
//  Copyright © 2019 Slawomir Kurczewski. All rights reserved.
//

import UIKit
import CoreData
class SelProductViewController: UIViewController, NSFetchedResultsControllerDelegate  {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
extension SelProductViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return database.toShopProduct.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SelProductViewControllerCell //
        let toShop=database.toShopProduct.array
        let dlugosc = toShop.count
        print("dlugosc \(dlugosc) indexPath.row \(indexPath.row)")
        if let product = toShop[indexPath.row].productRelation {
            configureCell(cell: cell, withEntity: product, row: indexPath.row, section: indexPath.section )
        }
        return cell
    }
        //let tmp = database.product.productArray[indexPath.row < dlugosc  ? indexPath.row: 0]
        //let obj = fetchedResultsController.object(at: indexPath) as! ToShopProductTable
//        if let product=obj.productRelation {
//            configureCell(cell: cell, withEntity: product, row: indexPath.row, section: indexPath.section )
//        }
       
       
    func configureCell(cell: SelProductViewControllerCell, withEntity product: ProductTable, row: Int, section: Int) {
        cell.producentLabel.text=product.producent
        cell.productLabel.text=product.productName
        cell.picture.image=UIImage(named: product.pictureName ?? "cameraCanon")
        cell.detaliLabel.text=(product.weight>0 ? "\(product.weight)g" : "")
//        cell.detailLabel.text=product.description
//        cell.producentLabel.text="aaa\(row),\(section)"
//        //cell.productNameLabel.text="cobj"
//        cell.productNameLabel.text = product.productName
//        cell.picture.image=UIImage(named: product.pictureName ?? "cameraCanon")
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Usuń z listy") { (lastAction, view, completionHandler) in
            //let sectionInfo =  self.fetchedResultsController.sections![indexPath.section]
            //sectionInfo.objects?.remove(at: indexPath.row)
            print("Usuń z listy")
            database.toShopProduct.remove(at: indexPath.row)
            database.save()
            completionHandler(true)
        }
        action.backgroundColor = .red
        action.image=UIImage(named: "full_trash")
        let swipe = UISwipeActionsConfiguration(actions: [action])
        return swipe
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action1 = UIContextualAction(style: .destructive, title: "Kup") { (act, view, completionHandler) in
            print("Kup")
            database.toShopProduct[indexPath.row].checked = true
            database.save()
            completionHandler(true)
        }
        action1.backgroundColor =  #colorLiteral(red: 0.09233232588, green: 0.5611743331, blue: 0.3208354712, alpha: 1)
        action1.image =  UIImage(named: "buy_filled")
        action1.title = "Kup"
        
        let action2 = UIContextualAction(style: .destructive, title: "Kup") { (act, view, completionHandler) in
            print("Kup")
            database.toShopProduct[indexPath.row].checked = false
            database.save()
            completionHandler(true)
        }
        action2.backgroundColor =  #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
        action2.image =  UIImage(named: "return_purchase_filled")
        action2.title = "Zwróć"
        let swipe = UISwipeActionsConfiguration(actions: [indexPath.section==0 ?  action1 : action2])
        return swipe
    }
}
