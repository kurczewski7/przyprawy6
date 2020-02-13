//
//  Database.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 30.08.2018.
//  Copyright © 2018 Slawomir Kurczewski. All rights reserved.
//
import UIKit
import CoreData
import CoreSpotlight

protocol DatabaseDelegate: class {
    func updateGUI()
    func getNumberOfRecords(numbersOfRecords recNo: Int, eanMode: Bool)
    }
//--------------------------------------------------------------------------------------------------------------------------------
// Other databases class
class ProductSeting2:  DatabaseTableGeneric<ProductTable>, DatabaseTableProtocol {
    override class func className() -> String {
        return "ProductSeting2"
    }    
    var checkProduct: Bool = false {
        didSet {
            print("Ustawiono nowa wartosc: \(checkProduct)  stara wartosc \(oldValue)")
        }
    }
}
class ToShopProduct2: DatabaseTableGeneric<ToShopProductTable>, DatabaseTableProtocol {
    var currentListNumber: Int {
        get {
            return Setup.currentListNumber
        }
    }
    override class func className() -> String {
        return "ToShopProduct2"
    }
    func insert(toshopProd: ToShopProductTable, at row: Int) {
         let categoryId = toshopProd.productRelation?.categoryId ?? 0
         toshopProd.categoryId = categoryId
         array.insert(toshopProd, at: row)
     }
    override func append<T>(_ value: T) {
        if let val = value as? ToShopProductTable {
            let categoryId = val.productRelation?.categoryId ?? 0
            val.categoryId = categoryId
            array.append(val)
         }
    }
    func checkProduct(forProduct product: ProductTable, at indexPath: IndexPath, isSelected value: Bool) {
        print("Current check row: \(indexPath), \(value), product: \(String(describing: product.productName)),currentListNumber:\(currentListNumber) ")
            product.checked1 = false
            save()
        
        //product.multiChecked = value
//cell.accessoryType =  product.checked1 ? .checkmark : .none

    }
}
class FavoriteContacts: DatabaseTableGeneric<FavoriteContactsTable>, DatabaseTableProtocol {
    override class func className() -> String {
        return "FavoriteContacts"
    }
    func findExistElement(forKey key: String) -> Int {
        let row = findValue(procedureToCheck: { (contact)  in
            if let tmpKey = contact?.key {
                return tmpKey == key
            } else
            {
               return false
            }
        })
        return row
    }
}
//--------------------------------------------------------------------------------------------------------------------------------
// Main database class
class Database  {

    // seting delegate
    var delegate: DatabaseDelegate?
    var context: NSManagedObjectContext
    var selectedProductList: Int
    var eanMode: Bool = false
    
    // MARK: - Entitis of project
    var category: CategorySeting!  //  = CategorySeting(context: context)
    //var product: ProductSeting!    //   = ProductSeting(context: context)
    var product: DatabaseTableGeneric<ProductTable>!
    var toShopProduct: ToShopProduct2!   //DatabaseTableGeneric<ToShopProductTable>!   ToShopProduct!
    var shopingProduct: ShopingProduct!
    var basketProduct: BasketProduct!
    var favoriteContacts: FavoriteContacts!
    let bits: Bits!
 
//    // variable for ShopingProductTable
//    var shopingProductArray = [ShopingProductTable]()
//    let featchResultCtrlShopingProduct: NSFetchedResultsController<ShopingProductTable>
//    var feachShopingRequest:NSFetchRequest<ShopingProductTable> = ShopingProductTable.fetchRequest()
//    let sortShopingProductDescriptor = NSSortDescriptor(key: "id", ascending: true)
//    //var shopingProductTable : ShopingProductTable(context: context)

