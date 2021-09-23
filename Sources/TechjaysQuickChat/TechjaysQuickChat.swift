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
            viewController.modalPresentationStyle = .overCurrentContext
            
            print("Chat token \(FayvKeys.ChatDefaults.chatToken)")
            print("AccessToken \(FayvKeys.ChatDefaults.token)")
            print("Endpoint \(FayvKeys.ChatDefaults.endpoint)")
            DispatchQueue.main.async {
                topMostController?.present(viewController, animated: true, completion: nil)
            }
        }
    }
}


