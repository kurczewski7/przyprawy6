//
//  AppDelegate.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 20.07.2018.
//  Copyright © 2018 Slawomir Kurczewski. All rights reserved.
//

import UIKit
enum LanguaesList: String {
    //  let language = ["pl", "en-GB","de","fr","pl"]
    case enlish     = "en"
    case english_US = "en-US"
    case english_GB = "en-GB"
    case polish     = "pl"
    case german     = "de"
    case french     = "fr_FR"
    case spanish    = "es_ES"
}
enum DbTableNames : String {
    case products         = "ProductTable"
    case basket           = "BasketProductTable"
    case shopingProduct   = "ShopingProductTable"
    case toShop           = "ToShopProductTable"
    case categories       = "CategoryTable"
    case favoriteContacts = "FavoriteContactsTable"  //FavortteContactsTable //FavoriteContactsTable
    case users            = "Users"
}
enum SearchField : String {
    case Producent = "producent"
    case Product   = "productName"
    case Tag       = "searchTag"
    case EAN       = "eanCode"
}

 typealias CategoryType = (name: String, nameEN: String, pictureName: String, selectedCategory : Bool)



let coreData = CoreDataStack()
let database = Database(context: coreData.persistentContainer.viewContext)
let server   = Server()
let cards = Setup.fillCards()
let speak = Speaking()

//let polishLanguage = true
// Mark: Detect 3D touch
let is3Dtouch = UIApplication.shared.keyWindow?.traitCollection.forceTouchCapability == UIForceTouchCapability.available
let bundleID = "pl.wroclaw.pwr.Przyprawy"
var segmentValues : [String] = ["product","producent"]


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        let speak = Speak(lang: .polish)
//        speak.startSpeaking()   //sSpeaking()
        
        print("database.product.count przed: \(database.product.count)")
        database.loadData(tableNameType: .products)
        print("database.product.count po: \(database.product.count)")
        
        print("database.categoryArray.count przed : \(database.category.categoryArray.count)")
        database.loadData(tableNameType: .categories)
        print("database.categoryArray.count po : \(database.category.categoryArray.count)")
        
        print("database.basketProduct.basketProductArray.count przed : \(database.basketProduct.count)")
        database.loadData(tableNameType: .basket)
        print("database.basketProduct.basketProductArray.count po : \(database.basketProduct.count)")
        if database.category.categoryArray.count == 0 {
            var i=1
            for rec in Setup.categoriesData {
                database.addCategory(newCategoryValue: rec, idNumber: i)
                i+=1
            }
        }
        else {
            for cat in database.category.categoryArray {
                if cat.selectedCategory {
                    database.selectedCategory=cat
                }
            }
        }
        // Override point for customization after application launch.
        aboutSwiftVersion()
        
        Setup.currentLanguage = .polish
//        Setup.currentLanguage = .enlish
//        Setup.currentLanguage = .german
//        Setup.currentLanguage = .french
        speak.textToSpeach = Setup.getWelcome()
        
        
        //Setup.getWelcome()
        //speak.startSpeaking()

        return true
    }
    func aboutSwiftVersion() {
        #if swift(>=5.0)
        print("Version: Swift 5.0")
        
        #elseif swift(>=4.2)
        print("Version: Swift 4.2")
        
        #elseif swift(>=4.1)
        print("Version: Swift 4.1")
        
        #elseif swift(>=4.0)
        print("Version: Swift 4.0")
        
        #elseif swift(>=3.2)
        print("Version: Swift 3.2")
        
        #elseif swift(>=3.0)
        print("Version: Swift 3.0")
        
        #elseif swift(>=2.2)
        print("Version: Swift 2.2")
        
        #elseif swift(>=2.1)
        print("Version: Swift 2.1")
        
        #elseif swift(>=2.0)
        print("Version: Swift 2.0")
        
        #elseif swift(>=2.0)
        print("Version: Swift 2.0")
        
        #elseif swift(>=1.2)
        print("Version: Swift 1.2")
        
        #elseif swift(>=1.1)
        print("Version: Swift 1.1")
        
        #elseif swift(>=1.0)
        print("Version: Swift 1.0")
        
        #endif
    }

    ///   tu był corebData stack
    // Mark : 3D touch method
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type=="pl.wroclaw.pwr.Przyprawy.showPictures"{
            print("pl.wroclaw.pwr.Przyprawy.showPictures")
            let storyBoard:UIStoryboard=UIStoryboard(name: "Main", bundle: nil)
            let initViewController = storyBoard.instantiateViewController(withIdentifier: "3dtouch")
            self.window?.rootViewController=initViewController
            self.window?.makeKeyAndVisible()
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        coreData.saveContext()
    }
    
    

}

