//
//  File.swift
//  
//
//  Created by SathyaKrishna on 11/10/21.
//

import UIKit
import Foundation
import MobileCoreServices
import UniformTypeIdentifiers

class DocumentService: NSObject {
    
    var completionBlock: CompletionObject<Data>?
    
    @available(iOS 14.0, *)
    func present(on parentViewController: UIViewController, allowedFileTypes types: [UTType], completion: CompletionObject<Data>?) {
        completionBlock = completion
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        documentPicker.delegate = self
        parentViewController.present(documentPicker, animated: true, completion: nil)
        
    }
}

extension DocumentService: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileUrl = urls.first else {
            return
        }
        guard let data = try? Data(contentsOf: fileUrl) else {
            return
        }
        self.completionBlock?(data)
    }
}
