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
            self.remove(at: index.row)
        }
    }
}