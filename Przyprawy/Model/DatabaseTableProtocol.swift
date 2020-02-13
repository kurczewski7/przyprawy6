//
//  DatabaseTableProtocol.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 18/08/2019.
//  Copyright © 2019 Slawomir Kurczewski. All rights reserved.
//

protocol DatabaseTableProtocol {
    var count: Int { get }
    // var array: [Any] { get set }
    func append<T>(_ value: T)
    func remove(at row: Int) -> Bool
}

