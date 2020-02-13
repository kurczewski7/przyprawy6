//
//  DatabaseTableGeneric.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 22/01/2020.
//  Copyright © 2020 Slawomir Kurczewski. All rights reserved.
//
import Foundation
import CoreData
// New Class ------------------------------------------
// variable for exemple ProductTable
class DatabaseTableGeneric <P: NSFetchRequestResult> {

    var context: NSManagedObjectContext
    var databaseSelf: Database
    private var  genericArray = [P]()
    private var  genericArrayFiltered: [P] = []
    private var  currentRow = 0
    
    var featchResultCtrl: NSFetchedResultsController<P> = NSFetchedResultsController<P>()
    var feachRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>()
    var sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor]()
    var count: Int {
        get {   return genericArray.count   }
    }
    var array: [P] {
        get {   return genericArray   }
        set {   genericArray = newValue  }
    }
    var arrayFiltered:[P] {
        get {   return genericArrayFiltered   }
        set {   genericArrayFiltered = newValue  }
    }
    subscript(index: Int) -> P {
        get {  _ = isIndexInRange(index: index)
            return genericArray[index]      }
        set {   _ = isIndexInRange(index: index)
            genericArray[index] = newValue  }
    }
    // you can override this class name in inheritance class
    class func className() -> String {
        return  "DatabaseTableGeneric" //self.classNameString  //"DatabaseTableGeneric"
    }
    init(databaseSelf: Database, keys: [String], ascendingKeys: [Bool], _ setFetchReqest: () -> NSFetchRequest<NSFetchRequestResult>) {
        self.context = databaseSelf.context
        self.databaseSelf = databaseSelf
        
        genericArray = []
        feachRequest = setFetchReqest()
        //feachRequest = initalizeFeachRequest()     // ProductTable.fetchRequest()
        for i in 0..<keys.count {
            sortDescriptors.append(NSSortDescriptor(key: keys[i], ascending: ascendingKeys[i]))
        }
        feachRequest.sortDescriptors = sortDescriptors
        featchResultCtrl = NSFetchedResultsController(fetchRequest: feachRequest, managedObjectContext:  context, sectionNameKeyPath: nil, cacheName: nil) as! NSFetchedResultsController<P>
    }
    func isIndexInRange(index: Int, isPrintToConsol: Bool = true) -> Bool {
            if index >= count {
                if isPrintToConsol {
                   print("Index \(index) is bigger then count \(count). Give correct index!")
                }
                return false
            }
            else {
                return true
            }
        }
    func first() -> P {
        _ = isIndexInRange(index: 0)
        return genericArray[0]
    }
    func last() -> P {
        let lastVal = count-1
        _ = isIndexInRange(index: lastVal)
        return genericArray[lastVal]
    }
    func append<T>(_ value: T) {
        if let val = value as? P {
            genericArray.append(val)
        }
    }
    func add(value: P) -> Int {
        genericArray.append(value)
        return genericArray.count
    }
    func remove(at row: Int) -> Bool {
        let r = (row == -1 ? genericArray.count-1 : row)
        if row < genericArray.count {
            context.delete(genericArray[r] as! NSManagedObject)
            genericArray.remove(at: row)
            return true
        }
        else {
            return false
        }
    }
//    func deleteOne(withProductRec row : Int) {
//         // for row -1 delete last record
//         //let arr = product.array
//         let r = (row == -1 ? product.count-1 : row)
//         context.delete(product.array[r])
//         product.array.remove(at: r)
//         save()
//     }

    func deleteAll()  {
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: feachRequest)
        do { try context.execute(DelAllReqVar) }
        catch { print(error) }
    }
    func next() -> P? {
        if currentRow+1 < count {
            currentRow += 1
            return genericArray[currentRow]
        }
        else {
            return nil
        }
    }
    func previous() -> P? {
        if currentRow > 0 && currentRow < count {
            currentRow += 1
            return genericArray[currentRow]
        }
        else {
            return nil
        }
    }
    // TODO: If you want
    func forEach(executeBlock: (_ index: Int, _ oneElement: P?) -> Void) {
        var i = -1
        print("genericArray.count:\(genericArray.count)")
        for elem in genericArray {
            i += 1
            executeBlock(i, elem)
        }
    }
    func findValue(procedureToCheck: (_ oneElement: P?) -> Bool) -> Int {
        var i = -1
        for elem in genericArray {
            i += 1
            if procedureToCheck(elem) {
                print("Object fond in table row \(i)")
                return i
            }
        }
        print("Object not found in table")
        return -1
    }
    func moveRow(fromSourceIndex sourceIndex: Int, to destinationIndex: Int) {
        let objectToMove = genericArray[sourceIndex]
        genericArray.remove(at: sourceIndex)
        genericArray.insert(objectToMove, at: destinationIndex)
    }
    func save() {
        self.databaseSelf.save()
    }
} // end of class DatabaseTableGeneric