    // variable for ToShopProductTable
    
//    var toShopProductArray = [ToShopProductTable]()
//    let featchResultCtrlToShopProduct: NSFetchedResultsController<ToShopProductTable>
//    var feachToShopProductRequest:NSFetchRequest<ToShopProductTable> = ToShopProductTable.fetchRequest()
//    let sortToShopProductDescriptor = NSSortDescriptor(key: "id", ascending: true)
    //var shopingProductTable : ShopingProductTable(context: context)

//    // variable for BasketProductTable
//    var basketProductArray = [BasketProductTable]()
//    let featchResultCtrlBasketProduct: NSFetchedResultsController<BasketProductTable>
//    var feachBasketProductRequest:NSFetchRequest<BasketProductTable> = BasketProductTable.fetchRequest()
//    let sortBasketProductDescriptor = NSSortDescriptor(key: "id", ascending: true)
//    //var shopingProductTable : ShopingProductTable(context: context)
    
    
    var usersArray=[UsersTable]()
    var scanerCodebarValue: String {
        didSet {
            self.eanMode = true
            self.filterData(searchText: scanerCodebarValue, searchTable: .products, searchField: .EAN)
            if database.product.count == 0 {
                print("Not found this product")
            }
        }
    }
    @objc var selectedCategory: CategoryTable? {
        didSet {
            print("Seting Category: \(selectedCategory?.categoryName ?? "")")
            let catArray=database.category.categoryArray
            for el in catArray {
                el.selectedCategory = selectedCategory?.categoryName == el.categoryName ? true : false
            }
            database.save()
        }
    }
    // initialising class Database
  // initialising class Database
    init(context: NSManagedObjectContext) {
        self.context = context
        self.selectedProductList = 1
        self.scanerCodebarValue = ""
        bits = Bits(context: context)
            
        
        category  = CategorySeting(context: context)
        //product   = ProductSeting(context: context)
        //toShopProduct = ToShopProduct(context: context)
        shopingProduct = ShopingProduct(context: context)
        basketProduct = BasketProduct(context: context)
    
        
        product = ProductSeting2(databaseSelf: self, keys: ["productName"], ascendingKeys: [true]) {
             return ProductTable.fetchRequest()
        }
        toShopProduct = ToShopProduct2(databaseSelf: self, keys: ["id"], ascendingKeys: [true]) {
            return ToShopProductTable.fetchRequest()
        }
        favoriteContacts = FavoriteContacts(databaseSelf: self, keys: ["key"], ascendingKeys: [true]) {
            return FavoriteContactsTable.fetchRequest()
        }
//        product.initalizeFeachRequest() {
//            return ProductTable.fetchRequest()
//        }
        
        
//        let myClass = Database.self
//        Database.
//        let type = type(of: myClass)
    }

    func getParam(tableArrayWith dbName: DbTableNames) -> [AnyObject] {
        
        var myArray: [AnyObject]?
        switch dbName {
        case .products:
            myArray  = category.categoryArray
        case .categories:
            myArray  = product.array
        case .shopingProduct:
            myArray  = shopingProduct.array
        case .toShop:
            myArray  = toShopProduct.array
        case .basket:
            myArray  = basketProduct.array
        case .favoriteContacts:
            myArray = favoriteContacts.array
        case .users:
            print("ERROR: myArray  = userArray")

        }
        return myArray!
    }
    func setSelectedCategory() {
        if category.categoryArray.count>0 {
            for elem in category.categoryArray {
                if elem.selectedCategory {
                    self.selectedCategory=elem
                    print("self.selectedCategory.id:\(self.selectedCategory?.id ?? 9)")
                    break
                }
            }
        }
    }
    func loadData()  {
        let request : NSFetchRequest<ProductTable> = ProductTable.fetchRequest()
        do {    let newProducyArray     = try context.fetch(request)
            // Todo- error out of range
            
            if newProducyArray.count > 0  {
                self.product.array = newProducyArray }
            else {
                print("Error loading empty data")
                self.product.array = newProducyArray
            }
        }
        catch { print("Error fetching data from context \(error)")   }
    }
    func loadData(tableNameType tabName : DbTableNames, categoryId: Int16 = 0) {
        var request : NSFetchRequest<NSFetchRequestResult>?
        var groupPredicate:NSPredicate?
        
        switch tabName {
        case .products       :
            request = ProductTable.fetchRequest()
            groupPredicate = NSPredicate(format: "%K = %@", "categoryId", "\(categoryId)")
            //groupPredicate = NSPredicate(format: "%K = %@", "categoryId", "\(self.selectedCategory?.id ?? 9)")
            request?.predicate = groupPredicate
        case .basket         :
            request = BasketProductTable.fetchRequest()
        case .shopingProduct :
            request = ShopingProductTable.fetchRequest()
        case .categories     :
            request = CategoryTable.fetchRequest()
            setSelectedCategory()
        case .users          :
            request = UsersTable.fetchRequest()
        case .toShop         :
            request = ToShopProductTable.fetchRequest()
        case .favoriteContacts:
            request = FavoriteContactsTable.fetchRequest()
        }

//        let predicate=NSPredicate(format: "%K CONTAINS[cd] %@", searchField, searchText)
//        predicates.append(predicate)
//        let predicateAll=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicates)
//        reqest.predicate=predicateAll
//        let groupPredicate=NSPredicate(format: "%K = %@", "categoryId", "\(findCategoryId)")
//        request = ProductTable.fetchRequest()
        do {    let newArray     = try context.fetch(request!)
            // Todo- error out of range
            
            if newArray.count == 0  {
                print("Error loading empty data")
            }
            switch tabName {
                case .products        :
                    product.array = newArray as! [ProductTable]
                case .basket           :
                    basketProduct.array = newArray as! [BasketProductTable]
                case .shopingProduct   :
                    shopingProduct.array = newArray as! [ShopingProductTable]
                case .categories       :
                    category.categoryArray = newArray as! [CategoryTable]
                case .users            :
                    usersArray = newArray as! [UsersTable]
                case .toShop           :
                    toShopProduct.array = newArray as! [ToShopProductTable]
                case .favoriteContacts :
                    favoriteContacts.array = newArray as! [FavoriteContactsTable]
            }
        }
        catch { print("Error fetching data from context \(error)")   }
    }
    // MARK: - Delete and Add record methods
    func deleteOne() {
        let r = product.count-1
        context.delete(product[r])
        _ = product.remove(at: r)
        save()
    }
    func deleteOne(withProductRec row : Int) {
        // for row -1 delete last record
        //let arr = product.array
        let r = (row == -1 ? product.count-1 : row)
        context.delete(product.array[r])
        product.array.remove(at: r)
        save()
    }
    func deleteOne(withToShopRec row : Int) {
        let arr = toShopProduct.array
        let r = (row == -1 ? toShopProduct.count-1 : row)
        context.delete(toShopProduct[r])
        _ = toShopProduct.remove(at: r)
        save()
        let arr2 = toShopProduct.array
        print("\(arr)")
        print("\(arr2)")
    }
    func deleteOne(withBasketRec row : Int) {
        //let arr = basketProduct.basketProductArray   //toShopProduct.toShopProductArray
        let r = (row == -1 ? basketProduct.count-1 : row)
        context.delete(basketProduct[r])
        _ = basketProduct.remove(at: r)
        save()
    }
    func uncheckOne(withToShopRec row : Int, toCheck: Bool = false) {
        //let arr = toShopProduct.toShopProductArray
        let r = (row == -1 ? toShopProduct.count-1 : row)
        //arr[r].productRelation?.checked1 = toCheck
        checkProductList(productTable: toShopProduct[r].productRelation, toCheck: toCheck)
        save()
    }
    func checkProductList(productTable: ProductTable?, toCheck: Bool = false )  {
        switch self.selectedProductList {
            //case 0: productTable?.checked = toCheck
            case 1: productTable?.checked1 = toCheck
            case 2: productTable?.checked2 = toCheck
        default:
            print("Error checked Product")
        }
    }
    func delTable(dbTableName : DbTableNames)  {
        let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: dbTableName.rawValue)
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        let context=coreData.persistentContainer.viewContext
        
