import UIKit

public struct TechjaysQuickChat {
   
    public init() {
        
    }
    
    // AccessToken, ChatToken,
    public func openChatListScreen(accessToken: String, chatToken: String, appEndPoint: String) {
        
        FayvKeys.UserDefault.chatToken = chatToken
        FayvKeys.UserDefault.token = accessToken
        FayvKeys.UserDefault.endpoint = appEndPoint
        
        let storyboard = UIStoryboard(name: TechjaysChatIdentifiers.Storyboard.conversations.rawValue, bundle: Bundle.module)
        if let viewController = storyboard.instantiateViewController(withIdentifier: TechjaysChatIdentifiers.ViewController.conversations.rawValue) as? ConversationsViewController {
            viewController.modalPresentationStyle = .fullScreen
            
            print("Chat token \(FayvKeys.UserDefault.chatToken)")
            print("AccessToken \(FayvKeys.UserDefault.token)")
            print("Endpoint \(FayvKeys.UserDefault.endpoint)")
            DispatchQueue.main.async {
                topMostController?.present(viewController, animated: true, completion: nil)
            }
        }
    }
}


