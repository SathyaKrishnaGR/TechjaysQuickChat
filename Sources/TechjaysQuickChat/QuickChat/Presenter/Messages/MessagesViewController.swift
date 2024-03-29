//  MIT License

//  Copyright (c) 2019 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import UIKit
import Foundation

class MessagesViewController: UIViewController, KeyboardHandler, UIGestureRecognizerDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: PaginatedTableView!
    @IBOutlet weak var inputTextField: UITextView!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    @IBOutlet weak var stackViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var barBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet var actionButtons: [UIButton]!
    @IBOutlet weak var inputTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topViewTop: NSLayoutConstraint!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    
    
    //MARK: Private properties
    private let manager = MessageManager()
    private let imageService = ImagePickerService()
    private let documentService = DocumentService()
//    private let locationService = LocationService()
    private var messages = [ObjectMessage]()
    var socketManager = SocketManager()
    var toChatScreen: Bool = false
    var opponentUserName: String?
    
    //MARK: Public properties
    var conversation = ObjectConversation()
    var newList = ObjectUser()
    var bottomInset: CGFloat {
        return view.safeAreaInsets.bottom + 50
    }
    var to_user_id: Int = 0
    fileprivate var webSocketConnected = false
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
       addKeyboardObservers() {[weak self] state in
            guard state else { return }
            self?.tableView.scroll(to: .bottom, animated: true)
        }
        FayvKeys.ChatDefaults.paginationLimit = "100"
        self.setBackgroundTheme(image: ChatBackground.image)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.fetchData()
        showUserNameOnNavBar()
        self.setTint()
        if socketManager.socket == nil {
            _ = socketManager.startSocketWith(url: FayvKeys.ChatDefaults.socketUrl)
        }
       
        socketManager.dataUpdateDelegate = self
        showActionButtons(false)
    }
}

//MARK: Private methods
extension MessagesViewController {
    private func send(_ message: String, messageType: String) {
        socketManager.sendMessage(chatToken: FayvKeys.ChatDefaults.chatToken, toUserId: String(to_user_id), message: message, messageType: messageType)
    }
    private func showUserNameOnNavBar() {
        if toChatScreen {
            self.navigationItem.title = opponentUserName
        } else {
            var last = ""
            var first = ""
            if let lastName = conversation.last_name {
                last = lastName
            }
            if let firstName = conversation.first_name {
                first = firstName
            }
            self.navigationItem.title = "\(first) \(last)"
        }
        
        //        showIconOnNavigationBar(imageUrl: nil) // Will show default image
        //        if let image = conversation.medium_profile_pic {
        //            showIconOnNavigationBar(imageUrl: image)
        //        }
    }
    
