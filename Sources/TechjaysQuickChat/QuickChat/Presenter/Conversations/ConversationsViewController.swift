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

class ConversationsViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: PaginatedTableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    //MARK: Private properties
    private var conversations = [ObjectConversation]()
    private let manager = ConversationManager()
    private let userManager = UserManager()
    private var currentUser: ObjectUser?
    var toChatScreen: Bool = false
    var userId: Int?
    var to_user_id: Int? = 0
    var opponentUserName: String?
    var selectedRow: Int =  -1 // Nothing is selected
    var socketManager = SocketManager()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.fetchData()
        
        
        socketManager.startSocketWith(url: FayvKeys.ChatDefaults.socketUrl)
        socketManager.dataUpdateDelegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if toChatScreen {
            self.performSegue(withIdentifier: "didSelect", sender: self)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "didSelect" {
            let nav = segue.destination as! UINavigationController
            if let vc = nav.viewControllers.first as? MessagesViewController {
                if selectedRow == -1 {
                    vc.to_user_id = self.userId!
                    vc.opponentUserName = opponentUserName
                    vc.toChatScreen = toChatScreen
                } else {
                    if let toUserId = conversations[selectedRow].to_user_id {
                        vc.to_user_id = toUserId
                        vc.conversation = conversations[selectedRow]
                    }
                }
            }
            modalPresentationStyle = .fullScreen
        }
    }
}

//MARK: IBActions
extension ConversationsViewController {
    
    @IBAction func editPressed(_ sender: Any) {
        
        isEditing = !isEditing
        if isEditing {
            self.editButton.setTitle("Done", for: .normal)
            self.editButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            self.deleteButton.isHidden = false
            self.deleteButton.isUserInteractionEnabled = true
            
            
        } else {
            self.editButton.setTitle("Edit", for: .normal)
            self.editButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            self.deleteButton.isHidden = true
            self.deleteButton.isUserInteractionEnabled = false
            
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        deleteAndRemoveRows()
        
    }
    fileprivate func deleteAndRemoveRows() {
        var arrayOfIndex: [Int] = []
        if let selectedRows = tableView.indexPathsForSelectedRows {
            
            var selectedConversations = [ObjectConversation]()
            for indexPath in selectedRows  {
                arrayOfIndex.append(indexPath.row)
                selectedConversations.append(conversations[indexPath.row])
            }
            
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: selectedRows, with: .automatic)
            deleteChatList(rows: selectedRows, userIdToDelete: selectedConversations)
            
            
        }
    }
    
}


//MARK: UITableView Delegate & DataSource
extension ConversationsViewController: PaginatedTableViewDelegate {
    
    func paginatedTableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func paginatedTableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            conversations.remove(at: indexPath.row)
        }
        
    }
    func paginatedTableView(paginationEndpointFor tableView: UITableView) -> PaginationUrl {
        
        return PaginationUrl(endpoint: "chat/chat-lists/")
    }
    
    
    
    func paginatedTableView(_ tableView: UITableView, paginateTo url: String, isFirstPage: Bool, afterPagination hasNext: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            self.fetchConversations(for: url, isFirstPage: isFirstPage, hasNext: hasNext)
        }
        
    }
    
    func paginatedTableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if conversations.isEmpty {
            return 1
        }
        return conversations.count
    }
    
    func paginatedTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !conversations.isEmpty else {
            return tableView.dequeueReusableCell(withIdentifier: "EmptyCell")!
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.className, for: indexPath) as? ConversationCell {
            cell.set(conversations[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func paginatedTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isEditing {
            selectedRow = indexPath.row
            performSegue(withIdentifier: "didSelect", sender: self)
        }
        
    }
    
    func paginatedTableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if conversations.isEmpty {
            return tableView.bounds.height - 50 //header view height
        }
        return 80
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        
    }
}

extension ConversationsViewController {
    fileprivate func fetchConversations(for url: String, isFirstPage: Bool, hasNext: @escaping (Bool) -> Void) {
        APIClient().GET(url: url, headers: ["Authorization": FayvKeys.ChatDefaults.token]) { (status, response: APIResponse<[ObjectConversation]>) in
            switch status {
            case .SUCCESS:
                if let data = response.data {
                    if isFirstPage {
                        self.conversations = data
                    } else {
                        self.conversations.append(contentsOf: data )
                    }
                    self.tableView.reloadData()
                }
                hasNext(response.nextLink ?? false)
            case .FAILURE:
                hasNext(false)
            }
        }
    }
    