        do { try context.execute(DelAllReqVar) }
        catch { print(error) }
        //productArray.removeAll()
        //database.deleteAllData(entity: DbTableNames.produkty.rawValue)
        //database.productArray.removeAll()
    }
    
      func addOneRecord(newProduct : ProductTable) {
        _ = self.product.add(value: newProduct)
        self.save()
    }
    func addOneRecord(newProductInBasket basketProd: BasketProductTable, at row: Int = -1) {
        if row == -1 {
            self.basketProduct.append(basketProd)
        }
        else {
            _ = self.basketProduct.insert(basketProd, at: row)
        }
        self.save()
    }
    func addOneRecord(newProductToShop toshopProd: ToShopProductTable, at row: Int = -1) {
        if row == -1 {
            self.toShopProduct.append(toshopProd)
        }
        else {
            self.toShopProduct.insert(toshopProd: toshopProd, at: row)
        }
        self.save()
    }

    func addProduct(withProductId id : Int, saving : Bool = true)    {        
        let productElem = giveElement(withProduct: id)
        productElem.id=Int32(id)
        
        //productElem.parentCategory?.categoryName=database.selectedCategory?.categoryName
        productElem.parentCategory=database.selectedCategory
        productElem.categoryId = 1
        self.product.append(productElem)
        if product[product.count-1].pictureName == nil
        {
            print("---------")
            print("nul at \(product.count-1)")
            print("---------")
        }
        if saving {
            save()
        }
    }
    func moveProdduct(toBasketFrom row: Int, toRow: Int = -1) {
       if row < toShopProduct.count {
        if let product = toShopProduct[row].productRelation {
            let basket = BasketProductTable(context: context)
            print("prod:\(product.productName ?? "brak")")
            basket.productRelation = product
            deleteOne(withToShopRec: row)
            addOneRecord(newProductInBasket: basket, at: toRow)
        }
//          toShopProduct.toShopProductArray.remove(at: row)
//          let product = toShopProduct.toShopProductArray[row].productRelation
        }
    }
    func moveProdduct(fromBasketFrom row: Int, toRow: Int = -1) {
        if row < basketProduct.count {
            if let product = basketProduct[row].productRelation {
                print("prod:\(product.productName ?? "brak")")
                let toShop = ToShopProductTable(context:  context)
                toShop.productRelation=product
                deleteOne(withBasketRec: row)
                addOneRecord(newProductToShop: toShop, at: toRow)
            }
        }
    }
    // MARK: - giveData methods
    func giveElement(withProduct nr: Int) -> ProductTable
    {
        let product : ProductTable = ProductTable(context: context)
        let weight: Int
        var eanCode: String
        var w : String = ""
        
        let pictureName:String = Setup.picturesArray[nr]
        let elementy = pictureName.split(separator: "_", maxSplits: 11, omittingEmptySubsequences: false)
        print("---- \(pictureName)  ----")
        for i in 0..<elementy.count
        {
            print("\(i) = \(elementy[i])")
        }
        if elementy.count > 0
        {
            let producent : String = String(elementy[0])
            let productName = NSMutableString()
            let zakres=elementy.count-5
            for i in 1..<zakres {
                productName.append("\(String(elementy[i])) ")
            }
            // Mark: substring of string
            let str=String(elementy[elementy.count-5])
            let str2=String(elementy[elementy.count-6])
            let str3=String(elementy[elementy.count-7])
            
            if database.substrng(right: str, len: 1).uppercased() == "G"    {
                w=database.substrng(left: str, len: str.count-1)
                if str.count==1 {
                    w =  String(elementy[elementy.count-6])
                }
                else
                {
                   w = database.substrng(left: str, len: str.count-1)
                }
            }
            else if database.substrng(right: str2, len: 1).uppercased() == "G"  {
                w=database.substrng(left: str2, len: str2.count-1)
            } else if database.substrng(right: str3, len: 1).uppercased() == "G" {
            }
            else {
                w="0"
            }
            
            if let  value : Int = Int(w) {
                weight = value
            }
            else {
                weight = 0
            }
            let number3 = Int(elementy[elementy.count-1]) ?? 0
            let number2 = Int(elementy[elementy.count-2]) ?? 0
            let number1 = Int(elementy[elementy.count-3]) ?? 0
            eanCode = String(elementy[elementy.count-4])
            if Int(eanCode) == nil {
                eanCode = "00000000"
            }
            product.producent  = producent
            product.productName=String(productName)
            product.eanCode    =  eanCode
            product.pictureName=pictureName
            product.fullPicture=UIImage(named: pictureName)?.pngData()
            product.number1    = Int32(number1)
            product.number2    = Int32(number2)
            product.number3    = Int32(number3)
            product.weight     = Int16(weight)
            product.id         = Int32(nr)
            product.changeDate = Date.init()
            product.checked1    = false
            product.multiChecked = 0x9
        }
        return product
    }
    func fill(product rec : inout ProductTable)
    {
        rec.producent="Knor"
        rec.productName="no product"
        rec.eanCode="88888"
        rec.id=222
        rec.pictureName="pic1"
        rec.number1=1
        rec.number2=2
        rec.number3=3
        rec.weight=123
        rec.searchTag="tag1"
    }
    func substring(string str: String, startPosition startEl: Int, len : Int) -> String {
        let startInd = str.index(str.startIndex, offsetBy: startEl)
        let end=min(startEl+len,str.count)
        let endInd = str.index(str.startIndex, offsetBy: end)
        let mySubstring = str[startInd..<endInd]  
        return String(mySubstring)
    }
    func substrng(left : String, len: Int) -> String {
        return String(left.prefix(len))
    }
    func substrng(right : String, len: Int) -> String {
        return String(right.suffix(len))
    }
    func filterData(searchText text : String, searchTable : DbTableNames, searchField field: SearchField, isAscending: Bool = true) {
        //let ageIs33Predicate = NSPredicate(format: "%K = %@", "age", "33")
        //let namesBeginningWithLetterPredicate = NSPredicate(format: "(firstName BEGINSWITH[cd] $letter) OR (lastName BEGINSWITH[cd] $letter)")
        //(people as NSArray).filteredArrayUsingPredicate(namesBeginningWithLetterPredicate.predicateWithSubstitutionVariables(["letter": "A"]))
        // ["Alice Smith", "Quentin Alberts"]
        
        var predicates = [NSPredicate]()
        var numberOfRecords = 0
        
        let searchField =  field.rawValue
        let sortField   =  field.rawValue
        let searchText  =  text
        let findCategoryId = database.selectedCategory?.id ?? 1
        
        if searchTable == .products {
            let groupPredicate=NSPredicate(format: "%K = %@", "categoryId", "\(findCategoryId)")
            predicates.append(groupPredicate)
        }
       
        let reqest=getReqest(searchTable: searchTable) //.products
        if text.count>0 {
            let predicate=NSPredicate(format: "%K CONTAINS[cd] %@", searchField, searchText)
            predicates.append(predicate)
            let predicateAll=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicates)
            reqest.predicate=predicateAll
            let sortDeescryptor=NSSortDescriptor(key: sortField, ascending: isAscending)
            reqest.sortDescriptors=[sortDeescryptor]
        }

        do {
            let newSearchArray = (try context.fetch(reqest))
            switch searchTable {
            case .products:         product.array       = newSearchArray as! [ProductTable]
                                    numberOfRecords    = product.count
            // FIXME - basketProduct to shopingProduct
            case .shopingProduct:   basketProduct.array = newSearchArray as! [BasketProductTable]
                                    numberOfRecords    = basketProduct.count
            case .toShop:           toShopProduct.array = newSearchArray as! [ToShopProductTable]
                                    numberOfRecords    = toShopProduct.count
            case .basket:           basketProduct.array = newSearchArray as! [BasketProductTable]
                                    numberOfRecords    = basketProduct.count
            default:
                print("Table does not exist")
            }

            //productArray = newSearchArray as! [ProductTable]
        } catch  {
            print("Error feaching data from context \(error)")
        }
        delegate?.getNumberOfRecords(numbersOfRecords: numberOfRecords, eanMode: eanMode)
        delegate?.updateGUI()
        
        return 
    }
    func setSearchRequestArray(newProductArray: NSFetchRequest<NSFetchRequestResult>, searchTable : DbTableNames)
    {
//        switch searchTable {
//            case .products:  productArray = newProductArray as! [ProductTable]
//            case .shopingProduct:  basketProductArray = newProductArray as! [BasketProductTable]
//            case .toShop:  toShopProductArray = newProductArray as! [ToShopProductTable]
//            case .basket:  basketProductArray = newProductArray as! [BasketProductTable]
//        default:
//            print("Table does not exist")
//        }
        //productArray = newProductArray as! [ProductTable]
    }
    func getReqest(searchTable : DbTableNames) -> NSFetchRequest<NSFetchRequestResult> {
        let reqest: NSFetchRequest<NSFetchRequestResult>
        switch searchTable {
        case .products:
            reqest  = ProductTable.fetchRequest()
        case .toShop:
            reqest  = ToShopProductTable.fetchRequest()
        case .basket:
            reqest  = BasketProductTable.fetchRequest()
        case .shopingProduct:
            reqest  = ShopingProductTable.fetchRequest()
        case .categories:
             reqest  = CategoryTable.fetchRequest()
        case .users:
            reqest  = UsersTable.fetchRequest()
        case .favoriteContacts:
            reqest  = FavoriteContactsTable.fetchRequest()
            print("No favoriteContacts")
        }
        return reqest
    }
    func save() {
        do {   try context.save()    }
        catch  {  print("Error saveing context \(error)")   }
    }
    

    func toString(product: ProductTable, nr: Int)
    {
        // = ProductTable()
        print("\(nr)) \(String(describing: product.producent)) :  \(String(describing: product.productName)) :  \(product.weight)  : \(String(describing: product.eanCode)) : \(product.number1) : \(product.number2) : \(product.number3) : \(String(describing: product.pictureName))")
    }
    func printPath()
    {
        print(FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask))
    }
    func getEntityBuffor(databaseWithProduct database: Database) -> ProductTable {
        let product=ProductTable(context: database.context)
        return product
    }
    func addCategory(newCategoryValue category: CategoryType, idNumber id: Int) {
        let newCategory=CategoryTable(context: database.context)
        newCategory.categoryName=category.name
        newCategory.nameEN=category.nameEN
        newCategory.selectedCategory=category.selectedCategory
        newCategory.selectedCategory=category.selectedCategory
        newCategory.pictureEmoji=category.pictureName
        newCategory.id=Int16(id)
        
        //        let pict=UIImage(named: category.pictureName)
        //        let coder=NSCoder()
        //        coder.decodeData()
        newCategory.picture=nil
        self.category.categoryArray.append(newCategory)
        if category.selectedCategory {
            selectedCategory=newCategory
        }
        save()
    }
    func addToProductList(product : ProductTable) {
        let toShop = ToShopProductTable(context: context)
        toShop.changeDate=Date.init()
        toShop.eanCode=product.eanCode
        toShop.productRelation=product
        toShop.checked = false  // false
        toShopProduct.append(toShop)
    }
        // TODO: - removeFromBasket
    func removeFromProductList(withProductRec row : Int = -1) {
        let r = (row == -1 ? product.count-1 : row)
        context.delete(product[r])
        _ = product.remove(at: r)
        save()
    }
