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
            DispatchQueue.main.async {
                topMostController?.present(viewController, animated: true, completion: nil)
                // tell the childviewcontroller it's contained in it's parent
            }
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
         viewController.modalPresentationStyle = .overCurrentContext
            DispatchQueue.main.async {
                
                topMostController?.present(viewController, animated: true, completion: nil)
                        
            }
        }
         
       }
    
    public func test(accessToken: String, chatToken: String, appEndPoint: String, socket: String,isFromReel: Bool?,userId: Int,opponentUserName: String?) -> UIViewController {
        FayvKeys.ChatDefaults.chatToken = chatToken
        FayvKeys.ChatDefaults.token = accessToken
        FayvKeys.ChatDefaults.endpoint = appEndPoint
        FayvKeys.ChatDefaults.socketUrl = socket
        let storyboard = UIStoryboard(name: TechjaysChatIdentifiers.Storyboard.conversations.rawValue, bundle: Bundle.module)
        if let viewController = storyboard.instantiateViewController(withIdentifier: TechjaysChatIdentifiers.ViewController.conversations.rawValue) as? ConversationsViewController {
          viewController.opponentUserName = opponentUserName
          viewController.userId = userId
          viewController.isFromReel = isFromReel
//         viewController.modalPresentationStyle = .overCurrentContext
            
            return viewController
        }
         return UIViewController()
       }
}