    fileprivate func showIconOnNavigationBar(imageUrl: String?) {
        
        let frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let customView = UIView(frame: frame)
        let imageView = UIImageView()
        imageView.frame = frame
        imageView.layer.cornerRadius = imageView.frame.height * 0.5
        imageView.layer.masksToBounds = true
        
        if imageUrl != nil {
            imageView.setImage(url: URL(string: imageUrl!))
        } else {
            imageView.image = UIImage(named: "profile_pic", in: Bundle.module, with: .none)
        }
        customView.addSubview(imageView)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: customView)
        ]
        
    }
    private func doneButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    private func showActionButtons(_ status: Bool) {
        guard !status else {
            stackViewWidthConstraint.constant = 32
            UIView.animate(withDuration: 0.3) {
                self.expandButton.isHidden = true
                self.expandButton.alpha = 0
                self.actionButtons.forEach({$0.isHidden = false})
                self.view.layoutIfNeeded()
            }
            return
        }
        guard stackViewWidthConstraint.constant != 32 else { return }
        stackViewWidthConstraint.constant = 32
        UIView.animate(withDuration: 0.3) {
            self.expandButton.isHidden = false
            self.expandButton.alpha = 1
            self.actionButtons.forEach({$0.isHidden = true})
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: IBActions
extension MessagesViewController {
    @IBAction func editPressed(_ sender: Any) {
        isEditing = !isEditing
        DispatchQueue.main.async {
            if self.isEditing {
                self.deleteButton.isEnabled = true
                self.navigationItem.leftBarButtonItem?.title = "Done"
                self.editButton.title = "Done"
               
            } else {
                self.deleteButton.isEnabled = false
                self.navigationItem.leftBarButtonItem?.title = "Edit"
                self.editButton.title = "Edit"
            }
        }
        
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        if deleteButton.isEnabled {
//            deleteButton.isEnabled = false
            self.checkForDeleteAction()
        }
    }
    
    fileprivate func checkForDeleteAction() {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            var selectedMessages = [ObjectMessage]()
            var deleteType: [String] = []
            for indexPath in selectedRows  {
                selectedMessages.append(messages[indexPath.row])
                if messages[indexPath.row].is_sent_by_myself! {
                    deleteType.append("everyone")
                } else {
                    deleteType.append("for_me")
                }
            }
            if !deleteType.contains("for_me") {
                self.showDeleteActionSheet(rows: selectedRows, messages: selectedMessages)
            } else {
                self.showDeleteforMeActionSheet(rows: selectedRows, messages: selectedMessages)
            }
        }
    }
    fileprivate func deleteAndRemoveRows(rows: [IndexPath], messages: [ObjectMessage], deleteType: String) {
        self.tableView.beginUpdates()
        self.messages.removeArrayOfIndex(at: rows)
        self.tableView.deleteRows(at: rows, with: .automatic)
        self.deleteChatMessages(rows: rows, messageIdToDelete: messages, deleteType: deleteType)
        
        
    }
}
extension MessagesViewController {
    
    @IBAction func sendMessagePressed(_ sender: Any) {
        guard let text = inputTextField.text, !text.isEmpty else { return }
        tableViewHeight.constant = 640
        topViewHeight.constant = 50
        inputTextFieldHeight.constant = 40
        let message = ObjectMessage()
        message.message = text
        message.timestamp = Date().dateToString()
        if let message = message.message {
            send(message, messageType: "message")
        }
        showActionButtons(false)
    }
    
    @IBAction func sendImagePressed(_ sender: UIButton) {
        //        imageService.pickImage(from: self, allowEditing: false, source: sender.tag == 0 ? .photoLibrary : .camera) {[weak self] image in
        if #available(iOS 14.0, *) {
            documentService.present(on: self, allowedFileTypes: [.pdf]) { data in
                let payload = Multipart(toUserId: self.to_user_id, fileType: "pdf", imageData: data)
                self.uploadAttachment(payload: payload)
                self.showActionButtons(false)
                
            }
        }
    }
    
    @IBAction func sendLocationPressed(_ sender: UIButton) {
//        locationService.getLocation {[weak self] response in
//            switch response {
//            case .denied:
//                self?.showAlert(title: "Error", message: "Please enable locattion services")
//            case .location(_):
//                self?.showActionButtons(false)
//            }
//        }
    }
    
    @IBAction func expandItemsPressed(_ sender: UIButton) {
        showActionButtons(true)
    }
}

//MARK: UITableView Delegate & DataSource
extension MessagesViewController: PaginatedTableViewDelegate {
    
    func paginatedTableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func paginatedTableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    func paginatedTableView(paginationEndpointFor tableView: UITableView) -> PaginationUrl {
        PaginationUrl(endpoint: "chat/chat-messages/", parameters: ["to_user_id": "\(to_user_id)"])
    }
    
    func paginatedTableView(_ tableView: UITableView, paginateTo url: String, isFirstPage: Bool, afterPagination hasNext: @escaping (Bool) -> Void) {
        fetchMessages(for: url, isFirstPage: isFirstPage, hasNext: hasNext)
    }
    
    func paginatedTableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func paginatedTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // MARK:- Messages from API
        