//    func deleteOne(withProductRec row : Int = -1) {
//        let r = (row == -1 ? product.productArray.count-1 : row)
//        context.delete(product.productArray[r])
//        product.productArray.remove(at: r)
//        save()
//    }

    
    func findSelestedCategory(categoryId : Int) -> CategoryTable {
        return database.category.categoryArray[categoryId]
    }
    func searchEanCode() {
        database.filterData(searchText: self.scanerCodebarValue, searchTable: .products, searchField: .EAN)
    }
}
//=====================================================
//class FavoriteContacts: DatabaseTableGeneric<FavoriteContactsTable>, DatabaseTableProtocol {
//}

// New Class ------------------------------------------
class CategorySeting2: DatabaseTableGeneric<CategoryTable> {
    struct SectionsData {
           var sectionId: Int = 0
           var sectionTitle: String = "No title"
           var groupId: Int = 0
           var objects: [Int] = []
       }
      var categoryGroups : [[Int]] = [[0,1,2], [3,4], [6],[],[],[],[],[]]
      var sectionsData: [SectionsData] = [SectionsData]()
    
    
    
      func crateCategoryGroups(forToShopProduct: [ToShopProductTable] ) {
            var categoryId: Int16 = 0
            //var categoryTmp: Int16?
            clearToShopForCategorries()
            for i in 0..<forToShopProduct.count {
                categoryId = forToShopProduct[i].productRelation?.categoryId ?? 0
                if categoryId > 0 {
                    categoryGroups[Int(categoryId)-1].append(i)
                }
            }
            createSectionsData()
        }
        func createSectionsData() {
            sectionsData.removeAll()
            var i: Int = 0
            var sectionNo: Int = 0
            var sectionTitle = ""
            for tmp in categoryGroups {
                if tmp.count > 0 {
                    sectionTitle = Setup.polishLanguage ? Setup.categoriesData[sectionNo].name : Setup.categoriesData[sectionNo].nameEN
                    addElementToSectionData(sectionId: sectionNo+1, sectionTitle: sectionTitle, groupId: i, objects: tmp)
                    i += 1
                }
                sectionNo += 1
            }
        }
        func addElementToSectionData(sectionId: Int, sectionTitle: String, groupId: Int, objects: [Int])
        {
            let newElement = SectionsData(sectionId: sectionId, sectionTitle: sectionTitle, groupId: groupId, objects: objects)
            print("newElement \(newElement)")
             sectionsData.append(newElement)
        }
        func deleteElement(forIndexpath indexpath: IndexPath) {
            let secton = indexpath.section
            let row = indexpath.row
            
    //aaaaaaaaaaaaaaaaaaaa
            sectionsData[secton].objects.remove(at: row)
            if sectionsData[secton].objects.count == 0 {
                print("UWAGA. OSTATNI ELEMENT")
                print("befor \(sectionsData[0])")
                //sectionsData.remove(at: secton)
                print("aftyer count: \(sectionsData.count)")
            }
        }
        func  clearToShopForCategorries() {
            categoryGroups = [[], [], [],[],[],[],[],[]]
        }
        func getCurrentSectionCount(forSection section: Int) -> Int {
            let val = self.sectionsData[section].objects.count //categoryGroups[section].count
             return val
        }
        
