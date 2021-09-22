import UIKit

public struct TechjaysQuickChat {
   
    public init() {
        
    }
    
    // AccessToken, ChatToken,
    public func openChatListScreen(accessToken: String, chatToken: String, appEndPoint: String) {
        
        FayvKeys.UserDefault.chatToken = chatToken
        FayvKeys.UserDefault.token = accessToken
        FayvKeys.UserDefault.endpoint = appEndPoint
        
        let storyboard = UIStoryboard(name: "Conversations", bundle: Bundle.module)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "ConversationsViewController") as? ConversationsViewController {
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


