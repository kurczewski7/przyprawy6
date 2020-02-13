//
//  Bits.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 12/12/2019.
//  Copyright © 2019 Slawomir Kurczewski. All rights reserved.
//

import Foundation
import CoreData
class Bits {
    var context: NSManagedObjectContext
    var product: ProductTable?
    var bitsArray: [Bool]   = [Bool](repeating: false, count: 64)
    var bitsListCount: [Int] = [Int](repeating: 0, count: 64)
    var multiCheck: UInt64 = 0x0
    init(context: NSManagedObjectContext) {
        self.context = context    }
    var count: Int {
        get {   return bitsArray.count   }
    }
    subscript(index: Int) -> Bool {
        get {  return bitsArray[index]      }
        set {  bitsArray[index] = newValue  }
    }
    func clearData() {
        for i in 0..<bitsArray.count {
           bitsArray[i]     = false
           bitsListCount[i] = 0
        }
    }
//    var array: [Bool] {
//        get {   return bitsArray   }
//        set {   bitsArray = newValue  }
//    }

    func setBit(withBitNumber number: Int) -> UInt64 {
        let val: UInt64 = 0x1
        return (number > 0) ? val << number  : val
    }
    func setProduct(withProduct product: ProductTable?) {
        self.product = product
    }
    func readMultiCheck() {
        if let prod = self.product {
            multiCheck = UInt64(prod.multiChecked)
            for i in 0..<bitsArray.count {
                bitsArray[i] = (multiCheck & setBit(withBitNumber: i)) == 0 ? false : true
            }
        }
    }
    func setMultiChick(numberOfBit number: Int, boolValue value: Bool = true) {
        bitsArray[number] = value
    }
    func save() {
        var value: UInt64 = 0x0
        for i in 0..<bitsArray.count {
            if bitsArray[i] {
              value = (value | setBit(withBitNumber: i))
            }
         }
        if let prod = self.product {
            prod.multiChecked = Int64(value)
            do {   try self.context.save()    }
            catch  {  print("Error saveing context \(error)")   }
        }
        print("ret value: \(value)")
    }
    func loadListBits() {
        var multiChecked: UInt64 = 0x0
        if database.product.count > 0 {
            print("W bazie istnieje \(database.product.count) produktów")
            
            print("multiChecked: \(multiChecked)")
            for i in 0..<database.product.count {
                multiChecked = UInt64(database.product[i].multiChecked)
                updateBitsListCouut(forMultiChecked: multiChecked)
             }
        }
    }
    func updateBitsListCouut(forMultiChecked value: UInt64)  {
        for i in 0..<bitsListCount.count {
            self.bitsListCount[i] += (value & self.setBit(withBitNumber: i)) == 0 ? 0 : 1
        }

    }
    func isActiveList(withListNumber listNumber: Int) -> Bool {
        return self.bitsListCount[listNumber] == 0 ? false : true
    }
    func printBits() {
        let b1 = bitsArray[0]
        let b2 = bitsArray[1]
        let b3 = bitsArray[2]
        let b4 = bitsArray[3]
        let b5 = bitsArray[4]
        let b6 = bitsArray[5]
        let b7 = bitsArray[6]
        let b8 = bitsArray[7]
        let b9 = bitsArray[8]
        let b10 = bitsArray[9]
        let b11 = bitsArray[10]
        let b12 = bitsArray[11]

        let res = multiCheck
        print("val: \(b1),\(b2),\(b3),\(b4),\(b5),\(b6),\(b7),\(b8),\(b9),\(b10),\(b11),\(b12), res:\(res)")
        print("bitsListCount:\(bitsListCount)")
    }

}
