//
//  File.swift
//  
//
//  Created by SathyaKrishna on 16/09/21.
//

import Foundation
import UIKit

public var topMostController: UIViewController? {
    guard let win = UIApplication.shared.windows.first,
        let rootViewController = win.rootViewController else {
        return nil
    }
    var topController = rootViewController
    while let newTopController = topController.presentedViewController {
        topController = newTopController
    }
    return topController
}
