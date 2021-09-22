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

class MessagesViewController: UIViewController, KeyboardHandler {
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: PaginatedTableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var barBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var actionButtons: [UIButton]!
    
    //MARK: Private properties
    private let manager = MessageManager()
    private let imageService = ImagePickerService()
    private let locationService = LocationService()
    private var messages = [ObjectMessage]()
    var webSocket = SocketManager()
    
    //MARK: Public properties
    var conversation = ObjectConversation()
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
        self.tableView.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let url = conversation.medium_profile_pic {
            if #available(iOS 14.0, *) {
                showProfileIconOnNavBar(urlString: url)
            } else {
                // Fallback on earlier versions
            }
            
            webSocket.sendUrlForWebsocketConfigure(url: FayvKeys.ChatDefaults.socketUrl)
        }
        
    }
}

//MARK: Private methods
extension MessagesViewController {
    private func send(_ message: String) {
        if webSocketConnected {
        
            webSocket.sendMessage(chatToken: FayvKeys.ChatDefaults.chatToken, toUserId: String(to_user_id), message: message)
        }
        
        //        manager.create(message, conversation: conversation) {[weak self] response in
        //            guard let weakSelf = self else { return }
        //            if response == .failure {
        //                weakSelf.showAlert()
        //                return
        //            }
        //            weakSelf.conversation.timestamp = String(Date().timeIntervalSince1970)
        //            //      switch message.contentType {
        //      case .none: weakSelf.conversation.lastMessage = message.message
        //      case .photo: weakSelf.conversation.lastMessage = "Attachment"
        //      case .location: weakSelf.conversation.lastMessage = "Location"
        //      default: break
        //      }
        //      if let currentUserID = UserManager().currentUserID() {
        //        weakSelf.conversation.isRead[currentUserID] = true
        //      }
        //      ConversationManager().create(weakSelf.conversation)
    }
    //    }
    
    private func showProfileIconOnNavBar(urlString: String) {
        
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.setImage(url: URL(string : urlString)!)
        let imageData = try? Data(contentsOf: URL(string : urlString)!)
        
        if let imageData = imageData , let image =  UIImage(data: imageData)?.resizeImage(to: button.frame.size) {
            button.setBackgroundImage(image, for: .normal)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.title = conversation.first_name
        
    }
    
    private func showActionButtons(_ status: Bool) {
        guard !status else {
            stackViewWidthConstraint.constant = 112
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
    
    @IBAction func sendMessagePressed(_ sender: Any) {
        guard let text = inputTextField.text, !text.isEmpty else { return }
        let message = ObjectMessage()
        message.message = text
        //        message.ownerID = UserManager().currentUserID()
        inputTextField.text = nil
        showActionButtons(false)
        send(text)
    }
    
    @IBAction func sendImagePressed(_ sender: UIButton) {
        imageService.pickImage(from: self, allowEditing: false, source: sender.tag == 0 ? .photoLibrary : .camera) {[weak self] image in
            let message = ObjectMessage()
            //            message.contentType = .photo
            //            message.profilePic = image
            //            message.ownerID = UserManager().currentUserID()
            //            self?.send(message)
            self?.inputTextField.text = nil
            self?.showActionButtons(false)
        }
    }
    
    @IBAction func sendLocationPressed(_ sender: UIButton) {
        locationService.getLocation {[weak self] response in
            switch response {
            case .denied:
                self?.showAlert(title: "Error", message: "Please enable locattion services")
            case .location(let location):
                //                let message = ObjectMessage()
                //                message.ownerID = UserManager().currentUserID()
                //                message.content = location.string
                //                message.contentType = .location
                //                self?.send(message)
                self?.inputTextField.text = nil
                self?.showActionButtons(false)
            }
        }
    }
    
    @IBAction func expandItemsPressed(_ sender: UIButton) {
        showActionButtons(true)
    }
}

//MARK: UITableView Delegate & DataSource
extension MessagesViewController: PaginatedTableViewDelegate {
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
        let message = messages[indexPath.row]
        
        //        if message.contentType == .none {
        let cell = tableView.dequeueReusableCell(withIdentifier: message.message_id == UserManager().currentUserID() ? "MessageTableViewCell" : "UserMessageTableViewCell") as! MessageTableViewCell
        cell.set(message, conversation: conversation)
        return cell
        //        }
        //        let cell = tableView.dequeueReusableCell(withIdentifier: message.ownerID == UserManager().currentUserID() ? "MessageAttachmentTableViewCell" : "UserMessageAttachmentTableViewCell") as! MessageAttachmentTableViewCell
        //        cell.delegate = self
        //        cell.set(message)
        return cell
    }
    
    func paginatedTableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard tableView.isDragging else { return }
        cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            cell.transform = CGAffineTransform.identity
        })
    }
    
    func paginatedTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
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
}

//MARK: UItextField Delegate
extension MessagesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        showActionButtons(false)
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
                    
                    //                    self.messages = self.messages.sorted(by: {$0.timestamp < $1.timestamp})
                    self.tableView.reloadData()
                    self.tableView.scroll(to: .bottom, animated: true)
                }
                hasNext(response.nextLink ?? false)
            case .FAILURE:
                hasNext(false)
            }
        }
    }
}
extension UIImage {
    func resizeImage(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }}
