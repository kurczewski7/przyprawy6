//
//  ProductList.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 31/10/2019.
//  Copyright © 2019 Slawomir Kurczewski. All rights reserved.
//

import Foundation
class ProductList {
    var englishName: String = " List"
    var polishName: String = " Lista"
    var pictureName: String = ""
    var descripton : String = ""
    var isCheked: Bool = false
    
    init(pictureName name: String) {
        self.pictureName = name
    }
    func getName() -> String{
        return Setup.polishLanguage  ? self.polishName : self.englishName
    }
}
