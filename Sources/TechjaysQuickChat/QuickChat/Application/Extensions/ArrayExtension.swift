//
//  File.swift
//  
//
//  Created by SathyaKrishna on 26/09/21.
//

import Foundation

extension Array {
    typealias CompletionHandler = () -> Void

    mutating func removeArrayOfIndex(array: [IndexPath], completionHandler: CompletionHandler)  {
//        Loop -> Remove and Complete
        var data = array.reversed()
            _ = data.reversed().map { index in
                print("index \(index.row)")
                print("Self should print the array \(self)")
                remove(at: index.row)
                self = data
            }
            completionHandler()
    }
}
