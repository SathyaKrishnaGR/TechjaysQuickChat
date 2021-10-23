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
        _ = array.map { index in
            print("index \(index.row)")
            self.remove(at: index.row)
        }
        completionHandler()
    }
}
