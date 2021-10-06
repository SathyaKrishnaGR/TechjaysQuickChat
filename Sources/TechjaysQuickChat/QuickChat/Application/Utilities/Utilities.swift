//
//  File.swift
//  
//
//  Created by SathyaKrishna on 06/10/21.
//

import UIKit


struct Utilities {
    static func showDeleteforMeActionSheet() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete for me", style: .destructive , handler:{ (UIAlertAction)in
            print("User click Edit button")
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        topMostController?.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    static func showDeleteActionSheet() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete for Everyone", style: .destructive , handler:{ (UIAlertAction)in
            print("User click Approve button")
        }))
        alert.addAction(UIAlertAction(title: "Delete for me", style: .destructive , handler:{ (UIAlertAction)in
            print("User click Edit button")
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        topMostController?.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
}