        let message = messages[indexPath.row]
        if !message.is_sent_by_myself! {
            
            //        if message.contentType == .none {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserMessageTableViewCell") as! MessageTableViewCell
            cell.messageTextView?.font = ChatFont.text
            cell.timestampLabel?.font = ChatFont.smallText
            
            cell.setChatList(message, conversation: conversation)
            return cell
            //        }
            //        let cell = tableView.dequeueReusableCell(withIdentifier: message.ownerID == UserManager().currentUserID() ? "MessageAttachmentTableViewCell" : "UserMessageAttachmentTableViewCell") as! MessageAttachmentTableViewCell
            //        cell.delegate = self
            //        cell.set(message)
            //        return cell
        } else {
            //        if message.contentType == .none {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell") as! MessageTableViewCell
            cell.chatBubbleView.backgroundColor = ChatColors.tint
            cell.messageTextView?.font = ChatFont.text
            cell.timestampLabel?.font = ChatFont.smallText
          
            cell.setChatList(message, conversation: conversation)
            return cell
            //        }
            //        let cell = tableView.dequeueReusableCell(withIdentifier: message.ownerID == UserManager().currentUserID() ? "MessageAttachmentTableViewCell" : "UserMessageAttachmentTableViewCell") as! MessageAttachmentTableViewCell
            //        cell.delegate = self
            //        cell.set(message)
            //        return cell
            
        }
        //        }
    }
    func paginatedTableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard tableView.isDragging else { return }
        cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            cell.transform = CGAffineTransform.identity
        })
    }
    func paginatedTableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    func paginatedTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let message = messages[indexPath.row]
        
        //        switch message.contentType {
        //        case .location:
        //            let vc: MapPreviewController = UIStoryboard.controller(storyboard: .previews)
        //            vc.locationString = message.content
        //            navigationController?.present(vc, animated: true)
        //        case .photo:
        //            let vc: ImagePreviewController = UIStoryboard.controller(storyboard: .previews)
        //            vc.imageURLString = message.profilePicLink
        //            navigationController?.present(vc, animated: true)
        //        default: break
        //        }
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        
    }
}

//MARK: UItextField Delegate
extension MessagesViewController: UITextFieldDelegate,UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        showActionButtons(false)
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        showActionButtons(false)
        if self.inputTextField.contentSize.height < 50 {
            tableViewHeight.constant = 640
            topViewHeight.constant = self.inputTextField.contentSize.height + 15
            inputTextFieldHeight.constant = self.inputTextField.contentSize.height
        } else if self.inputTextField.contentSize.height < 130 {
            tableViewHeight.constant = 580
            topViewHeight.constant = self.inputTextField.contentSize.height + 10
            inputTextFieldHeight.constant = self.inputTextField.contentSize.height
        } else {
            tableViewHeight.constant = 580
            topViewHeight.constant = 130
            inputTextFieldHeight.constant = 120
            self.inputTextField.isScrollEnabled = true
        }
           
        return true
    }
  
}