        func getTotalNumberOfSection() -> Int {
            let val = self.sectionsData.count // database.category.getCurrentSectionCount(forSection: section)
            return val
            
        }
        func getCategorySectionHeader(forSection section: Int) -> String {
            return self.sectionsData[section].sectionTitle
        }


}
class CategorySeting {
    struct SectionsData {
        var sectionId: Int = 0
        var sectionTitle: String = "No title"
        var groupId: Int = 0
        var objects: [Int] = []
    }
    let feachCategoryRequest: NSFetchRequest<CategoryTable> = CategoryTable.fetchRequest()
    var categoryGroups : [[Int]] = [[0,1,2], [3,4], [6],[],[],[],[],[]]
    var sectionsData: [SectionsData] = [SectionsData]()
    var context: NSManagedObjectContext
    var categoryArray: [CategoryTable] = []
    var sortCategoryDescriptor:NSSortDescriptor
    
    var count: Int {
        get {   return categoryArray.count   }
    }
    subscript(index: Int) -> CategoryTable {
        get {  return categoryArray[index]      }
        set {  categoryArray[index] = newValue  }
    }
    init(context: NSManagedObjectContext)
    {
        self.context=context
        categoryArray=[]
        sortCategoryDescriptor=NSSortDescriptor(key: "categoryName", ascending: true)
    }
    func crateCategoryGroups(forToShopProduct: [ToShopProductTable] ) {
        var categoryId: Int16 = 0
        //var categoryTmp: Int16?
        clearToShopForCategorries()
        for i in 0..<forToShopProduct.count {
            categoryId = forToShopProduct[i].productRelation?.categoryId ?? 0
            if categoryId > 0 {
                categoryGroups[Int(categoryId)-1].append(i)
            }
        }
        createSectionsData()
    }
    func createSectionsData() {
        sectionsData.removeAll()
        var i: Int = 0
        var sectionNo: Int = 0
        var sectionTitle = ""        
        for tmp in categoryGroups {
            if tmp.count > 0 {
                sectionTitle = Setup.polishLanguage ? Setup.categoriesData[sectionNo].name : Setup.categoriesData[sectionNo].nameEN
                addElementToSectionData(sectionId: sectionNo+1, sectionTitle: sectionTitle, groupId: i, objects: tmp)
                i += 1
            }
            sectionNo += 1
        }
    }
    func addElementToSectionData(sectionId: Int, sectionTitle: String, groupId: Int, objects: [Int])
    {
        let newElement = SectionsData(sectionId: sectionId, sectionTitle: sectionTitle, groupId: groupId, objects: objects)
        print("newElement \(newElement)")
         sectionsData.append(newElement)
    }
    func deleteElement(forIndexpath indexpath: IndexPath) {
        let secton = indexpath.section
        let row = indexpath.row
        
//aaaaaaaaaaaaaaaaaaaa
        sectionsData[secton].objects.remove(at: row)
        if sectionsData[secton].objects.count == 0 {
            print("UWAGA. OSTATNI ELEMENT")
            print("befor \(sectionsData[0])")
            //sectionsData.remove(at: secton)
            print("aftyer count: \(sectionsData.count)")
        }
    }
    func  clearToShopForCategorries() {
        categoryGroups = [[], [], [],[],[],[],[],[]]
    }
    func getCurrentSectionCount(forSection section: Int) -> Int {
        let val = self.sectionsData[section].objects.count //categoryGroups[section].count
         return val
    }
    
