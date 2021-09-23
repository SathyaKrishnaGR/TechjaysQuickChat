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
            UINavigationController().pushViewController(viewController, animated: true)
//            viewController.modalPresentationStyle = .currentContext
//            DispatchQueue.main.async {
//                topMostController?.present(viewController, animated: true, completion: nil)
//                // tell the childviewcontroller it's contained in it's parent
//            }
        }
    }
    
    public func openChatListScreenForVidhire(accessToken: String, chatToken: String, appEndPoint: String, socket: String,isFromReel: Bool?,userId: Int,opponentUserName: String?) {
        FayvKeys.ChatDefaults.chatToken = chatToken
        FayvKeys.ChatDefaults.token = accessToken
        FayvKeys.ChatDefaults.endpoint = appEndPoint
        FayvKeys.ChatDefaults.socketUrl = socket
        let storyboard = UIStoryboard(name: TechjaysChatIdentifiers.Storyboard.conversations.rawValue, bundle: Bundle.module)
        if let viewController = storyboard.instantiateViewController(withIdentifier: TechjaysChatIdentifiers.ViewController.conversations.rawValue) as? ConversationsViewController {
          viewController.opponentUserName = opponentUserName
          viewController.userId = userId
          viewController.isFromReel = isFromReel
//         viewController.modalPresentationStyle = .currentContext
            UINavigationController().pushViewController(viewController, animated: true)
//
//         DispatchQueue.main.async {
//          topMostController?.present(viewController, animated: true, completion: nil)
//          // tell the childviewcontroller it’s contained in it’s parent
//         }
        }
       }
}


