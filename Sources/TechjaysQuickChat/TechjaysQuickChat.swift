import UIKit

public struct TechjaysQuickChat {
    var text = "Hello, World!"
    var topMostController: UIViewController? {
        guard let win = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
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
    
    public func hello() -> String {
        return "Hello"
    }
    
    public func openChatListScreen() {
        let vc = UIStoryboard.initial(storyboard: UserManager().currentUserID().isNone ? .auth : .conversations)
        vc.modalPresentationStyle = .fullScreen
        topMostController?.present(vc, animated: true, completion: nil)
    }
}