    func getTotalNumberOfSection() -> Int {
        let val = self.sectionsData.count // database.category.getCurrentSectionCount(forSection: section)
        return val
        
    }
    func getCategorySectionHeader(forSection section: Int) -> String {
        return self.sectionsData[section].sectionTitle
    }
} // end of class CategorySeting

// New Class ------------------------------------------
// variable for ProductTable


class ProductSeting: DatabaseTableProtocol {

    var context: NSManagedObjectContext
    private var  productArray: [ProductTable] = []
    private var  productArrayFiltered: [ProductTable] = []
    
    var featchResultCtrl: NSFetchedResultsController<ProductTable>
    let feachRequest: NSFetchRequest<ProductTable> = ProductTable.fetchRequest()
    var sortDescriptor:NSSortDescriptor
    var count: Int {
        get {   return productArray.count   }
    }
    var array: [ProductTable] {
        get {   return productArray   }
        set {   productArray = newValue  }
    }
    var arrayFiltered:[ProductTable] {
        get {   return productArrayFiltered   }
        set {   productArrayFiltered = newValue  }
    }
    subscript(index: Int) -> ProductTable {
        get {  return productArray[index]      }
        set {  productArray[index] = newValue  }
    }
//    subscript(section: Int, row: Int) {
//        get { return nil }
//        set { _ = newValue }
//    }
    func append<T>(_ value: T) {
        if let val = value as? ProductTable {
            productArray.append(val)
        }
    }
    init(context: NSManagedObjectContext)
    {
        self.context=context
        productArray=[]
        sortDescriptor=NSSortDescriptor(key: "productName", ascending: true)
        feachRequest.sortDescriptors = [sortDescriptor]
        featchResultCtrl=NSFetchedResultsController(fetchRequest: feachRequest, managedObjectContext:  context, sectionNameKeyPath: nil, cacheName: nil)
    }
    func add(value: ProductTable) -> Int {
        productArray.append(value)
        return productArray.count
    }
    func remove(at row: Int) -> Bool {
        let res: Bool
        if row < productArray.count {
            productArray.remove(at: row)
            res = true
        }
        else {
            res = false
        }
        return res
    }
    func remove(fromDatabaseRow row:Int) -> Bool {
        
        return true
    }
    
} // end of class ProductSeting

