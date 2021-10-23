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
//        _ = array.reversed().map { index in
//            print("index \(index.row)")
//            print("Self should print the array \(self)")
//            if array.indices.contains(index.row) {
//                remove(at: index.row)
//            }
//        }
//        completionHandler()
//    }
        var iterator = array.makeIterator()
        while let element = iterator.next() {
            // do something with the element
            remove(at: element.row)
        }
    }
}
