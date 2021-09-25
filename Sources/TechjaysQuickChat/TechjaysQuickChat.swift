import UIKit

public struct TechjaysQuickChat {
   
    public init() {
        
    }
        
    public func presentInContainerWith(accessToken: String, chatToken: String, appEndPoint: String, version: String, socket: String,toChatScreen: Bool?,userId: Int,opponentUserName: String?) -> UIViewController {
        FayvKeys.ChatDefaults.chatToken = chatToken
        FayvKeys.ChatDefaults.token = accessToken
        FayvKeys.ChatDefaults.endpoint = appEndPoint
        FayvKeys.ChatDefaults.socketUrl = socket
        
        FayvKeys.APIDefaults.baseUrl = appEndPoint
        FayvKeys.APIDefaults.version = version
        let storyboard = UIStoryboard(name: TechjaysChatIdentifiers.Storyboard.conversations.rawValue, bundle: Bundle.module)
        if let viewController = storyboard.instantiateViewController(withIdentifier: TechjaysChatIdentifiers.ViewController.conversations.rawValue) as? ConversationsViewController {
          viewController.opponentUserName = opponentUserName
          viewController.userId = userId
            viewController.toChatScreen = toChatScreen!
            
            return viewController
        }
         return UIViewController()
       }
    
    public func presentInContainerWith(accessToken: String, chatToken: String, appEndPoint: String, version: String, socket: String, userId: Int,opponentUserName: String?) -> UIViewController {
        FayvKeys.ChatDefaults.chatToken = chatToken
        FayvKeys.ChatDefaults.token = accessToken
        FayvKeys.ChatDefaults.endpoint = appEndPoint
        FayvKeys.ChatDefaults.socketUrl = socket
        
        FayvKeys.APIDefaults.baseUrl = appEndPoint
        FayvKeys.APIDefaults.version = version
        let storyboard = UIStoryboard(name: TechjaysChatIdentifiers.Storyboard.conversations.rawValue, bundle: Bundle.module)
        if let viewController = storyboard.instantiateViewController(withIdentifier: TechjaysChatIdentifiers.ViewController.conversations.rawValue) as? ConversationsViewController {
          viewController.opponentUserName = opponentUserName
          viewController.userId = userId
            
            return viewController
        }
         return UIViewController()
       }
}