// New Class ------------------------------------------
// variable for ToShopProductTable
//class ToShopProduct2 {
//    var context: NSManagedObjectContext
//    var sortDescriptor:NSSortDescriptor
//
//    var toShopProductArray = [ToShopProductTable]()
//    var featchResultCtrl: NSFetchedResultsController<ToShopProductTable>
//    var feachRequest:NSFetchRequest<ToShopProductTable> = ToShopProductTable.fetchRequest()
//    init(context: NSManagedObjectContext)
//    {
//        self.context=context
//        toShopProductArray=[]
//        sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
//        feachRequest.sortDescriptors = [sortDescriptor]
//        featchResultCtrl = NSFetchedResultsController(fetchRequest: feachRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//    }
//    func deleteOne(withProductRec row : Int = -1) {
//        let r = (row == -1 ? toShopProductArray.count-1 : row)
//        context.delete(toShopProductArray[r])
//        toShopProductArray.remove(at: r)
//        save()
//    }
//    func save() {
//        do {   try context.save()    }
//        catch  {  print("Error saveing context \(error)")   }
//    }
//}
//        let categoryId = toshopProd.productRelation?.categoryId ?? 0
//        toshopProd.categoryId = categoryId
//        array.insert(toshopProd, at: row)
//
//class FavoriteContacts: DatabaseTableGeneric<FavoriteContactsTable> {
//
//}
class ToShopProduct: DatabaseTableProtocol {

    var context: NSManagedObjectContext
    var sortDescriptor:NSSortDescriptor
    
    private var toShopProductArray = [ToShopProductTable]()
    var featchResultCtrl: NSFetchedResultsController<ToShopProductTable>
    var feachRequest:NSFetchRequest<ToShopProductTable> = ToShopProductTable.fetchRequest()
    //var count: Int = 0
    var count: Int {
        get {  return toShopProductArray.count  }
    }
    var array: [ToShopProductTable] {
        get { return toShopProductArray }
        set { toShopProductArray = newValue }
    }
    subscript(index: Int) -> ToShopProductTable {
        get { return toShopProductArray[index] }
        set { toShopProductArray[index] = newValue }
    }
    
