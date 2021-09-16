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
        let storyboard = UIStoryboard(name: TechjaysChatIdentifiers.Storyboard.conversations.rawValue, bundle: Bundle.module)
        if let viewController = storyboard.instantiateViewController(withIdentifier: TechjaysChatIdentifiers.ViewController.conversations.rawValue) as? ConversationsViewController {
            viewController.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                topMostController?.present(viewController, animated: true, completion: nil)
            }
        }
    }
}