    fileprivate func deleteChatList(rows: [IndexPath], userIdToDelete: [ObjectConversation] ) {
        let stringArray = userIdToDelete.map { "\($0.to_user_id ?? 0)" }
        let payloadString = stringArray.joined(separator: ",")
        
        let url = URLFactory.shared.url(endpoint: "chat/delete-chat-list/")
        APIClient().POST(url: url, headers: ["Authorization": FayvKeys.ChatDefaults.token], payload: ["to_user_id": payloadString]) { (status, response: APIResponse<[ObjectConversation]>) in
            switch status {
            case .SUCCESS:
                self.conversations.removeArrayOfIndex(array: rows)
                self.isEditing = !self.isEditing
                self.resetEditAndDeletebuttons()
                self.tableView.endUpdates()
            case .FAILURE:
                print(response.msg)
                
            }
        }
    }
    
    fileprivate func resetEditAndDeletebuttons() {
        self.deleteButton.isHidden =  true
        self.deleteButton.isUserInteractionEnabled = false
        self.editButton.setTitle("Edit", for: .normal)
        self.editButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    }
}

//MARK: ProfileViewController Delegate
extension ConversationsViewController: ProfileViewControllerDelegate {
    func profileViewControllerDidLogOut() {
        //    userManager.logout()
        navigationController?.dismiss(animated: true)
    }
}

//MARK: ContactsPreviewController Delegate
extension ConversationsViewController: ContactsPreviewControllerDelegate {
    func contactsPreviewController(didSelect user: ObjectUser) {
        guard userManager.currentUserID() != nil else { return }
        let vc: MessagesViewController = UIStoryboard.initial(storyboard: .messages)
        //        if let conversation = conversations.filter({$0.userIDs.contains(user.id)}).first {
        //            vc.conversation = conversation
        //            show(vc, sender: self)
        //            return
        //        }
        let conversation = ObjectConversation()
        //        conversation.userIDs.append(contentsOf: [currentID, user.id])
        //        conversation.isRead = [currentID: true, user.id: true]
        vc.conversation = conversation
        show(vc, sender: self)
    }
}

extension Array {
    mutating func removeArrayOfIndex(array: [IndexPath]) {
        let res = array.map { index in
            self.remove(at: index.row)
        }
        
        print("Res is \(res)")
    }
}

extension ConversationsViewController: SocketDataTransferDelegate {
    func updateChatList(message messageString: String) {
        
        jsonDecode(messageToDecode: messageString, completion: { messageinClosure, error in
            
            print("Error is \(String(describing: error))")
            print("Message is \(String(describing: messageinClosure))")
            if error == nil {
                if let socketConversation = messageinClosure {
                     // Someone is sending you a message!
                    socketConversation.is_sent_by_myself = false
                    if let objMessage = messageinClosure {
                        if let message = objMessage.message {
                            socketConversation.company_name = objMessage.company_name
                            socketConversation.first_name = objMessage.first_name
                            socketConversation.to_user_id = objMessage.to_user_id
                            socketConversation.timestamp = objMessage.timestamp
                            
                            socketConversation.message = objMessage.message
                            
                        }
                    }
                    self.processTheDatafrom(socket: socketConversation)
                }
                
            }
        })
}

func processTheDatafrom(socket: ObjectConversation) {
    if socket.type == "chat" && !socket.is_sent_by_myself! && socket.to_user_id != nil {
        self.conversations.append(socket)
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.scroll(to: .top, animated: true)
            
        }
    }
    
}

func jsonDecode(messageToDecode: String, completion: @escaping ( _ data: ObjectConversation?, _ error: Error?) -> Void) {
    do {
        let decoder = JSONDecoder()
        let data = Data(messageToDecode.utf8)
        
        let decodedConversation = try decoder.decode(ObjectConversation.self, from: data)
        return completion(decodedConversation, nil)
    } catch let error {
        return completion(nil, error)
    }
}
}
