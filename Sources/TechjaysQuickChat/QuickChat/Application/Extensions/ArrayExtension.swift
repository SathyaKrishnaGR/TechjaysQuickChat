//
//  File.swift
//  
//
//  Created by SathyaKrishna on 26/09/21.
//

import Foundation

extension Array {
    mutating func removeArrayOfIndex(array: [IndexPath]) {
        _ = array.map { index in
            
            print("index \(index.row)")
            self.remove(at: index.row)
        }
    }
}
