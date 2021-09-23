import UIKit

public struct TechjaysQuickChat {
   
    public init() {
        
    }
    
    // AccessToken, ChatToken,
    public func openChatListScreen(accessToken: String, chatToken: String, appEndPoint: String, socket: String) {
        
        FayvKeys.ChatDefaults.chatToken = chatToken
        FayvKeys.ChatDefaults.token = accessToken
        FayvKeys.ChatDefaults.endpoint = appEndPoint
        FayvKeys.ChatDefaults.socketUrl = socket
        
        
        let storyboard = UIStoryboard(name: TechjaysChatIdentifiers.Storyboard.conversations.rawValue, bundle: Bundle.module)
        if let viewController = storyboard.instantiateViewController(withIdentifier: TechjaysChatIdentifiers.ViewController.conversations.rawValue) as? ConversationsViewController {
//            viewController.modalPresentationStyle = .popover
            
            
            print("Chat token \(FayvKeys.ChatDefaults.chatToken)")
            print("AccessToken \(FayvKeys.ChatDefaults.token)")
            print("Endpoint \(FayvKeys.ChatDefaults.endpoint)")
            DispatchQueue.main.async {
//                topMostController?.present(viewController, animated: true, completion: nil)
                topMostController?.embed(viewController, inView: (topMostController?.view)!)
                // tell the childviewcontroller it's contained in it's parent
            }
        }
    }
}
extension UIViewController {
    func embed(_ viewController:UIViewController, inView view:UIView){
        viewController.willMove(toParent: self)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        self.addChild(viewController)
        viewController.didMove(toParent: self)
    }
}

