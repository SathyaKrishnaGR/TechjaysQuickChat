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
import Starscream

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
    var socket: WebSocket!
    var socketListDelegate: SocketListUpdateDelegate?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelectionDuringEditing = true
        FayvKeys.ChatDefaults.paginationLimit = "10"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.fetchData()
        deleteButton.isEnabled = true
        socket = socketManager.startSocketWith(url: FayvKeys.ChatDefaults.socketUrl)
        socketManager.listUpdateDelegate = self
        self.setTint()
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
                    if let toUserId = self.to_user_id {
                        vc.to_user_id = toUserId
                    }
                    vc.opponentUserName = opponentUserName
                    vc.toChatScreen = toChatScreen
                } else {
                    if let toUserId = conversations[selectedRow].to_user_id {
                        vc.to_user_id = toUserId
                        vc.conversation = conversations[selectedRow]
                    }
                }
                vc.socketManager.socket = self.socket
                vc.socketManager = self.socketManager
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
        if deleteButton.isEnabled {
            deleteButton.isEnabled = false
            deleteAndRemoveRows()
        }
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
                    self.tableView.scroll(to: .top, animated: true)
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
        self.deleteButton.isEnabled = true
        self.deleteButton.isUserInteractionEnabled = false
        self.editButton.setTitle("Edit", for: .normal)
        self.editButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    }
}

extension ConversationsViewController: SocketListUpdateDelegate {
    func updateChatList(message: String) {
        MessagesViewController.jsonDecode(messageToDecode: message, completion: { messageinClosure, error in
            if error == nil {
                if let socketMessage = messageinClosure {
                    if let message = socketMessage.data, let sender = message.sender {
                        if let userId = sender.user_id {
                            if self.conversations.contains(where: { conversation in conversation.to_user_id == userId }) {
                                print("1 exists in the array")
                            } else {
                                print("1 does not exists in the array")
                            }
                        }
                    }
                }
            }
        })
    }
}

//MARK: ProfileViewController Delegate
extension ConversationsViewController: ProfileViewControllerDelegate {
    func profileViewControllerDidLogOut() {
        navigationController?.dismiss(animated: true)
    }
}

extension ConversationsViewController {
    func setTint() {
        self.tableView.tintColor = ChatColors.tint
        self.navigationItem.rightBarButtonItem?.tintColor = ChatColors.tint
        self.navigationItem.leftBarButtonItem?.tintColor = ChatColors.tint
    }
}
