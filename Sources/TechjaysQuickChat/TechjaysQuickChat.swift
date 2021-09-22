import UIKit

public struct TechjaysQuickChat {
   
    public init() {
        
    }
    
    // AccessToken, ChatToken,
    public func openChatListScreen(accessToken: String, chatToken: String, appEndPoint: String) {
        let storyboard = UIStoryboard(name: TechjaysChatIdentifiers.Storyboard.conversations.rawValue, bundle: Bundle.module)
        if let viewController = storyboard.instantiateViewController(withIdentifier: TechjaysChatIdentifiers.ViewController.conversations.rawValue) as? ConversationsViewController {
            viewController.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                topMostController?.present(viewController, animated: true, completion: nil)
            }
        }
    }
}


