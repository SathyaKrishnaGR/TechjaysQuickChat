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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    //MARK: Private properties
    private var conversations = [ObjectConversation]()
    private let manager = ConversationManager()
    private let userManager = UserManager()
    private var currentUser: ObjectUser?
    var isFromReel: Bool?
    var userId: Int?
    var to_user_id: Int? = 0
    var opponentUserName: String?
    var selectedRow: Int =  -1 // Nothing is selected
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFromReel! {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "didSelect", sender: self)
//                let vc: MessagesViewController = UIStoryboard.initial(storyboard: .messages)
//                vc.to_user_id = self.userId!
//                vc.opponentUserName = self.opponentUserName
//                vc.isFromReel = self.isFromReel!
//                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.tableView.allowsMultipleSelection = true
        self.tableView.allowsMultipleSelectionDuringEditing = true
        self.tableView.fetchData()
        
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
                    vc.isFromReel = isFromReel!
                } else {
                    if let toUserId = conversations[selectedRow].to_user_id {
                        vc.to_user_id = toUserId
                        vc.conversation = conversations[selectedRow]
                    }
                }
            }
        }
    }
}

//MARK: IBActions
extension ConversationsViewController {
    
    @IBAction func profilePressed(_ sender: Any) {
        isEditing = true
        if let indexPaths = tableView.indexPathsForSelectedRows {
            //Sort the array so it doesn’t cause a crash depending on your selection order.
            let sortedPaths = indexPaths.sorted {$0.row > $1.row}
            for indexPath in sortedPaths {
                let count = conversations.count
                let index = count-1
                for i in stride(from: index, through: 0, by: -1) {
                    if(indexPath.row == i){
                        let toUserId = conversations[indexPath.row].to_user_id ?? 0
                        self.deleteChatList(users: "\(indexPath.row)", to_user_id: toUserId)
                        conversations.remove(at: i)
                    }
                }
            }
            isEditing = false
            tableView.deleteRows(at: sortedPaths, with: .automatic)
        }
    }
    
    
    
    
    @IBAction func composePressed(_ sender: Any) {}
}


//MARK: UITableView Delegate & DataSource
extension ConversationsViewController: PaginatedTableViewDelegate {
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
        if isEditing {} else{
            if conversations.isEmpty {
                composePressed(self)
                return
            }
        }
        
        selectedRow = indexPath.row
        performSegue(withIdentifier: "didSelect", sender: self)
    }
    
    func paginatedTableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if conversations.isEmpty {
            return tableView.bounds.height - 50 //header view height
        }
        return 80
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
    
    fileprivate func deleteChatList(users: String,to_user_id: Int ) {
        let url = URLFactory.shared.url(endpoint: "chat/delete-chat-list/", parameters: ["to_user_id": "\(to_user_id)"])
        APIClient().POST(url: url, headers: ["Authorization": FayvKeys.ChatDefaults.token], payload: users) { (status, response: APIResponse<[ObjectConversation]>) in
            switch status {
            case .SUCCESS:
                self.tableView.reloadData()
            case .FAILURE:
                print(response.msg)
            }
        }
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

