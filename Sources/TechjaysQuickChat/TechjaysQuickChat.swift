import UIKit

public struct TechjaysQuickChat {
    var text = "Hello, World!"
    var topMostController: UIViewController? {
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
    

    public init() {
        
    }
    
    // User Id, Profile, 
    public func openChatListScreen() {
//        let vc = UIStoryboard.initial(storyboard: .conversations)
//
        let vc = UIStoryboard.controller(storyboard: .conversations)
        vc.modalPresentationStyle = .fullScreen
        topMostController?.present(vc, animated: true, completion: nil)
    }
}


