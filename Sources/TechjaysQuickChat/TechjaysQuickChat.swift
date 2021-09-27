import UIKit

public struct TechjaysQuickChat {
    
    public init() {
        
    }
    
    public func openChatList(accessToken: String, chatToken: String, appEndPoint: String, version: String, socket: String) -> UIViewController {
        FayvKeys.ChatDefaults.chatToken = chatToken
        FayvKeys.ChatDefaults.token = accessToken
        FayvKeys.ChatDefaults.endpoint = appEndPoint
        FayvKeys.ChatDefaults.socketUrl = socket
        FayvKeys.APIDefaults.baseUrl = appEndPoint
        FayvKeys.APIDefaults.version = version
        
        let storyboard = UIStoryboard(name: TechjaysChatIdentifiers.Storyboard.conversations.rawValue, bundle: Bundle.module)
        if let viewController = storyboard.instantiateViewController(withIdentifier: TechjaysChatIdentifiers.ViewController.conversations.rawValue) as? ConversationsViewController {
            viewController.toChatScreen = false
            
            return viewController
        }
        return UIViewController()
    }
    
    
    public func openChatMessage(accessToken: String, chatToken: String, appEndPoint: String, version: String, socket: String,toChatScreen: Bool?,userId: Int,opponentUserName: String?) -> UIViewController {
        FayvKeys.ChatDefaults.chatToken = chatToken
        FayvKeys.ChatDefaults.token = accessToken
        FayvKeys.ChatDefaults.endpoint = appEndPoint
        FayvKeys.ChatDefaults.socketUrl = socket
        FayvKeys.APIDefaults.baseUrl = appEndPoint
        FayvKeys.APIDefaults.version = version
        
        let storyboard = UIStoryboard(name: TechjaysChatIdentifiers.Storyboard.conversations.rawValue, bundle: Bundle.module)
        if let viewController = storyboard.instantiateViewController(withIdentifier: TechjaysChatIdentifiers.ViewController.conversations.rawValue) as? ConversationsViewController {
            viewController.opponentUserName = opponentUserName
            viewController.to_user_id = userId
            viewController.toChatScreen = true
            
            return viewController
        }
        return UIViewController()
    }
    
}


