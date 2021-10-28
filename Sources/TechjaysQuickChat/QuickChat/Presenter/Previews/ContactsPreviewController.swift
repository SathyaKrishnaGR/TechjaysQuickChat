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
import Alamofire

class ContactsPreviewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tableView: PaginatedTableView!
    
    //MARK: Private properties
    private var users = [ObjectConversation]()
    private var searchArray = [ObjectConversation]()
    fileprivate var isSearchEnabled: Bool = false
    var toChatScreen: Bool = false
    var selectedRow: Int =  -1
    var opponentUserName: String?
    var socketManager = SocketManager()
    var socket: WebSocket!
    var to_user_id: Int? = 0
    private let manager = UserManager()

  
  @IBAction func closePressed(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
      socket = socketManager.startSocketWith(url: FayvKeys.ChatDefaults.socketUrl)
      self.setTint()
      self.tableView.fetchData()
    
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
            let nav = segue.destination as? UINavigationController
            if let vc = nav?.viewControllers.first as? MessagesViewController {
               /* if selectedRow == -1 {
                    if let toUserId = self.to_user_id {
                        vc.to_user_id = toUserId
                    }
                    vc.opponentUserName = opponentUserName
                    vc.toChatScreen = toChatScreen
                } else {*/
                   if isSearchEnabled {
                        if let toUserId = searchArray[selectedRow].to_user_id {
                             vc.to_user_id = toUserId
                             vc.conversation = searchArray[selectedRow]
                         }
                    } else {
                        if let toUserId = users[selectedRow].to_user_id {
                             vc.to_user_id = toUserId
                             vc.conversation = users[selectedRow]
                         }
                    }
                //}
                vc.socketManager.socket = self.socket
                vc.socketManager = self.socketManager
            }
            modalPresentationStyle = .fullScreen
        }
    }
}

extension ContactsPreviewController:PaginatedTableViewDelegate {
    func paginatedTableView(paginationEndpointFor tableView: UITableView) -> PaginationUrl {
        if isSearchEnabled {
            return PaginationUrl(endpoint: "chat/get-users-list/",search: searchbar.text ?? "",parameters: ["is_following":"true"])
        } else {
            return PaginationUrl(endpoint: "chat/get-users-list/",parameters: ["is_following":"true"])

        }
    }
    
    func paginatedTableView(_ tableView: UITableView, paginateTo url: String, isFirstPage: Bool, afterPagination hasNext: @escaping (Bool) -> Void) {
            self.fetchConversations(for: url, isFirstPage: isFirstPage, hasNext: hasNext)
        
    }
    
    func paginatedTableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchEnabled {
            return self.searchArray.count
        } else {
            return self.users.count
        }
    }
    
    func paginatedTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as? ConversationCell {
            var last = ""
            var first = ""
            if isSearchEnabled {
                if let lastName = self.searchArray[indexPath.row].last_name {
                    last = lastName
                }
                if let firstName = self.searchArray[indexPath.row].first_name {
                    first = firstName
                }
                
               cell.nameLabel?.text = "\(first) \(last)"
                
                cell.messageLabel?.text = self.searchArray[indexPath.row].username
              DispatchQueue.main.async {
                    if let urlString = self.searchArray[indexPath.row].medium_profile_pic {
                        cell.profilePic?.setImage(url: URL(string: urlString))
                    } else {
                        cell.profilePic?.image = UIImage(named: "profile_pic", in: Bundle.module, compatibleWith: .some(.current))
                        cell.profilePic?.contentMode = .scaleAspectFit
                    }
                }
            } else {
               if let lastName = self.users[indexPath.row].last_name {
                    last = lastName
                }
                if let firstName = self.users[indexPath.row].first_name {
                    first = firstName
                }
                
               cell.nameLabel?.text = "\(first) \(last)"
                
                cell.messageLabel?.text = self.users[indexPath.row].username
              DispatchQueue.main.async {
                    if let urlString = self.users[indexPath.row].medium_profile_pic {
                        cell.profilePic?.setImage(url: URL(string: urlString))
                    } else {
                        cell.profilePic?.image = UIImage(named: "profile_pic", in: Bundle.module, compatibleWith: .some(.current))
                        cell.profilePic?.contentMode = .scaleAspectFit
                    }
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func paginatedTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        performSegue(withIdentifier: "didSelect", sender: self)
    }
    
    func paginatedTableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if users.isEmpty {
            return tableView.bounds.height - 50 //header view height
        }
        return 80
    }
    
    fileprivate func fetchConversations(for url: String, isFirstPage: Bool, hasNext: @escaping (Bool) -> Void) {
        APIClient().GET(url: url, headers: ["Authorization": FayvKeys.ChatDefaults.token]) { (status, response: APIResponse<[ObjectConversation]>) in
            switch status {
            case .SUCCESS:
                if isFirstPage, let data = response.data {
                    if self.isSearchEnabled {
                        self.searchArray = data
                    } else {
                        self.users = data
                    }
                } else if let data = response.data {
                    if self.isSearchEnabled {
                        self.searchArray.append(contentsOf: data)
                    } else {
                        self.users.append(contentsOf: data)
                    }
                }
                self.tableView.reloadData()
                hasNext(response.nextLink ?? false)
                self.tableView.scroll(to: .top, animated: true)
            case .FAILURE:
                hasNext(false)
            }
        }
    }
}



extension ContactsPreviewController:UISearchBarDelegate {
   
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.resignFirstResponder()
        isSearchEnabled = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.resignFirstResponder()
        isSearchEnabled = false
    }
    
   func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.resignFirstResponder()
        isSearchEnabled = true
        self.tableView.fetchData()
        if searchText == "" {
            isSearchEnabled = false
            self.tableView.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !self.tableView.isLoading {
                self.tableView.reloadData()
            }
        }
    }
}