//MARK: MessageTableViewCellDelegate Delegate
extension MessagesViewController: MessageTableViewCellDelegate {
    func messageTableViewCellUpdate() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension MessagesViewController {
    fileprivate func fetchMessages(for url: String, isFirstPage: Bool, hasNext: @escaping (Bool) -> Void) {
        APIClient().GET(url: url, headers: ["Authorization": FayvKeys.ChatDefaults.token]) { (status, response: APIResponse<[ObjectMessage]>) in
            switch status {
            case .SUCCESS:
                if let data = response.data {
                    if isFirstPage {
                        self.messages = data
                    } else {
                        self.messages.append(contentsOf: data )
                    }
                    if self.messages.count > 1 {
                        self.messages = self.messages.sorted(by: {$0.timestamp?.stringToDate().compare(($1.timestamp?.stringToDate())!) == .orderedAscending})
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.tableView.scroll(to: .bottom, animated: true)
                    }
                }
                hasNext(response.nextLink ?? false)
            case .FAILURE:
                hasNext(false)
            }
        }
    }
    fileprivate func deleteChatMessages(rows: [IndexPath], messageIdToDelete: [ObjectMessage], deleteType: String) {
        let stringArray = messageIdToDelete.map {String(describing: $0.message_id!)}
        let payloadString = stringArray.joined(separator: ",")
        
        let url = URLFactory.shared.url(endpoint: "chat/delete-chat-messages/")
        APIClient().POST(url: url, headers: ["Authorization": FayvKeys.ChatDefaults.token], payload: ["to_user_id": to_user_id, "message_ids": payloadString,  "delete_message_type": deleteType]) { (status, response: APIResponse<[ObjectMessage]>) in
            switch status {
            case .SUCCESS:
                self.isEditing = !self.isEditing
                self.resetEditAndDeletebuttons()
                DispatchQueue.main.async {
                    self.tableView.fetchData()
                }
                self.tableView.endUpdates()
            case .FAILURE:
                print(response.msg)
            }
        }
    }
    fileprivate func uploadAttachment(payload: Multipart) {
        let url = URLFactory.shared.url(endpoint: "chat/file-upload/")
        APIClient().MULTIPART(url: url,
                              headers: ["Authorization": FayvKeys.ChatDefaults.token], uploadType: .post,
                              payload: payload,
                              files: [.init(fileName: "file", fileExtension: payload.fileType! , data: payload.imageData!)]) { (status, response: APIResponse<ObjectMessage>) in
            switch status {
            case .SUCCESS:
                let data = response.data
                if let dat = data?.file_url {
                    self.inputTextField.text = dat
                    self.send(dat, messageType: "file")
                }
            case .FAILURE:
                break
            }
        }
    }
    
    fileprivate func resetEditAndDeletebuttons() {
        self.deleteButton.isEnabled = false
        self.editButton.title = "Edit"
    }
}

extension MessagesViewController: SocketDataTransferDelegate {
    func updateChat(message messageString: String) {
        MessagesViewController.jsonDecode(messageToDecode: messageString, completion: { messageinClosure, error in
            if error == nil {
                if let socketMessage = messageinClosure {
                    if  socketMessage.data?.sender == nil {
                        // Our User - Sending someone a message
                        socketMessage.message = messageinClosure?.data?.message
                        socketMessage.message_id = messageinClosure?.data?.message_id
                        socketMessage.is_sent_by_myself = true
                        socketMessage.timestamp = messageinClosure?.data?.timestamp
                        self.inputTextField.text = nil
                        self.showDataOnChatScreen(socket: socketMessage)
                    } else {
                        // Someone is sending you a message!
                        socketMessage.is_sent_by_myself = false
                        if let objMessage = messageinClosure {
                            if let message = objMessage.data, let sender = objMessage.data?.sender {
                                if let userId = sender.user_id {
                                    if  userId != self.to_user_id {
                                        if let user = sender.username {
                                            let notification = LocalNotification(title: "New message from \(user)", subTitle: "", body: message.message)
                                            LocalNotificationManager.shared.sendNotification(localNotification: notification)
                                        }
                                    } else {
                                        socketMessage.message = objMessage.data?.message
                                        socketMessage.message_id = objMessage.data?.message_id
                                        socketMessage.timestamp = messageinClosure?.data?.timestamp

                                        self.showDataOnChatScreen(socket: socketMessage)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    func showDataOnChatScreen(socket: ObjectMessage) {
        if socket.type == "chat" && socket.result == true {
            messages.append(socket)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.scroll(to: .bottom, animated: true)
            }
        }
    }
    class func jsonDecode(messageToDecode: String, completion: @escaping ( _ data: ObjectMessage?, _ error: Error?) -> Void) {
        do {
            let decoder = JSONDecoder()
            let data = Data(messageToDecode.utf8)
            
            let decodedMessage = try decoder.decode(ObjectMessage.self, from: data)
            return completion(decodedMessage, nil)
        } catch let error {
            return completion(nil, error)
        }
    }
}

extension MessagesViewController {
    func setTint() {
        self.tableView.tintColor = ChatColors.tint
        self.sendButton.tintColor = ChatColors.tint
        self.expandButton.tintColor = ChatColors.tint
        self.editButton.tintColor = ChatColors.tint
        self.deleteButton.tintColor = ChatColors.tint
        _ = self.actionButtons.map { btn in
            btn.tintColor = ChatColors.tint
        }
    }
    
    fileprivate func showDeleteActionSheet(rows: [IndexPath], messages: [ObjectMessage]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete For Everyone", style: .destructive , handler:{ (UIAlertAction)in
            self.deleteAndRemoveRows(rows: rows, messages: messages, deleteType: "everyone")
        }))
        alert.addAction(UIAlertAction(title: "Delete For Me", style: .destructive , handler:{ (UIAlertAction)in
            self.deleteAndRemoveRows(rows: rows, messages: messages, deleteType: "for_me")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            self.isEditing = !self.isEditing
        }))
        self.present(alert, animated: true, completion: {
        })
    }
    
    fileprivate func showDeleteforMeActionSheet(rows: [IndexPath], messages: [ObjectMessage]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete For Me", style: .destructive , handler:{ (UIAlertAction)in
            self.deleteAndRemoveRows(rows: rows, messages: messages, deleteType: "for_me")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            self.isEditing = !self.isEditing
        }))
        self.present(alert, animated: true, completion: {
        })
    }
    
    func setBackgroundTheme(image: UIImage? = nil) {
        let background = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
         background.image = image
         self.view.addSubview(background)
         self.view.sendSubviewToBack(background)
     }
}