    func append<T>(_ value: T) {
        if let val = value as? ToShopProductTable {
            val.categoryId = val.productRelation?.categoryId ?? 0
            toShopProductArray.append(val)
        }
    }
    // self.toShopProduct.insert(toshopProd, at: row)
    func insert(toshopProd: ToShopProductTable, at row: Int) {
        let categoryId = toshopProd.productRelation?.categoryId ?? 0
        toshopProd.categoryId = categoryId
        toShopProductArray.insert(toshopProd, at: row)
    }
    func remove(at row: Int) -> Bool {
        var result: Bool = false
        if row < toShopProductArray.count {
            toShopProductArray.remove(at: row)
            result = true
        }
        return result
    }
    init(context: NSManagedObjectContext)
    {
        self.context=context
        toShopProductArray=[]
        sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        feachRequest.sortDescriptors = [sortDescriptor]
        featchResultCtrl = NSFetchedResultsController(fetchRequest: feachRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
}

// New Class ------------------------------------------
// variable for ShopingProductTable
class ShopingProduct {
    var context: NSManagedObjectContext
    private var shopingProductArray = [ShopingProductTable]()
    var featchResultCtrl: NSFetchedResultsController<ShopingProductTable>
    var feachRequest:NSFetchRequest<ShopingProductTable> = ShopingProductTable.fetchRequest()
    let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
    //var shopingProductTable : ShopingProductTable(context: context)
    init(context: NSManagedObjectContext)
    {
        self.context=context
        shopingProductArray = []
        feachRequest.sortDescriptors = [sortDescriptor]
        feachRequest.sortDescriptors = [sortDescriptor]
        featchResultCtrl = NSFetchedResultsController(fetchRequest: feachRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
    var count: Int {
        get { return shopingProductArray.count }
    }
    var array: [ShopingProductTable] {
        get { return shopingProductArray }
        set { shopingProductArray = newValue }
    }
    subscript(index: Int) -> ShopingProductTable {
        get { return shopingProductArray[index] }
        set { shopingProductArray[index] = newValue }
    }
    func append<T>(_ value: T) {
        if let val = value as? ShopingProductTable {
            shopingProductArray.append(val)
        }
    }
    func add(value: ShopingProductTable) -> Int {
        shopingProductArray.append(value)
        return shopingProductArray.count
    }
    func remove(at row: Int) -> Bool {
        let res:Bool
        if row < shopingProductArray.count {
            shopingProductArray.remove(at: row)
            res = true
        }
        else {
            res = false
        }
        return res
    }
}
// New Class ------------------------------------------
// variable for BasketProductTable
class BasketProduct {
    var context: NSManagedObjectContext
    private var basketProductArray = [BasketProductTable]()
    var featchResultCtrl: NSFetchedResultsController<BasketProductTable>
    var feachRequest:NSFetchRequest<BasketProductTable> = BasketProductTable.fetchRequest()
    let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
    init(context: NSManagedObjectContext)
    {
        self.context=context
        basketProductArray = []
        feachRequest.sortDescriptors = [sortDescriptor]
        feachRequest.sortDescriptors = [sortDescriptor]
        featchResultCtrl = NSFetchedResultsController(fetchRequest: feachRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
    var count: Int {
        get { return basketProductArray.count }
    }
    var array: [BasketProductTable] {
        get { return basketProductArray }
        set { basketProductArray = newValue }
    }
    subscript(index: Int) -> BasketProductTable {
        get { return basketProductArray[index] }
        set { basketProductArray[index] = newValue }
    }
    func append<T>(_ value: T) {
        if let val = value as? BasketProductTable {
            basketProductArray.append(val)
        }
    }
    func add(value: BasketProductTable) -> Int {
        basketProductArray.append(value)
        return basketProductArray.count
    }
    func remove(at row: Int) -> Bool {
        let res: Bool
        if row < basketProductArray.count {
            basketProductArray.remove(at: row)
            res = true
        }
        else {
            res = false
        }
        return res
    }
    //insert(basketProd, at: row)
    func insert(_ productToInsert: BasketProductTable, at row: Int) -> Int {
        basketProductArray.insert(productToInsert, at: row)
        return basketProductArray.count
    }
}

//        let predicate=NSPredicate(format: "%K CONTAINS[cd] %@", searchField, searchText)
//        predicates.append(predicate)
//        let predicateAll=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicates)
//        reqest.predicate=predicateAll
//  let groupPredicate=NSPredicate(format: "%K = %@", "categoryId", "\(findCategoryId)")

//    // variable for ProductTable
//    var productArray : [ProductTable] = []
//    var featchResultCtrlProduct: NSFetchedResultsController<ProductTable>
//    let feachProductRequest: NSFetchRequest<ProductTable> = ProductTable.fetchRequest()
//    let sortProductDescriptor = NSSortDescriptor(key: "productName", ascending: true)
//    //var productTable = ProductTable(context: context)

//var productTable = ProductTable(context: context)

